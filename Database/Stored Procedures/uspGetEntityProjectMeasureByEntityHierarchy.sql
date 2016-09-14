IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityProjectMeasureByEntityHierarchy') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityProjectMeasureByEntityHierarchy
GO

/* uspGetEntityProjectMeasureByEntityHierarchy
 *
 *
 *
 *
*/
CREATE PROCEDURE uspGetEntityProjectMeasureByEntityHierarchy

	@bntEntityIdent BIGINT,
	@bntEntityProjectMeasureIdent BIGINT,
	@bntASUserIdent BIGINT

AS

	SET NOCOUNT ON

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
	
	CREATE TABLE #tmpPractices(
		Ident BIGINT,
		DisplayName NVARCHAR(MAX),
		Organization NVARCHAR(MAX),
		NPI NVARCHAR(10),
		Person BIT
	)
	
	CREATE TABLE #tmpPracticeRollup(
		OrganizationIdent BIGINT,
		AvailableTotal BIGINT,
		AnswerTotal BIGINT,
		Value1 MONEY,
		Value2 MONEY
	)

	CREATE TABLE #tmpOrganizationOptionListValues(
		OrganizationIdent BIGINT,
		Value1 NVARCHAR(MAX),
		ValueCount BIGINT,
		OrderWeight BIGINT
	)
	
	DECLARE @bntEntitySearchIdent BIGINT,
			@nvrEntityMeasureName1 NVARCHAR(MAX),
			@bntQuestion1EntityProjectRequirementIdent BIGINT,
			@bntQuestion2EntityProjectRequirementIdent BIGINT,
			@bntEntitySearchDataTypeIdent BIGINT,
			@bntEntitySearchDataTypeNumberIdent BIGINT,
			@bntEntitySearchDataTypeOptionsListIdent BIGINT,
			@bntEntitySearchDataTypeYesNoIdent BIGINT,
			@intQuestionCount BIGINT,
			@tblPracticeBreakdown [EntityOrganizationAnswerTable]

	SET @bntEntitySearchDataTypeNumberIdent = dbo.ufnEntitySearchDataTypeNumberIdent()
	SET @bntEntitySearchDataTypeOptionsListIdent = dbo.ufnEntitySearchDataTypeOptionsListIdent()
	SET @bntEntitySearchDataTypeYesNoIdent = dbo.ufnEntitySearchDataTypeYesNoIdent()

	-- this is going to look and feel like 	uspRecalculateEntityProjectMeasure for a bit, until we get to the entities
	-- from there, we'll need to group by organization
	SELECT
		@nvrEntityMeasureName1 = EPM.Name1,
		@bntEntitySearchIdent = EPM.EntitySearchIdent,
		@bntQuestion1EntityProjectRequirementIdent = EPM.Question1EntityProjectRequirementIdent,
		@bntQuestion2EntityProjectRequirementIdent = EPM.Question2EntityProjectRequirementIdent,
		@bntEntitySearchDataTypeIdent = MT.EntitySearchDataTypeIdent
	FROM
		EntityProjectMeasure EPM WITH (NOLOCK)
		INNER JOIN
		MeasureType MT WITH (NOLOCK)
			ON MT.Ident = EPM.MeasureTypeIdent
	WHERE
		EPM.Ident = @bntEntityProjectMeasureIdent
		AND EPM.EntityIdent = @bntEntityIdent
		AND EPM.Active = 1

	-- if the measure has a segment, we need to go determine that segments resources
	IF (@bntEntitySearchIdent > 0)
		BEGIN
				
			DECLARE @tblFilters [EntitySearchFilterTable],
				@tblEntity [EntitySearchOutput],
				@bntSearchEntityIdent BIGINT,
				@nvrKeyword NVARCHAR(MAX),
				@nvrLocation NVARCHAR(MAX),
				@decLatitude DECIMAL(20,8) = 0.0,
				@decLongitude DECIMAL(20,8) = 0.0,
				@intDistanceInMiles INT

			SELECT
				@bntSearchEntityIdent = EntityIdent,
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
			EXEC uspEntitySearchOutput @bntEntityIdent = @bntSearchEntityIdent,
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
		
	-- remove anyone who doesnt qualify based on the question/project availability
	DELETE
		#tmpRollup
	WHERE
		AvailableTotal <> @intQuestionCount

	-- get all the orgs/practices within this entities hierarchy
	INSERT INTO #tmpPractices(
		Ident,
		DisplayName,
		Organization,
		NPI,
		Person
	)
	EXEC uspGetEntityNetwork @bntEntityIdent, @bntASUserIdent, 0, 1

	-- setup unaffiliated (for those not within a group)
	INSERT INTO #tmpPractices(
		Ident,
		DisplayName,
		Organization,
		NPI,
		Person
	)
	SELECT
		0,
		'Unaffiliated',
		'Unaffiliated',
		'',
		0

	-- link the resources to their assigned orgs
	INSERT INTO @tblPracticeBreakdown(
		OrganizationIdent,
		EntityIdent,
		Answered,
		Value1,
		Value2
	)
	SELECT
		OrganizationIdent = tP.Ident,
		EntityIdent = tR.EntityIdent,
		Answered = CASE 
					WHEN tR.AnswerTotal = tR.AvailableTotal THEN 1
					ELSE 0
				   END,
		Value1 = '',
		Value2 = ''
	FROM
		#tmpRollup tR WITH (NOLOCK)
		INNER JOIN
		EntityHierarchy EH WITH (NOLOCK)
			ON EH.EntityIdent = @bntEntityIdent
			AND EH.ToEntityIdent = tR.EntityIdent
		INNER JOIN
		#tmpPractices tP WITH (NOLOCK)
			ON tP.Ident = EH.FromEntityIdent
	WHERE
		EH.Active = 1

	-- find everyone not in a practice, and mark as unaffiliated
	INSERT INTO @tblPracticeBreakdown(
		OrganizationIdent,
		EntityIdent,
		Answered,
		Value1,
		Value2
	)
	SELECT
		OrganizationIdent = 0,
		EntityIdent = tR.EntityIdent,
		Answered = CASE 
					WHEN tR.AnswerTotal = tR.AvailableTotal THEN 1
					ELSE 0
				   END,
		Value1 = '',
		Value2 = ''
	FROM
		#tmpRollup tR WITH (NOLOCK)
		OUTER APPLY
		(
		SELECT
			OrganizationIdent
		FROM
			@tblPracticeBreakdown tPR
		WHERE
			EntityIdent = tR.EntityIdent
		) A
	WHERE
		COALESCE(A.OrganizationIdent,0) = 0

	-- transfer the project answers to our breakdown table, well use that to finalize the data
	UPDATE
		tPR
	SET
		Value1 = tE.AnswerValue
	FROM
		@tblPracticeBreakdown tPR
		INNER JOIN
		#tmpEntities tE WITH (NOLOCK)
			ON tE.EntityIdent = tPR.EntityIdent
	WHERE
		tE.EntityProjectRequirementIdent = @bntQuestion1EntityProjectRequirementIdent
		AND tE.Answered = 1

	UPDATE
		tPR
	SET
		Value2 = tE.AnswerValue
	FROM
		@tblPracticeBreakdown tPR
		INNER JOIN
		#tmpEntities tE WITH (NOLOCK)
			ON tE.EntityIdent = tPR.EntityIdent
	WHERE
		@bntQuestion2EntityProjectRequirementIdent > 0
		AND tE.EntityProjectRequirementIdent = @bntQuestion2EntityProjectRequirementIdent
		AND tE.Answered = 1
		
	-- OK, now we need to totals based on each org
	-- 1. Numbers - Calculate the SUM for each question
	-- 2. Counts - Determine the COUNT of answered questions
	-- 3. Yes/No - Determine the COUNT of Yes answers
	-- 4. Options (Pie Chart) - Determine the COUNT of each answer
	IF (@bntEntitySearchDataTypeIdent = 0) -- get the counts
		BEGIN
				
			-- count their answers
			INSERT INTO #tmpPracticeRollup(
				OrganizationIdent,
				AvailableTotal,
				AnswerTotal,
				Value1,
				Value2
			)
			SELECT
				OrganizationIdent = tPR.OrganizationIdent,
				AvailableTotal = COUNT(*),
				AnswerTotal = SUM(CAST(tPR.Answered AS INT)),
				Value1 = SUM(CAST(tPR.Answered AS INT)),
				Value2 = 0
			FROM
				@tblPracticeBreakdown tPR
			GROUP BY
				OrganizationIdent

		END
	ELSE IF (@bntEntitySearchDataTypeIdent = @bntEntitySearchDataTypeNumberIdent) -- get the sums
		BEGIN
			
			-- sum their answers
			INSERT INTO #tmpPracticeRollup(
				OrganizationIdent,
				AvailableTotal,
				AnswerTotal,
				Value1,
				Value2
			)
			SELECT
				OrganizationIdent = tPR.OrganizationIdent,
				AvailableTotal = COUNT(*),
				AnswerTotal = SUM(CAST(tPR.Answered AS INT)),
				Value1 = SUM(COALESCE(TRY_CAST(tPR.Value1 AS MONEY), 0.0)),
				Value2 = SUM(COALESCE(TRY_CAST(tPR.Value2 AS MONEY), 0.0))
			FROM
				@tblPracticeBreakdown tPR
			GROUP BY
				OrganizationIdent

		END
	ELSE IF (@bntEntitySearchDataTypeIdent = @bntEntitySearchDataTypeOptionsListIdent)
		BEGIN

			-- count their answers
			INSERT INTO #tmpPracticeRollup(
				OrganizationIdent,
				AvailableTotal,
				AnswerTotal,
				Value1,
				Value2
			)
			SELECT
				OrganizationIdent = tPR.OrganizationIdent,
				AvailableTotal = COUNT(*),
				AnswerTotal = SUM(CAST(tPR.Answered AS INT)),
				Value1 = SUM(CAST(tPR.Answered AS INT)),
				Value2 = 0
			FROM
				@tblPracticeBreakdown tPR
			GROUP BY
				OrganizationIdent

			INSERT INTO #tmpOrganizationOptionListValues(
				OrganizationIdent,
				Value1,
				ValueCount,
				OrderWeight
			)
			SELECT
				OrganizationIdent,
				Value1,
				ValueCount,
				OrderWeight
			FROM
				dbo.ufnGetOptionListValueCountByOrganization(@tblPracticeBreakdown, @bntQuestion1EntityProjectRequirementIdent)

		END
	ELSE IF (@bntEntitySearchDataTypeIdent = @bntEntitySearchDataTypeYesNoIdent) 
		BEGIN
				
			-- and count their answers where = Yes
			INSERT INTO #tmpPracticeRollup(
				OrganizationIdent,
				AvailableTotal,
				AnswerTotal,
				Value1,
				Value2
			)
			SELECT
				OrganizationIdent = tPR.OrganizationIdent,
				AvailableTotal = COUNT(*),
				AnswerTotal = SUM(CAST(tPR.Answered AS INT)),
				Value1 = CASE tPR.Value1
							WHEN 'Yes' THEN 1
							ELSE 0
						 END,
				Value2 = 0
			FROM
				@tblPracticeBreakdown tPR
			GROUP BY
				tPR.OrganizationIdent,
				tPR.Value1

		END

	-- final select - Measure Name
	SELECT
		@nvrEntityMeasureName1 as [Name1]

	-- final select - Measures (by Org)
	SELECT
		EPM.Ident,
		EPM.EntityIdent,
		tP.Ident as [OrganizationIdent],
		tP.Organization AS [Name1],
		EPM.Desc1,
		EPM.EntitySearchIdent,
		MT.EntitySearchDataTypeIdent,
		MT.HasDenominator,
		MT.HasTargetValue,
		MT.IsAverage,
		MT.IsPercentage,
		EPM.MeasureTypeIdent,
		MT.Name1 AS [MeasureType],
		0 AS [EntityProject1Ident],
		'' AS [EntityProject1Name],
		EPM.Question1EntityProjectRequirementIdent,
		EPR.RequirementTypeIdent AS [Question1RequirementTypeIdent],
		0 AS [EntityProject2Ident],
		'' AS [EntityProject2Name],
		EPM.Question2EntityProjectRequirementIdent,
		EPM.TargetValue,
		EPM.LastRecalculateDate,
		COALESCE(tPR.Value1, 0.0) as [Question1Value],
		COALESCE(tPR.Value2, 0.0) as [Question2Value],
		COALESCE(tPR.AnswerTotal, 0) AS [TotalResourcesComplete],
		tPR.AvailableTotal AS [TotalResourcesAvailable]
	FROM
		#tmpPracticeRollup tPR WITH (NOLOCK)
		INNER JOIN
		#tmpPractices tP WITH (NOLOCK)
			ON tP.Ident = tPR.OrganizationIdent
		INNER JOIN
		EntityProjectMeasure EPM WITH (NOLOCK)
			ON EPM.Ident = @bntEntityProjectMeasureIdent
		INNER JOIN
		MeasureType MT WITH (NOLOCK)
			ON MT.Ident = EPM.MeasureTypeIdent
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.Ident = EPM.Question1EntityProjectRequirementIdent
	ORDER BY
		CASE tP.Ident 
			WHEN 0 THEN 'ZZZZZZZZZZZZZZZZ'
			ELSE tP.Organization
		END ASC

	-- final select - Measure Ranges
	SELECT
		EPMR.Ident,
		EPMR.EntityProjectMeasureIdent,
		EPMR.Name1,
		EPMR.Color,
		EPMR.RangeStartValue,
		EPMR.RangeEndValue
	FROM
		EntityProjectMeasureRange EPMR WITH (NOLOCK)
	WHERE
		EPMR.EntityProjectMeasureIdent = @bntEntityProjectMeasureIdent
		AND EPMR.Active = 1
	ORDER BY
		EPMR.EntityProjectMeasureIdent ASC,
		EPMR.RangeStartValue ASC

	-- final select - Measure Values
	SELECT
		0 as [Ident],
		OrganizationIdent,
		Value1,
		ValueCount,
		OrderWeight
	FROM
		#tmpOrganizationOptionListValues WITH (NOLOCK)
	ORDER BY
		OrganizationIdent ASC,
		OrderWeight DESC

	-- participant list
	SELECT
		tPR.EntityIdent,
		E.FullName,
		E.DisplayName,
		E.NPI,
		E.ProfilePhoto,
		tPR.OrganizationIdent as [OrganizationIdent],
		tP.Organization,
		tPR.Value1,
		tPR.Value2,
		tPR.Value1 as [Value1String],
		tPR.Value2 as [Value2String],
		tPR.Answered
	FROM
		@tblPracticeBreakdown tPR
		INNER JOIN
		#tmpPractices tP WITH (NOLOCK)
			ON tP.Ident = tPR.OrganizationIdent
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = tPR.EntityIdent
	ORDER BY
		tP.Organization ASC,
		E.DisplayName ASC

	DROP TABLE #tmpEntities
	DROP TABLE #tmpRollup
	DROP TABLE #tmpPractices
	DROP TABLE #tmpPracticeRollup
	DROP TABLE #tmpOrganizationOptionListValues

GO
