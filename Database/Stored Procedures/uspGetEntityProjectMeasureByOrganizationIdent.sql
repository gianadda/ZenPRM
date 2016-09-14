IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityProjectMeasureByOrganizationIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityProjectMeasureByOrganizationIdent
GO

/* uspGetEntityProjectMeasureByOrganizationIdent 2, 306487, 4, 496986
 *
 *
 * Returns dials per resources with an organization
 *
*/
CREATE PROCEDURE uspGetEntityProjectMeasureByOrganizationIdent

	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT,
	@bntMeasureLocationIdent BIGINT,
	@bntOrganizationIdent BIGINT

AS

	SET NOCOUNT ON

	DECLARE @nvrOther NVARCHAR(5) = dbo.ufnGetEntityProjectMeasureOther()
	DECLARE @bntEntitySearchDataTypeNumberIdent BIGINT
	DECLARE @bntEntitySearchDataTypeOptionsListIdent BIGINT
	DECLARE @bntEntitySearchDataTypeYesNoIdent BIGINT

	SET @bntEntitySearchDataTypeNumberIdent = dbo.ufnEntitySearchDataTypeNumberIdent()
	SET @bntEntitySearchDataTypeOptionsListIdent = dbo.ufnEntitySearchDataTypeOptionsListIdent()
	SET @bntEntitySearchDataTypeYesNoIdent = dbo.ufnEntitySearchDataTypeYesNoIdent()

	DECLARE @bntMeasureIdent BIGINT, 
			@bntEntitySearchIdent BIGINT,
			@bntEntitySearchDataTypeIdent BIGINT,
			@bntQuestion1EntityProjectRequirementIdent BIGINT, 
			@bntQuestion2EntityProjectRequirementIdent BIGINT,
			@tblEntity [EntitySearchOutput]

	
	/*** Entity Search Variables***/
	DECLARE @tblFilters [EntitySearchFilterTable],
		@nvrKeyword NVARCHAR(MAX),
		@nvrLocation NVARCHAR(MAX),
		@decLatitude DECIMAL(20,8) = 0.0,
		@decLongitude DECIMAL(20,8) = 0.0,
		@intDistanceInMiles INT

    CREATE TABLE #tmpMeasures(
        Ident BIGINT,
		EntitySearchDataTypeIdent BIGINT,
		EntitySearchIdent BIGINT,
        Question1EntityProjectRequirementIdent BIGINT,
        Question2EntityProjectRequirementIdent BIGINT
    )

	CREATE TABLE #tmpEntityHierarchy(
		EntityIdent BIGINT
	)
	
	CREATE TABLE #tmpEntitySegment(
		EntitySearchIdent BIGINT,
		EntityIdent BIGINT
	)

	CREATE TABLE #tmpEntities(
		EntityIdent BIGINT,
		MeasureIdent BIGINT,
		EntityProjectEntityIdent BIGINT,
		EntityProjectRequirementIdent BIGINT,
		EntityProjectEntityAnswerIdent BIGINT,
		Answered BIT,
		AnswerValue NVARCHAR(MAX)
	)
	
	CREATE TABLE #tmpValues(
		Ident BIGINT IDENTITY(1,1),
		EntityProjectMeasureIdent BIGINT,
		Value1 NVARCHAR(MAX),
		ValueCount BIGINT
	)
	
	CREATE TABLE #tmpMeasureRollup(
		MeasureIdent BIGINT,
		AvailableTotal BIGINT,
		AnswerTotal BIGINT,
		Value1 MONEY,
		Value2 MONEY
	)

	CREATE NONCLUSTERED INDEX idx_tmpEntities_SearchCoveringIndex ON #tmpEntities(EntityIdent, MeasureIdent)
	CREATE NONCLUSTERED INDEX idx_tmpEntityHierarchy_SearchCoveringIndex ON #tmpEntityHierarchy(EntityIdent)
	CREATE NONCLUSTERED INDEX idx_tmpEntitiesSegment_SearchCoveringIndex ON #tmpEntitySegment(EntityIdent, EntitySearchIdent)

	-- first, get a list of the measures that could be displayed on this orgs profile 
	INSERT INTO #tmpMeasures(
        Ident,
		EntitySearchDataTypeIdent,
		EntitySearchIdent,
        Question1EntityProjectRequirementIdent,
        Question2EntityProjectRequirementIdent
    )
	SELECT
		EPM.Ident,
		MT.EntitySearchDataTypeIdent,
		EPM.EntitySearchIdent,
		EPM.Question1EntityProjectRequirementIdent,
		EPM.Question2EntityProjectRequirementIdent
	FROM
		EntityProjectMeasure EPM WITH (NOLOCK)
		INNER JOIN
		EntityProjectMeasureLocationXref X WITH (NOLOCK)
			ON X.EntityProjectMeasureIdent = EPM.Ident
		INNER JOIN
		MeasureType MT WITH (NOLOCK)
			ON MT.Ident = EPM.MeasureTypeIdent
	WHERE
		EPM.EntityIdent = @bntEntityIdent
		AND EPM.Active = 1
		AND X.MeasureLocationIdent = @bntMeasureLocationIdent
		AND X.Active = 1

	-- next, get a list of the entities hierarchy
	-- this list the max entities that would be used in the calcs below
	INSERT INTO #tmpEntityHierarchy(
		EntityIdent
	)
	SELECT
		ToEntityIdent
	FROM
		EntityHierarchy EH WITH (NOLOCK)
	WHERE
		EH.EntityIdent = @bntEntityIdent
		AND EH.FromEntityIdent = @bntOrganizationIdent
		AND EH.Active = 1

	-- now, if a measure has a segment applied
	-- determine if this resource is in the segment prior to continuing
	-- we can group the segments by EntitySearchIdent, so if multiple measures utilize the same segment
	-- we can minimize effort
	DECLARE segment_cursor CURSOR FOR

		SELECT
			EntitySearchIdent
		FROM
			#tmpMeasures WITH (NOLOCK)
		GROUP BY
			EntitySearchIdent

		OPEN segment_cursor
		
		FETCH NEXT FROM segment_cursor
		INTO @bntEntitySearchIdent

		WHILE @@FETCH_STATUS = 0
		BEGIN
	
			SELECT
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
			EXEC uspEntitySearchOutput @bntEntityIdent = @bntEntityIdent,
											@bntASUserIdent = @bntASUserIdent,
											@nvrKeyword = @nvrKeyword,
											@nvrLocation = @nvrLocation,
											@decLatitude = @decLatitude,
											@decLongitude = @decLongitude,
											@intDistanceInMiles = @intDistanceInMiles,
											@bntResultsShown = 0,
											@tblFilters = @tblFilters

			-- and reflect the changes in the segment table		
			INSERT INTO #tmpEntitySegment(
				EntitySearchIdent,
				EntityIdent
			)
			SELECT
				@bntEntitySearchIdent,
				tE.EntityIdent
			FROM
				@tblEntity tE
				INNER JOIN
				#tmpEntityHierarchy tEH WITH (NOLOCK)
					ON tEH.EntityIdent = tE.EntityIdent

			DELETE @tblFilters
			DELETE @tblEntity
		
			FETCH NEXT FROM segment_cursor
			INTO @bntEntitySearchIdent

		END
		
	CLOSE segment_cursor
	DEALLOCATE segment_cursor

	-- now loop through each measure and determine the applicable resources and their answers
	DECLARE measure_cursor CURSOR FOR

		SELECT
			Ident,
			EntitySearchIdent,
			EntitySearchDataTypeIdent,
			Question1EntityProjectRequirementIdent,
			Question2EntityProjectRequirementIdent
		FROM
			#tmpMeasures WITH (NOLOCK)

		OPEN measure_cursor

		FETCH NEXT FROM measure_cursor
		INTO @bntMeasureIdent, @bntEntitySearchIdent, @bntEntitySearchDataTypeIdent, @bntQuestion1EntityProjectRequirementIdent, @bntQuestion2EntityProjectRequirementIdent

		WHILE @@FETCH_STATUS = 0
		BEGIN

			DELETE @tblEntity

			-- if there is not a segment applied to this measure, then the applicable entities are the orgs hierarchy
			INSERT INTO @tblEntity(
				EntityIdent,
				DisplayName,
				Person,
				Distance,
				SearchResults,
				EntitySearchHistoryIdent
			)
			SELECT
				EntityIdent = EntityIdent,
				DisplayName = '',
				Person = 0,
				Distance = 0.0,
				SearchResults = 0,
				EntitySearchHistoryIdent = 0
			FROM
				#tmpEntityHierarchy WITH (NOLOCK)
			WHERE
				@bntEntitySearchIdent = 0

			-- otherwise, if there is a segment applied to this measure, get only segment of the hierarchy that
			INSERT INTO @tblEntity(
				EntityIdent,
				DisplayName,
				Person,
				Distance,
				SearchResults,
				EntitySearchHistoryIdent
			)
			SELECT
				EntityIdent = EntityIdent,
				DisplayName = '',
				Person = 0,
				Distance = 0.0,
				SearchResults = 0,
				EntitySearchHistoryIdent = 0
			FROM
				#tmpEntitySegment WITH (NOLOCK)
			WHERE
				@bntEntitySearchIdent > 0
				AND EntitySearchIdent = @bntEntitySearchIdent

			INSERT INTO #tmpEntities(
				EntityIdent,
				MeasureIdent,
				EntityProjectEntityIdent,
				EntityProjectRequirementIdent,
				EntityProjectEntityAnswerIdent,
				Answered,
				AnswerValue
			)
			SELECT
				EntityIdent,
				@bntMeasureIdent,
				EntityProjectEntityIdent,
				EntityProjectRequirementIdent,
				EntityProjectEntityAnswerIdent,
				Answered,
				AnswerValue
			FROM
				dbo.ufnGetEntityProjectMeasureEntities(@bntQuestion1EntityProjectRequirementIdent, @bntQuestion2EntityProjectRequirementIdent, @tblEntity)
				
			-- if this is an option list, get a breakdown of the values
			INSERT INTO #tmpValues(
				EntityProjectMeasureIdent,
				Value1,
				ValueCount
			)
			SELECT
				@bntMeasureIdent,
				Value1,
				ValueCount
			FROM
				dbo.ufnGetOptionListValueCount(@tblEntity, @bntQuestion1EntityProjectRequirementIdent)
			WHERE
				@bntEntitySearchDataTypeIdent = @bntEntitySearchDataTypeOptionsListIdent


			FETCH NEXT FROM measure_cursor
			INTO @bntMeasureIdent, @bntEntitySearchIdent, @bntEntitySearchDataTypeIdent, @bntQuestion1EntityProjectRequirementIdent, @bntQuestion2EntityProjectRequirementIdent

		END
		
	CLOSE measure_cursor
	DEALLOCATE measure_cursor

	-- rollup the entity totals for the final select
	-- we have a few scenarios
	-- 1. Numbers - Calculate the SUM for each question
	-- 2. Counts - Determine the COUNT of answered questions
	-- 3. Yes/No - Determine the COUNT of Yes answers
	-- 4. Options (Pie Chart) - Determine the COUNT of each answer
	INSERT INTO #tmpMeasureRollup(
		MeasureIdent,
		AvailableTotal,
		AnswerTotal,
		Value1,
		Value2
	)
	SELECT
		tE.MeasureIdent,
		COUNT(*),
		SUM(CAST(tE.Answered AS INT)),
		Value1 = CASE tM.EntitySearchDataTypeIdent
			WHEN 0 THEN COUNT(tE.AnswerValue)
			WHEN @bntEntitySearchDataTypeNumberIdent THEN SUM(TRY_CAST(tE.AnswerValue AS MONEY))
			WHEN @bntEntitySearchDataTypeOptionsListIdent THEN 0.0
			WHEN @bntEntitySearchDataTypeYesNoIdent THEN SUM(CASE tE.AnswerValue WHEN 'Yes' THEN 1 ELSE 0 END)
		END,
		Value2 = CASE tM.EntitySearchDataTypeIdent
			WHEN 0 THEN COUNT(tE.AnswerValue)
			WHEN @bntEntitySearchDataTypeNumberIdent THEN SUM(TRY_CAST(tE.AnswerValue AS MONEY))
			WHEN @bntEntitySearchDataTypeOptionsListIdent THEN 0.0
			WHEN @bntEntitySearchDataTypeYesNoIdent THEN COUNT(*)
		END
	FROM
		#tmpMeasures tM WITH (NOLOCK)
		INNER JOIN
		#tmpEntities tE WITH (NOLOCK)
			ON tM.Ident = tE.MeasureIdent
			AND tM.Question1EntityProjectRequirementIdent = tE.EntityProjectRequirementIdent
		LEFT OUTER JOIN
		#tmpEntities tEtwo WITH (NOLOCK)
			ON tM.Ident = tEtwo.MeasureIdent
			AND tM.Question2EntityProjectRequirementIdent = tEtwo.EntityProjectRequirementIdent
	GROUP BY
		tE.MeasureIdent,
		tM.EntitySearchDataTypeIdent

	-- final select - Measures
	SELECT
		EPM.Ident,
		EPM.EntityIdent,
		EPM.Name1,
		EPM.Desc1,
		EPM.EntitySearchIdent,
		MT.EntitySearchDataTypeIdent,
		MT.HasDenominator,
		MT.HasTargetValue,
		MT.IsAverage,
		MT.IsPercentage,
		EPM.MeasureTypeIdent,
		MT.Name1 AS [MeasureType],
		EP.Ident AS [EntityProject1Ident],
		EP.Name1 AS [EntityProject1Name],
		EPM.Question1EntityProjectRequirementIdent,
		EPR.RequirementTypeIdent AS [Question1RequirementTypeIdent],
		COALESCE(EPTWO.Ident,0) AS [EntityProject2Ident],
		COALESCE(EPTWO.Name1,'') AS [EntityProject2Name],
		EPM.Question2EntityProjectRequirementIdent,
		EPM.TargetValue,
		EPM.LastRecalculateDate,
		COALESCE(tMR.Value1, '0.0') as [Question1Value],
		COALESCE(tMR.Value2, '0.0') as [Question2Value],
		COALESCE(tMR.AnswerTotal, 0) AS [TotalResourcesComplete],
		tMR.AvailableTotal AS [TotalResourcesAvailable]
	FROM
		#tmpMeasures tM WITH (NOLOCK)
		INNER JOIN
		#tmpMeasureRollup tMR WITH (NOLOCK)
			 ON tMR.MeasureIdent = tM.Ident
		INNER JOIN
		EntityProjectMeasure EPM WITH (NOLOCK)
			ON EPM.Ident = tM.Ident
		INNER JOIN
		MeasureType MT WITH (NOLOCK)
			ON MT.Ident = EPM.MeasureTypeIdent
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.Ident = EPM.Question1EntityProjectRequirementIdent
		LEFT OUTER JOIN
		EntityProjectRequirement EPRTWO WITH (NOLOCK)
			ON EPRTWO.Ident = EPM.Question2EntityProjectRequirementIdent
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = EPR.EntityProjectIdent
		LEFT OUTER JOIN
		EntityProject EPTWO WITH (NOLOCK)
			ON EPTWO.Ident = EPRTWO.EntityProjectIdent
	ORDER BY
		EPM.Name1 ASC

	-- final select - Measure Ranges
	SELECT
		EPMR.Ident,
		EPMR.EntityProjectMeasureIdent,
		EPMR.Name1,
		EPMR.Color,
		EPMR.RangeStartValue,
		EPMR.RangeEndValue
	FROM
		#tmpMeasures tM WITH (NOLOCK)
		INNER JOIN
		EntityProjectMeasureRange EPMR WITH (NOLOCK)
			ON EPMR.EntityProjectMeasureIdent = tM.Ident
	WHERE
		EPMR.Active = 1
	ORDER BY
		EPMR.EntityProjectMeasureIdent ASC,
		EPMR.RangeStartValue ASC

	-- final select - Measure Location
	SELECT
		X.Ident,
		X.EntityProjectMeasureIdent,
		ML.Ident as [MeasureLocationIdent],
		ML.Name1 as [LocationName],
		X.Active
	FROM
		#tmpMeasures tM WITH (NOLOCK)
		INNER JOIN
		EntityProjectMeasureLocationXref X WITH (NOLOCK)
			ON X.EntityProjectMeasureIdent = tM.Ident
		INNER JOIN
		MeasureLocation ML WITH (NOLOCK)
			ON ML.Ident = X.MeasureLocationIdent
	ORDER BY
		X.EntityProjectMeasureIdent ASC

	-- final select - Measure Values
	SELECT
		tV.Ident,
		tV.EntityProjectMeasureIdent,
		tV.Value1,
		COALESCE(tV.ValueCount, 0) as [ValueCount]
	FROM
		#tmpMeasures tM WITH (NOLOCK)
		INNER JOIN
		#tmpValues tV WITH (NOLOCK)
			ON tV.EntityProjectMeasureIdent = tM.Ident
	WHERE
		COALESCE(tV.ValueCount, 0) > 0
	ORDER BY
		tV.EntityProjectMeasureIdent ASC,
		tV.ValueCount DESC
	
	DROP TABLE #tmpMeasures
	DROP TABLE #tmpEntityHierarchy
	DROP TABLE #tmpEntities
	DROP TABLE #tmpEntitySegment
	DROP TABLE #tmpMeasureRollup
	DROP TABLE #tmpValues

GO