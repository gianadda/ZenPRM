IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityProjectMeasureByEntityProjectIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityProjectMeasureByEntityProjectIdent
GO

/* uspGetEntityProjectMeasureByEntityProjectIdent 306485, 306487, 2, 10118
 *
 *
 *
 *
*/
CREATE PROCEDURE uspGetEntityProjectMeasureByEntityProjectIdent

	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT,
	@bntMeasureLocationIdent BIGINT,
	@bntEntityProjectIdent BIGINT

AS

	SET NOCOUNT ON

	DECLARE @nvrOther NVARCHAR(5) = dbo.ufnGetEntityProjectMeasureOther()
	DECLARE @bntMeasureIdent BIGINT

	CREATE TABLE #tmpMeasuresToRecalculate(
		Ident BIGINT,
		Recalculate BIT,
		LastRecalculateDateTime DATETIME
	)

	INSERT INTO #tmpMeasuresToRecalculate(
		Ident,
		Recalculate,
		LastRecalculateDateTime
	)
	SELECT
		EPM.Ident,
		EPM.Recalculate,
		EPM.LastRecalculateDate
	FROM
		EntityProjectMeasure EPM WITH (NOLOCK)
		INNER JOIN
		EntityProjectRequirement EPRone WITH (NOLOCK)
			ON EPRone.Ident = EPM.Question1EntityProjectRequirementIdent
		LEFT OUTER JOIN
		EntityProjectRequirement EPRtwo WITH (NOLOCK)
			ON EPRone.Ident = EPM.Question2EntityProjectRequirementIdent
		INNER JOIN
		EntityProjectMeasureLocationXref X WITH (NOLOCK)
			ON X.EntityProjectMeasureIdent = EPM.Ident
	WHERE
		EPM.EntityIdent = @bntEntityIdent
		AND (EPRone.EntityProjectIdent = @bntEntityProjectIdent OR EPRtwo.EntityProjectIdent = @bntEntityProjectIdent)
		AND EPM.Active = 1
		AND X.MeasureLocationIdent = @bntMeasureLocationIdent
		AND X.Active = 1

	-- if measures need to be updated, we will do so before returning the data
	-- this shouldnt occur that often, but if it does, we dont want to return old/bad data
	DECLARE measureCalculator_cursor CURSOR FOR

	SELECT
		Ident
	FROM
		#tmpMeasuresToRecalculate
	WHERE
		Recalculate = 1

	OPEN measureCalculator_cursor

	FETCH NEXT FROM measureCalculator_cursor
	INTO @bntMeasureIdent
	
		WHILE @@FETCH_STATUS = 0
		BEGIN

			EXEC uspRecalculateEntityProjectMeasure @bntMeasureIdent, 1 -- supress output

			FETCH NEXT FROM measureCalculator_cursor
			INTO @bntMeasureIdent

		END

	CLOSE measureCalculator_cursor
	DEALLOCATE measureCalculator_cursor

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
		EPM.Question1Value,
		EPM.Question2Value,
		EPM.TotalResourcesComplete,
		EPM.TotalResourcesAvailable
	FROM
		#tmpMeasuresToRecalculate tM WITH (NOLOCK)
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
		#tmpMeasuresToRecalculate tM WITH (NOLOCK)
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
		#tmpMeasuresToRecalculate tM WITH (NOLOCK)
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
		EPMV.Ident,
		EPMV.EntityProjectMeasureIdent,
		EPMV.Value1,
		EPMV.ValueCount,
		CASE EPMV.Value1
			WHEN @nvrOther THEN -99999
			ELSE EPMV.ValueCount
		END AS [OrderWeight] -- use this to always put Other at the bottom of the list
	FROM
		#tmpMeasuresToRecalculate tM WITH (NOLOCK)
		INNER JOIN
		EntityProjectMeasureValue EPMV WITH (NOLOCK)
			ON EPMV.EntityProjectMeasureIdent = tM.Ident
	WHERE
		EPMV.Active = 1
	ORDER BY
		EPMV.EntityProjectMeasureIdent ASC,
		'OrderWeight' DESC
	
	DROP TABLE #tmpMeasuresToRecalculate

GO