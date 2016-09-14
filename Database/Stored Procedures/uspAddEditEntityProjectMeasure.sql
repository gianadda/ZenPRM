IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEditEntityProjectMeasure') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspAddEditEntityProjectMeasure
GO
/* uspAddEditEntityProjectMeasure
 *
 *	Adds or Updates the Entity Project Measure
 *
 */
CREATE PROCEDURE uspAddEditEntityProjectMeasure

	@bntIdent BIGINT,
	@bntASUserIdent BIGINT,
	@bntEntityIdent BIGINT,
	@nvrName1 NVARCHAR(MAX),
	@nvrDesc1 NVARCHAR(MAX),
	@bntEntitySearchIdent BIGINT,
	@bntMeasureTypeIdent BIGINT,
	@bntQuestion1EntityProjectRequirementIdent BIGINT,
	@bntQuestion2EntityProjectRequirementIdent BIGINT,
	@decTargetValue MONEY,
	@tblRanges [EntityProjectMeasureRangeTable] READONLY,
	@tblLocation [EntityProjectMeasureLocationTable] READONLY

AS

	SET NOCOUNT ON

	DECLARE @bntEntityProjectIdent1 BIGINT
	DECLARE @bntEntityProjectIdent2 BIGINT

	SET @bntEntityProjectIdent1 = 0
	SET @bntEntityProjectIdent2 = 0

	IF (@bntIdent = 0)  -- only add the record if it doesnt exist

		BEGIN

			-- make sure the user has access to track these questions
			SELECT
				@bntEntityProjectIdent1 = EP.Ident
			FROM
				EntityProjectRequirement EPR WITH (NOLOCK)
				INNER JOIN
				EntityProject EP WITH (NOLOCK)
					ON EP.Ident = EPR.EntityProjectIdent
			WHERE
				EPR.Ident = @bntQuestion1EntityProjectRequirementIdent
				AND EP.EntityIdent = @bntEntityIdent

			-- make sure the user has access to track these questions
			SELECT
				@bntEntityProjectIdent2 = EP.Ident
			FROM
				EntityProjectRequirement EPR WITH (NOLOCK)
				INNER JOIN
				EntityProject EP WITH (NOLOCK)
					ON EP.Ident = EPR.EntityProjectIdent
			WHERE
				@bntQuestion2EntityProjectRequirementIdent > 0
				AND EPR.Ident = @bntQuestion2EntityProjectRequirementIdent
				AND EP.EntityIdent = @bntEntityIdent

			INSERT INTO EntityProjectMeasure(
				EntityIdent,
				Name1,
				Desc1,
				EntitySearchIdent,
				MeasureTypeIdent,
				Question1EntityProjectRequirementIdent,
				Question2EntityProjectRequirementIdent,
				TargetValue,
				AddASUserIdent,
				AddDateTime,
				EditASUserIdent,
				EditDateTime,
				Active,
				Recalculate,
				LastRecalculateDate,
				Question1Value,
				Question2Value,
				TotalResourcesComplete,
				TotalResourcesAvailable
			)
			SELECT
				EntityIdent = @bntEntityIdent,
				Name1 = @nvrName1,
				Desc1 = @nvrDesc1,
				EntitySearchIdent = @bntEntitySearchIdent,
				MeasureTypeIdent = @bntMeasureTypeIdent,
				Question1EntityProjectRequirementIdent = @bntQuestion1EntityProjectRequirementIdent,
				Question2EntityProjectRequirementIdent = @bntQuestion2EntityProjectRequirementIdent,
				TargetValue = @decTargetValue,
				AddASUserIdent = @bntASUserIdent,
				AddDateTime = dbo.ufnGetMyDate(),
				EditASUserIdent = 0,
				EditDateTime = '1/1/1900',
				Active = 1,
				Recalculate = 1, -- need to default to recalc on add
				LastRecalculateDate = '1/1/1900',
				Question1Value = 0.0,
				Question2Value = 0.0,
				TotalResourcesComplete = 0,
				TotalResourcesAvailable = 0
			WHERE
				@bntEntityProjectIdent1 > 0
				AND (@bntEntityProjectIdent2 > 0 OR @bntQuestion2EntityProjectRequirementIdent = 0) -- project Ident 2 wont be > 0 if there is no Q2

			SET @bntIdent = SCOPE_IDENTITY()

			INSERT INTO EntityProjectMeasureRange(
				EntityProjectMeasureIdent,
				Name1,
				Color,
				RangeStartValue,
				RangeEndValue,
				AddASUserIdent,
				AddDateTime,
				EditASUserIdent,
				EditDateTime,
				Active
			)
			SELECT
				EntityProjectMeasureIdent = @bntIdent,
				Name1 = tR.Name1,
				Color = tR.Color,
				RangeStartValue = tR.RangeStartValue,
				RangeEndValue = tR.RangeEndValue,
				AddASUserIdent = @bntASUserIdent,
				AddDateTime = dbo.ufnGetMyDate(),
				EditASUserIdent = 0,
				EditDateTime = '1/1/1900',
				Active = 1
			FROM
				@tblRanges tR
			WHERE
				@bntIdent > 0

			INSERT INTO EntityProjectMeasureLocationXref(
				EntityProjectMeasureIdent,
				MeasureLocationIdent,
				AddASUserIdent,
				AddDateTime,
				EditASUserIdent,
				EditDateTime,
				Active
			)
			SELECT
				EntityProjectMeasureIdent = @bntIdent,
				MeasureLocationIdent = tL.MeasureLocationIdent,
				AddASUserIdent = @bntASUserIdent,
				AddDateTime = dbo.ufnGetMyDate(),
				EditASUserIdent = 0,
				EditDateTime = '1/1/1900',
				Active = tL.Selected
			FROM
				@tblLocation tL
			WHERE
				@bntIdent > 0
				
		END

	ELSE

		BEGIN
		
			-- make sure the user has access to track these questions
			SELECT
				@bntEntityProjectIdent1 = EP.Ident
			FROM
				EntityProjectRequirement EPR WITH (NOLOCK)
				INNER JOIN
				EntityProject EP WITH (NOLOCK)
					ON EP.Ident = EPR.EntityProjectIdent
			WHERE
				EPR.Ident = @bntQuestion1EntityProjectRequirementIdent
				AND EP.EntityIdent = @bntEntityIdent

			-- make sure the user has access to track these questions
			SELECT
				@bntEntityProjectIdent2 = EP.Ident
			FROM
				EntityProjectRequirement EPR WITH (NOLOCK)
				INNER JOIN
				EntityProject EP WITH (NOLOCK)
					ON EP.Ident = EPR.EntityProjectIdent
			WHERE
				@bntQuestion2EntityProjectRequirementIdent > 0
				AND EPR.Ident = @bntQuestion2EntityProjectRequirementIdent
				AND EP.EntityIdent = @bntEntityIdent

			-- make sure the requirement idents are accessible by this user, otherwise dont update
			IF (@bntEntityProjectIdent1 = 0) AND (@bntEntityProjectIdent2 = 0 AND @bntQuestion2EntityProjectRequirementIdent > 0)
				BEGIN
					SET @bntIdent = 0
				END
			
			UPDATE
				EntityProjectMeasure
			SET
				Name1 = @nvrName1,
				Desc1 = @nvrDesc1,
				EntitySearchIdent = @bntEntitySearchIdent,
				MeasureTypeIdent = @bntMeasureTypeIdent,
				Question1EntityProjectRequirementIdent = @bntQuestion1EntityProjectRequirementIdent,
				Question2EntityProjectRequirementIdent = @bntQuestion2EntityProjectRequirementIdent,
				TargetValue = @decTargetValue,
				EditASUserIdent = @bntASUserIdent,
				EditDateTime = dbo.ufnGetMyDate(),
				Recalculate = 1 -- and force the recalculate
			WHERE
				@bntIdent > 0
				AND Ident = @bntIdent
				AND EntityIdent = @bntEntityIdent

			UPDATE
				EntityProjectMeasureRange
			SET
				Active = 0,
				EditASUserIdent = @bntASUserIdent,
				EditDateTime = dbo.ufnGetMyDate()
			WHERE
				@bntIdent > 0
				AND EntityProjectMeasureIdent = @bntIdent
				AND Active = 1

			-- just purge and resave
			INSERT INTO EntityProjectMeasureRange(
				EntityProjectMeasureIdent,
				Name1,
				Color,
				RangeStartValue,
				RangeEndValue,
				AddASUserIdent,
				AddDateTime,
				EditASUserIdent,
				EditDateTime,
				Active
			)
			SELECT
				EntityProjectMeasureIdent = @bntIdent,
				Name1 = tR.Name1,
				Color = tR.Color,
				RangeStartValue = tR.RangeStartValue,
				RangeEndValue = tR.RangeEndValue,
				AddASUserIdent = @bntASUserIdent,
				AddDateTime = dbo.ufnGetMyDate(),
				EditASUserIdent = 0,
				EditDateTime = '1/1/1900',
				Active = 1
			FROM
				@tblRanges tR
			WHERE
				@bntIdent > 0

			UPDATE
				X
			SET
				Active = tL.Selected,
				EditASUserIdent = @bntASUserIdent,
				EditDateTime = dbo.ufnGetMyDate()
			FROM
				@tblLocation tL
				INNER JOIN
				EntityProjectMeasureLocationXref X WITH (NOLOCK)
					ON X.Ident = tL.Ident
					AND X.EntityProjectMeasureIdent = tL.EntityProjectMeasureIdent
					AND X.MeasureLocationIdent = tL.MeasureLocationIdent
			WHERE
				@bntIdent > 0

		END


	SELECT COALESCE(@bntIdent, 0) as [Ident] -- returns edited record or new row ident

GO