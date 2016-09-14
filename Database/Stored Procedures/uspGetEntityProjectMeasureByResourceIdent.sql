IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityProjectMeasureByResourceIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityProjectMeasureByResourceIdent
GO

/* uspGetEntityProjectMeasureByResourceIdent 2, 306487, 3, 732418
 *
 *
 * Returns dials per resource
 *
*/
CREATE PROCEDURE uspGetEntityProjectMeasureByResourceIdent

	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT,
	@bntMeasureLocationIdent BIGINT,
	@bntResourceIdent BIGINT

AS

	SET NOCOUNT ON

	DECLARE @bntMeasureIdent BIGINT

	DECLARE @bntEntitySearchDataTypeNumberIdent BIGINT
	DECLARE @bntEntitySearchDataTypeOptionsListIdent BIGINT
	DECLARE @bntEntitySearchDataTypeYesNoIdent BIGINT

	SET @bntEntitySearchDataTypeNumberIdent = dbo.ufnEntitySearchDataTypeNumberIdent()
	SET @bntEntitySearchDataTypeOptionsListIdent = dbo.ufnEntitySearchDataTypeOptionsListIdent()
	SET @bntEntitySearchDataTypeYesNoIdent = dbo.ufnEntitySearchDataTypeYesNoIdent()

	/*** Entity Search Variables***/
	
	DECLARE @nvrEntityFullname NVARCHAR(MAX),
		@bntEntitySearchIdent BIGINT,
		@tblFilters [EntitySearchFilterTable],
		@tblEntity [EntitySearchOutput],
		@nvrKeyword NVARCHAR(MAX),
		@nvrLocation NVARCHAR(MAX),
		@decLatitude DECIMAL(20,8) = 0.0,
		@decLongitude DECIMAL(20,8) = 0.0,
		@intDistanceInMiles INT,
		@bitIsInSegment BIT

	CREATE TABLE #tmpMeasuresToDisplay(
		Ident BIGINT,
		EntitySearchDataTypeIdent BIGINT,
		Question1EntityProjectRequirementIdent BIGINT,
		Question2EntityProjectRequirementIdent BIGINT,
		EntityProjectEntityIdent1 BIGINT,
		EntityProjectEntityIdent2 BIGINT,
		Question1Value MONEY,
		Question2Value MONEY,
		ReturnOnResourceProfile BIT,
		EntitySearchIdent BIGINT,
		EntityIsInSegment BIT
	)

	CREATE TABLE #tmpValues(
		Ident BIGINT IDENTITY(1,1),
		EntityProjectMeasureIdent BIGINT,
		Value1 NVARCHAR(MAX),
		ValueCount BIGINT
	)

	-- find all the dials that the resource could be a part of and are set to display on the resource page
	INSERT INTO #tmpMeasuresToDisplay(
		Ident,
		EntitySearchDataTypeIdent,
		Question1EntityProjectRequirementIdent,
		Question2EntityProjectRequirementIdent,
		EntityProjectEntityIdent1,
		EntityProjectEntityIdent2,
		Question1Value,
		Question2Value,
		ReturnOnResourceProfile,
		EntitySearchIdent,
		EntityIsInSegment
	)
	SELECT
		EPM.Ident,
		MT.EntitySearchDataTypeIdent,
		EPM.Question1EntityProjectRequirementIdent,
		EPM.Question2EntityProjectRequirementIdent,
		0,
		0,
		0.0,
		0.0,
		0,
		EPM.EntitySearchIdent,
		0
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

	-- now figure out of they should be displayed 
	UPDATE
		tM
	SET
		EntityProjectEntityIdent1 = EPE.Ident
	FROM
		#tmpMeasuresToDisplay tM WITH (NOLOCK)
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.Ident = tM.Question1EntityProjectRequirementIdent
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityProjectIdent = EPR.EntityProjectIdent
			AND EPE.EntityIdent = @bntResourceIdent
	WHERE
		EPE.Active = 1

	UPDATE
		tM
	SET
		EntityProjectEntityIdent2 = EPE.Ident
	FROM
		#tmpMeasuresToDisplay tM WITH (NOLOCK)
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.Ident = tM.Question2EntityProjectRequirementIdent
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityProjectIdent = EPR.EntityProjectIdent
			AND EPE.EntityIdent = @bntResourceIdent
	WHERE
		tM.Question2EntityProjectRequirementIdent > 0
		AND EPE.Active = 1

	UPDATE
		#tmpMeasuresToDisplay
	SET
		ReturnOnResourceProfile = 1
	WHERE
		EntityProjectEntityIdent1 > 0
		AND (EntityProjectEntityIdent2 > 0 OR Question2EntityProjectRequirementIdent = 0)

	SELECT
		@nvrEntityFullname = Fullname
	FROM
		Entity WITH (NOLOCK)
	WHERE
		Ident = @bntResourceIdent

	-- now, if a measure was marked as return on profile, but there is a segment applied
	-- determine if this resource is in the segment prior to continuing
	-- we can group the segments by EntitySearchIdent, so if multiple measures utilize the same segment
	-- we can minimize effort
	DECLARE segment_cursor CURSOR FOR

		SELECT
			EntitySearchIdent
		FROM
			#tmpMeasuresToDisplay WITH (NOLOCK)
		WHERE
			ReturnOnResourceProfile = 1
			AND EntitySearchIdent > 0
		GROUP BY
			EntitySearchIdent

		OPEN segment_cursor
		
		FETCH NEXT FROM segment_cursor
		INTO @bntEntitySearchIdent

		WHILE @@FETCH_STATUS = 0
		BEGIN
	
			SET @bitIsInSegment = 0 -- reset value

			-- we're searching for an individual resource, so we should be able to
			-- limit the result set to this entities' record by filtering by their name
			SET @nvrKeyword = @nvrEntityFullname

			SELECT
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

			-- if this entity record is found in the result set, then mark them as in the segment
			SELECT
				@bitIsInSegment = 1
			FROM
				@tblEntity
			WHERE
				EntityIdent = @bntResourceIdent

			-- and reflect the changes in the measure list
			UPDATE
				#tmpMeasuresToDisplay
			SET
				EntityIsInSegment = @bitIsInSegment
			WHERE
				EntitySearchIdent = @bntEntitySearchIdent

			DELETE @tblFilters
			DELETE @tblEntity
		
			FETCH NEXT FROM segment_cursor
			INTO @bntEntitySearchIdent

		END
		
	CLOSE segment_cursor
	DEALLOCATE segment_cursor

	-- now, for any of the measures that were marked as return on resource profile
	-- that are no longer valid since the resource is outside the segment,
	-- lets mark them as NOT return on profile
	UPDATE
		#tmpMeasuresToDisplay
	SET
		ReturnOnResourceProfile = 0
	WHERE
		ReturnOnResourceProfile = 1
		AND EntitySearchIdent > 0
		AND EntityIsInSegment = 0

	-- now get the resources values, if applicable
	UPDATE
		tM
	SET
		Question1Value = CASE EntitySearchDataTypeIdent
			WHEN 0 THEN 1 -- the count
			WHEN @bntEntitySearchDataTypeNumberIdent THEN TRY_CAST(V.Value1 AS MONEY)
			WHEN @bntEntitySearchDataTypeOptionsListIdent THEN 0.0
			WHEN @bntEntitySearchDataTypeYesNoIdent THEN CASE V.Value1 WHEN 'Yes' THEN 1 ELSE 0 END
		END,
		Question2Value = CASE EntitySearchDataTypeIdent
			WHEN 0 THEN 1
			WHEN @bntEntitySearchDataTypeYesNoIdent THEN 1
			ELSE Question2Value
		END
	FROM
		#tmpMeasuresToDisplay tM WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntityAnswer A WITH (NOLOCK)
			ON A.EntityProjectRequirementIdent = tM.Question1EntityProjectRequirementIdent
			AND A.EntityProjectEntityIdent = tM.EntityProjectEntityIdent1
		INNER JOIN
		EntityProjectEntityAnswerValue V WITH (NOLOCK)
			ON V.EntityProjectEntityAnswerIdent = A.Ident
	WHERE
		tM.ReturnOnResourceProfile = 1
		AND tM.EntityProjectEntityIdent1 > 0
		AND A.Active = 1
		AND V.Active = 1

	UPDATE
		tM
	SET
		Question2Value = COALESCE(TRY_CAST(V.Value1 AS MONEY),0.0)
	FROM
		#tmpMeasuresToDisplay tM WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntityAnswer A WITH (NOLOCK)
			ON A.EntityProjectRequirementIdent = tM.Question2EntityProjectRequirementIdent
			AND A.EntityProjectEntityIdent = tM.EntityProjectEntityIdent2
		INNER JOIN
		EntityProjectEntityAnswerValue V WITH (NOLOCK)
			ON V.EntityProjectEntityAnswerIdent = A.Ident
	WHERE
		tM.ReturnOnResourceProfile = 1
		AND tM.Question2EntityProjectRequirementIdent > 0
		AND tM.EntityProjectEntityIdent2 > 0
		AND tM.EntitySearchDataTypeIdent = @bntEntitySearchDataTypeNumberIdent
		AND A.Active = 1
		AND V.Active = 1

	
	-- for check box lists and tags (multiple answers allowed), get all the selected answers
	INSERT INTO #tmpValues(
		EntityProjectMeasureIdent,
		Value1,
		ValueCount
	)
	SELECT
		tM.Ident,
		Value1 = V.Name1,
		ValueCount = COUNT(*)
	FROM
		EntityProjectEntityAnswerValue V WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntityAnswer A WITH (NOLOCK)
			ON A.Ident = V.EntityProjectEntityAnswerIdent
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.Ident = A.EntityProjectEntityIdent
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.Ident = A.EntityProjectRequirementIdent
		INNER JOIN
		#tmpMeasuresToDisplay tM WITH (NOLOCK)
			ON tM.Question1EntityProjectRequirementIdent = A.EntityProjectRequirementIdent
		INNER JOIN
		RequirementType RT WITH (NOLOCK)
			ON RT.Ident = EPR.RequirementTypeIdent
	WHERE
		tM.ReturnOnResourceProfile = 1
		AND tM.EntitySearchDataTypeIdent = @bntEntitySearchDataTypeOptionsListIdent
		AND V.Active = 1
		AND UPPER(V.Value1) = 'TRUE'
		AND A.Active = 1
		AND EPE.EntityIdent = @bntResourceIdent
		AND EPE.Active = 1
		AND RT.AllowMultipleOptions = 1
	GROUP BY
		tM.Ident,
		V.Name1

	-- otherwise, get the selected option for the other questions
	INSERT INTO #tmpValues(
		EntityProjectMeasureIdent,
		Value1,
		ValueCount
	)
	SELECT
		tM.Ident,
		Value1 = V.Value1,
		ValueCount = COUNT(*)
	FROM
		EntityProjectEntityAnswerValue V WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntityAnswer A WITH (NOLOCK)
			ON A.Ident = V.EntityProjectEntityAnswerIdent
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.Ident = A.EntityProjectEntityIdent
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.Ident = A.EntityProjectRequirementIdent
		INNER JOIN
		#tmpMeasuresToDisplay tM WITH (NOLOCK)
			ON tM.Question1EntityProjectRequirementIdent = A.EntityProjectRequirementIdent
		INNER JOIN
		RequirementType RT WITH (NOLOCK)
			ON RT.Ident = EPR.RequirementTypeIdent
	WHERE
		tM.ReturnOnResourceProfile = 1
		AND tM.EntitySearchDataTypeIdent = @bntEntitySearchDataTypeOptionsListIdent
		AND V.Active = 1
		AND A.Active = 1
		AND EPE.EntityIdent = @bntResourceIdent
		AND EPE.Active = 1
		AND RT.AllowMultipleOptions = 0
	GROUP BY
		tM.Ident,
		V.Value1

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
		tM.Question1Value,
		tM.Question2Value,
		0 AS [TotalResourcesComplete],
		0 AS [TotalResourcesAvailable]
	FROM
		#tmpMeasuresToDisplay tM WITH (NOLOCK)
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
	WHERE
		tM.ReturnOnResourceProfile = 1
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
		#tmpMeasuresToDisplay tM WITH (NOLOCK)
		INNER JOIN
		EntityProjectMeasureRange EPMR WITH (NOLOCK)
			ON EPMR.EntityProjectMeasureIdent = tM.Ident
	WHERE
		tM.ReturnOnResourceProfile = 1
		AND EPMR.Active = 1
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
		#tmpMeasuresToDisplay tM WITH (NOLOCK)
		INNER JOIN
		EntityProjectMeasureLocationXref X WITH (NOLOCK)
			ON X.EntityProjectMeasureIdent = tM.Ident
		INNER JOIN
		MeasureLocation ML WITH (NOLOCK)
			ON ML.Ident = X.MeasureLocationIdent
	WHERE
		tM.ReturnOnResourceProfile = 1
	ORDER BY
		X.EntityProjectMeasureIdent ASC

	-- final select - Measure Values
	SELECT
		tV.Ident,
		tV.EntityProjectMeasureIdent,
		tV.Value1,
		tV.ValueCount
	FROM
		#tmpMeasuresToDisplay tM WITH (NOLOCK)
		INNER JOIN
		#tmpValues tV WITH (NOLOCK)
			ON tV.EntityProjectMeasureIdent = tM.Ident
	WHERE
		tM.ReturnOnResourceProfile = 1
	ORDER BY
		tV.EntityProjectMeasureIdent ASC,
		tV.Value1 ASC
	
	DROP TABLE #tmpMeasuresToDisplay
	DROP TABLE #tmpValues

GO