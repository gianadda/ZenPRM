IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetEntityProjectMeasureEntities') 
	AND OBJECTPROPERTY(id, N'IsTableFunction') = 1)
DROP FUNCTION ufnGetEntityProjectMeasureEntities
GO

/* ufnGetEntityProjectMeasureEntities
 *
 *  Gets the list of entities and answers based on the measure and its filters
 *
 *
*/
CREATE FUNCTION ufnGetEntityProjectMeasureEntities(@bntQuestion1EntityProjectRequirementIdent BIGINT, @bntQuestion2EntityProjectRequirementIdent BIGINT, @tblEntity AS [EntitySearchOutput] READONLY)
RETURNS @tblResults TABLE
	(
		EntityIdent BIGINT,
		EntityProjectEntityIdent BIGINT,
		EntityProjectRequirementIdent BIGINT,
		EntityProjectEntityAnswerIdent BIGINT,
		Answered BIT,
		AnswerValue NVARCHAR(MAX)
	)
AS

	BEGIN

		DECLARE @bntQuestion1EntityProjectIdent BIGINT,
				@bntQuestion2EntityProjectIdent BIGINT,
				@bntFilteredEntityCount BIGINT

		SELECT
			@bntFilteredEntityCount = COUNT(*)
		FROM
			@tblEntity

		-- and figure out the requirement / project info
		SELECT
			@bntQuestion1EntityProjectIdent = EPR.EntityProjectIdent
		FROM
			EntityProjectRequirement EPR WITH (NOLOCK)
		WHERE
			EPR.Ident = @bntQuestion1EntityProjectRequirementIdent
		
		SELECT
			@bntQuestion2EntityProjectIdent = EPR.EntityProjectIdent
		FROM
			EntityProjectRequirement EPR WITH (NOLOCK)
		WHERE
			EPR.Ident = @bntQuestion2EntityProjectRequirementIdent

		/**********************

			SCENARIO 1 - All measure entities, no segments

		**********************/
		IF (@bntFilteredEntityCount = 0)
			BEGIN

				INSERT INTO @tblResults(
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
					dbo.ufnGetEntityProjectRequirementAnswerByIdent(@bntQuestion1EntityProjectIdent, @bntQuestion1EntityProjectRequirementIdent)
				UNION ALL
				SELECT
					EntityIdent,
					EntityProjectEntityIdent,
					EntityProjectRequirementIdent,
					EntityProjectEntityAnswerIdent,
					Answered,
					AnswerValue	
				FROM
					dbo.ufnGetEntityProjectRequirementAnswerByIdent(@bntQuestion2EntityProjectIdent, @bntQuestion2EntityProjectRequirementIdent)
				WHERE
					@bntQuestion2EntityProjectRequirementIdent > 0

			END

		
		/**********************

			SCENARIO 2 - All measure entities, but the measure has a segment

		**********************/
		IF (@bntFilteredEntityCount > 0)
			BEGIN

				INSERT INTO @tblResults(
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
					dbo.ufnGetEntityProjectRequirementAnswerByIdentSubset(@tblEntity, @bntQuestion1EntityProjectIdent, @bntQuestion1EntityProjectRequirementIdent)
				UNION ALL
				SELECT
					EntityIdent,
					EntityProjectEntityIdent,
					EntityProjectRequirementIdent,
					EntityProjectEntityAnswerIdent,
					Answered,
					AnswerValue	
				FROM
					dbo.ufnGetEntityProjectRequirementAnswerByIdentSubset(@tblEntity, @bntQuestion2EntityProjectIdent, @bntQuestion2EntityProjectRequirementIdent)
				WHERE
					@bntQuestion2EntityProjectRequirementIdent > 0

			END

	RETURN

	END

GO
