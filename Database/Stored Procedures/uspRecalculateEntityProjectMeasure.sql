IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspRecalculateEntityProjectMeasure') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspRecalculateEntityProjectMeasure
GO

/* uspRecalculateEntityProjectMeasure 7, 0
 *
 *	
 *
 */

CREATE PROCEDURE uspRecalculateEntityProjectMeasure

	@bntIdent BIGINT,
	@bitSupressOutput BIT

AS
	
	SET NOCOUNT ON

	DECLARE @intUpdateCount INT

	CREATE TABLE #tmpMeasures(
		EntityProjectMeasureIdent BIGINT,
		EntitySearchDataTypeIdent BIGINT,
		LastRecalculateDate DATETIME,
		Question1EntityProjectRequirementIdent BIGINT,
		Question2EntityProjectRequirementIdent BIGINT,
		EntitySearchIdent BIGINT
	)

	-- Determine if we need to recalcuate any measures
	INSERT INTO #tmpMeasures(
		EntityProjectMeasureIdent,
		EntitySearchDataTypeIdent,
		LastRecalculateDate,
		Question1EntityProjectRequirementIdent,
		Question2EntityProjectRequirementIdent,
		EntitySearchIdent
	)
	SELECT
		EPM.Ident,
		MT.EntitySearchDataTypeIdent,
		EPM.LastRecalculateDate,
		EPM.Question1EntityProjectRequirementIdent,
		EPM.Question2EntityProjectRequirementIdent,
		EPM.EntitySearchIdent
	FROM
		EntityProjectMeasure EPM WITH (NOLOCK)
		INNER JOIN
		MeasureType MT WITH (NOLOCK)
			ON MT.Ident = EPM.MeasureTypeIdent
	WHERE
		@bntIdent > 0
		AND EPM.Ident = @bntIdent
		AND EPM.Recalculate = 1
		AND EPM.Active = 1
	UNION ALL
	SELECT TOP 1
		EPM.Ident,
		MT.EntitySearchDataTypeIdent,
		EPM.LastRecalculateDate,
		EPM.Question1EntityProjectRequirementIdent,
		EPM.Question2EntityProjectRequirementIdent,
		EPM.EntitySearchIdent
	FROM
		EntityProjectMeasure EPM WITH (NOLOCK)
		INNER JOIN
		MeasureType MT WITH (NOLOCK)
			ON MT.Ident = EPM.MeasureTypeIdent
	WHERE
		@bntIdent = 0
		AND EPM.Recalculate = 1
		AND EPM.Active = 1
	ORDER BY
		EPM.LastRecalculateDate ASC

	
	SELECT @intUpdateCount = COUNT(*) FROM #tmpMeasures WITH (NOLOCK)

	IF (@intUpdateCount > 0)
	BEGIN

		DECLARE @bntEntityProjectMeasureIdent BIGINT,
				@bntEntitySearchDataTypeIdent BIGINT,
				@intQuestionCount BIGINT,
				@bntQuestion1EntityProjectRequirementIdent BIGINT,
				@bntQuestion2EntityProjectRequirementIdent BIGINT,
				@decQuestion1Value MONEY,
				@decQuestion2Value MONEY,
				@bntTotalResourcesComplete BIGINT,
				@bntTotalResourcesAvailable BIGINT,
				@bntEntitySearchDataTypeNumberIdent BIGINT,
				@bntEntitySearchDataTypeOptionsListIdent BIGINT,
				@bntEntitySearchDataTypeYesNoIdent BIGINT
				
		SET @bntEntitySearchDataTypeNumberIdent = dbo.ufnEntitySearchDataTypeNumberIdent()
		SET @bntEntitySearchDataTypeOptionsListIdent = dbo.ufnEntitySearchDataTypeOptionsListIdent()
		SET @bntEntitySearchDataTypeYesNoIdent = dbo.ufnEntitySearchDataTypeYesNoIdent()	

		DECLARE @bntEntitySearchIdent BIGINT,
				@tblFilters [EntitySearchFilterTable],
				@tblEntity [EntitySearchOutput],
				@bntASUserIdent BIGINT,
				@nvrKeyword NVARCHAR(MAX),
				@nvrLocation NVARCHAR(MAX),
				@decLatitude DECIMAL(20,8) = 0.0,
				@decLongitude DECIMAL(20,8) = 0.0,
				@intDistanceInMiles INT

		CREATE TABLE #tmpEntities(
			EntityIdent BIGINT,
			EntityProjectEntityIdent BIGINT,
			EntityProjectRequirementIdent BIGINT,
			EntityProjectEntityAnswerIdent BIGINT,
			Answered BIT,
			AnswerValue NVARCHAR(MAX)
		)

		CREATE NONCLUSTERED INDEX idx_tmpEntities_SearchCoveringIndex ON #tmpEntities(EntityIdent)

		CREATE TABLE #tmpRollup(
			EntityIdent BIGINT,
			AvailableTotal BIGINT,
			AnswerTotal BIGINT
		)

		CREATE TABLE #tmpOptionListValues(
			Value1 NVARCHAR(MAX),
			ValueCount BIGINT
		)

		SELECT
			@bntEntityProjectMeasureIdent = EntityProjectMeasureIdent,
			@bntEntitySearchIdent = EntitySearchIdent,
			@bntQuestion1EntityProjectRequirementIdent = Question1EntityProjectRequirementIdent,
			@bntQuestion2EntityProjectRequirementIdent = Question2EntityProjectRequirementIdent,
			@bntEntitySearchDataTypeIdent = EntitySearchDataTypeIdent
		FROM
			#tmpMeasures WITH (NOLOCK)

		-- if the measure has a segment, we need to go determine that segments resources
		IF (@bntEntitySearchIdent > 0)
			BEGIN
				
				SELECT
					@bntASUserIdent = EntityIdent,
					@nvrKeyword = Keyword,
					@nvrLocation = Location,
					@decLatitude = Latitude,
					@decLongitude = Longitude,
					@intDistanceInMiles = DistanceInMiles
				FROM
					EntitySearch WITH (NOLOCK)
				WHERE
					Ident = @bntEntitySearchIdent

				INSERT INTO @tblFilters(
					Ident,
					EntitySearchFilterTypeIdent,
					EntitySearchOperatorIdent,
					EntityProjectRequirementIdent,
					ReferenceIdent,
					SearchValue
				)
				SELECT
					Ident,
					EntitySearchFilterTypeIdent,
					EntitySearchOperatorIdent,
					EntityProjectRequirementIdent,
					ReferenceIdent,
					SearchValue
				FROM
					EntitySearchFilter WITH (NOLOCK)
				WHERE
					EntitySearchIdent = @bntEntitySearchIdent
					AND Active = 1

				INSERT INTO @tblEntity(
					EntityIdent,
					DisplayName,
					Person,
					Distance,
					SearchResults,
					EntitySearchHistoryIdent
				)
				EXEC uspEntitySearchOutput @bntEntityIdent = @bntASUserIdent,
												@bntASUserIdent = @bntASUserIdent,
												@nvrKeyword = @nvrKeyword,
												@nvrLocation = @nvrLocation,
												@decLatitude = @decLatitude,
												@decLongitude = @decLongitude,
												@intDistanceInMiles = @intDistanceInMiles,
												@bntResultsShown = 0,
												@tblFilters = @tblFilters

			END -- IF (@bntEntitySearchIdent > 0) 

		-- at this point we need to determine if the questions are across different projects
		SET @intQuestionCount = 1
		
		-- if they are, set our count, we'll need it later
		IF (@bntQuestion2EntityProjectRequirementIdent <> 0)
			BEGIN
				SET @intQuestionCount = 2
			END

		-- get the list of entity answers that qualify for the measure
		INSERT INTO #tmpEntities(
			EntityIdent,
			EntityProjectEntityIdent,
			EntityProjectRequirementIdent,
			EntityProjectEntityAnswerIdent,
			Answered,
			AnswerValue
		)
		SELECT
			EntityIdent,
			EntityProjectEntityIdent,
			EntityProjectRequirementIdent,
			EntityProjectEntityAnswerIdent,
			Answered,
			AnswerValue
		FROM
			dbo.ufnGetEntityProjectMeasureEntities(@bntQuestion1EntityProjectRequirementIdent, @bntQuestion2EntityProjectRequirementIdent, @tblEntity)

		-- roll up the data so we can get totals
		INSERT INTO #tmpRollup(
			EntityIdent,
			AvailableTotal,
			AnswerTotal
		)
		SELECT
			EntityIdent = EntityIdent,
			AvailableTotal = COUNT(*),
			AnswerTotal = SUM(CAST(Answered AS INT))
		FROM
			#tmpEntities WITH (NOLOCK)
		GROUP BY
			EntityIdent

		-- get the count of matching available resources
		SELECT 
			@bntTotalResourcesAvailable = COUNT(*)
		FROM
			#tmpRollup WITH (NOLOCK)
		WHERE
			AvailableTotal = @intQuestionCount

		SELECT 
			@bntTotalResourcesComplete = COUNT(*)
		FROM
			#tmpRollup WITH (NOLOCK)
		WHERE
			AnswerTotal = @intQuestionCount

		-- OK, now that we've determine WHO we need to collect data from, lets go determine what the results are going to be, 
		-- we have a few scenarios
		-- 1. Numbers - Calculate the SUM for each question
		-- 2. Counts - Determine the COUNT of answered questions
		-- 3. Yes/No - Determine the COUNT of Yes answers
		-- 4. Options (Pie Chart) - Determine the COUNT of each answer
		IF (@bntEntitySearchDataTypeIdent = 0) -- get the counts
			BEGIN
				
				-- and count their answers to Q1
				SELECT
					@decQuestion1Value = COUNT(*)
				FROM
					#tmpRollup tR WITH (NOLOCK)
				WHERE
					tR.AnswerTotal = @intQuestionCount

			END
		ELSE IF (@bntEntitySearchDataTypeIdent = @bntEntitySearchDataTypeNumberIdent) -- get the sums
			BEGIN
				
				-- and sum their answers to Q1
				SELECT
					@decQuestion1Value = SUM(COALESCE(TRY_CAST(tE.AnswerValue AS MONEY), 0.0))
				FROM
					#tmpRollup tR WITH (NOLOCK)
					INNER JOIN
					#tmpEntities tE WITH (NOLOCK)
						ON tE.EntityIdent = tR.EntityIdent
				WHERE
					tR.AnswerTotal = @intQuestionCount
					AND tE.EntityProjectRequirementIdent = @bntQuestion1EntityProjectRequirementIdent

				-- and sum their answers to Q2
				SELECT
					@decQuestion2Value = SUM(COALESCE(TRY_CAST(tE.AnswerValue AS MONEY), 0.0))
				FROM
					#tmpRollup tR WITH (NOLOCK)
					INNER JOIN
					#tmpEntities tE WITH (NOLOCK)
						ON tE.EntityIdent = tR.EntityIdent
				WHERE
					tR.AnswerTotal = @intQuestionCount
					AND tE.EntityProjectRequirementIdent = @bntQuestion2EntityProjectRequirementIdent

			END
		ELSE IF (@bntEntitySearchDataTypeIdent = @bntEntitySearchDataTypeOptionsListIdent)
			BEGIN
				
				-- reset our table var and pass into the option list calc process
				DELETE @tblEntity
				
				INSERT INTO @tblEntity(
					EntityIdent
				)
				SELECT
					EntityIdent
				FROM
					#tmpRollup WITH (NOLOCK)

				INSERT INTO #tmpOptionListValues(
					Value1,
					ValueCount
				)
				SELECT
					Value1,
					ValueCount
				FROM
					dbo.ufnGetOptionListValueCount(@tblEntity, @bntQuestion1EntityProjectRequirementIdent)

			END
		ELSE IF (@bntEntitySearchDataTypeIdent = @bntEntitySearchDataTypeYesNoIdent) 
			BEGIN
				
				-- get the count of yes
				SELECT
					@decQuestion1Value = COUNT(*)
				FROM
					#tmpRollup tR WITH (NOLOCK)
					INNER JOIN
					#tmpEntities tE WITH (NOLOCK)
						ON tE.EntityIdent = tR.EntityIdent
				WHERE
					tR.AnswerTotal = @intQuestionCount
					AND tE.EntityProjectRequirementIdent = @bntQuestion1EntityProjectRequirementIdent
					AND tE.AnswerValue = 'Yes'
			
			END
	
		UPDATE
			EPM
		SET
			Recalculate = 0, -- remove it from the queue to be processed
			LastRecalculateDate = dbo.ufnGetMyDate(),
			Question1Value = COALESCE(@decQuestion1Value, 0.0),
			Question2Value = COALESCE(@decQuestion2Value, 0.0),
			TotalResourcesComplete = @bntTotalResourcesComplete,
			TotalResourcesAvailable = @bntTotalResourcesAvailable
		FROM
			EntityProjectMeasure EPM WITH (NOLOCK)
		WHERE
			EPM.Ident = @bntEntityProjectMeasureIdent

		-- start by clearing the slate for this measures values
		UPDATE
			EntityProjectMeasureValue
		SET
			Active = 0,
			EditDateTime = dbo.ufnGetMyDate()
		WHERE
			EntityProjectMeasureIdent = @bntEntityProjectMeasureIdent

		-- and add/reactivate the values
		MERGE 
			EntityProjectMeasureValue AS [target]
		USING 
			#tmpOptionListValues AS [source] 
				ON 
				([target].EntityProjectMeasureIdent = @bntEntityProjectMeasureIdent
					AND [target].Value1 = [source].Value1)
    		WHEN MATCHED THEN 
			UPDATE SET 
					ValueCount = [source].ValueCount,
					Active = 1,
					EditDateTime = dbo.ufnGetMyDate()
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT (
					EntityProjectMeasureIdent,
					Value1,
					ValueCount,
					AddASUserIdent,
					AddDateTime,
					EditASUserIdent,
					EditDateTime,
					Active
					)
			VALUES (
					@bntEntityProjectMeasureIdent,
					source.Value1,
					source.ValueCount,
					0,
					dbo.ufnGetMyDate(),
					0,
					'1/1/1900',
					1
					); -- You really do need to end this function with a semi-colon

		DROP TABLE #tmpEntities
		DROP TABLE #tmpRollup
		DROP TABLE #tmpOptionListValues

		IF (@bitSupressOutput = 0)
			BEGIN
				SELECT @bntEntityProjectMeasureIdent as [EntityProjectMeasureIdent]
			END

	END -- IF (@intUpdateCount > 0)

	DROP TABLE #tmpMeasures

GO