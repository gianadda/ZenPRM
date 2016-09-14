IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspSaveEntityProjectEntityAnswerValueValidateOptions') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspSaveEntityProjectEntityAnswerValueValidateOptions
 GO
/* uspSaveEntityProjectEntityAnswerValueValidateOptions
 *
 * Once we've saved all the options to the database, lets confirm with onces are "no longer" selected, and deactivate
 *
 *
*/
CREATE PROCEDURE uspSaveEntityProjectEntityAnswerValueValidateOptions

	@intEntityIdent BIGINT,
	@intEntityProjectRequirementIdent BIGINT,
	@intASUserIdent BIGINT,
	@nvrSelectedOptions NVARCHAR(MAX)

AS

	SET NOCOUNT ON

	DECLARE @nvrOptions NVARCHAR(MAX)
	DECLARE @bitAllowMultipleOptions BIT
	
	CREATE TABLE #tmpSelectedOptions(
		OptionValue NVARCHAR(MAX)
	)
	CREATE TABLE #tmpOptions(
		OptionValue NVARCHAR(MAX),
		CurrentlySelected BIT
	)

	SELECT
		@nvrOptions = EPR.Options,
		@bitAllowMultipleOptions = RT.AllowMultipleOptions
	FROM
		EntityProjectRequirement EPR WITH (NOLOCK)
		INNER JOIN
		RequirementType RT WITH (NOLOCK)
			ON RT.Ident = EPR.RequirementTypeIdent
	WHERE
		EPR.Ident = @intEntityProjectRequirementIdent

	-- make sure this is a question type we want to do this for
	IF (@bitAllowMultipleOptions = 1)
		BEGIN

			INSERT INTO #tmpSelectedOptions(
				OptionValue
			)
			SELECT
				LTRIM(RTRIM([Value]))
			FROM
				dbo.ufnSplitString(@nvrSelectedOptions, '|')
			WHERE
				LTRIM(RTRIM([Value])) <> ''

			INSERT INTO #tmpOptions(
				OptionValue,
				CurrentlySelected
			)
			SELECT
				LTRIM(RTRIM([Value])),
				0
			FROM
				dbo.ufnSplitString(@nvrOptions, '|')
			WHERE
				LTRIM(RTRIM([Value])) <> ''

			UPDATE
				tmpO
			SET
				CurrentlySelected = 1
			FROM
				#tmpOptions tmpO WITH (NOLOCK)
				INNER JOIN
				#tmpSelectedOptions tSO WITH (NOLOCK)
					ON tSO.OptionValue = tmpO.OptionValue

			UPDATE
				V
			SET
				Active = 0,
				Value1 = CASE V.Value1
							WHEN 'True' THEN 'False'
							ELSE V.Value1
						END,
				EditASUserIdent = @intASUserIdent,
				EditDateTime = dbo.ufnGetMyDate()
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
					AND EPR.EntityProjectIdent = EPE.EntityProjectIdent
				INNER JOIN
				#tmpOptions tmpO WITH (NOLOCK)
					ON (tmpO.OptionValue = V.Value1 AND V.Name1 = ''
							OR (tmpO.OptionValue = V.Name1 AND UPPER(V.Value1) = 'TRUE'))
			WHERE
				EPR.Ident = @intEntityProjectRequirementIdent
				AND EPE.EntityIdent = @intEntityIdent
				AND EPE.Active = 1
				AND A.Active = 1
				AND V.Active = 1
				AND tmpO.CurrentlySelected = 0

		END
		
	DROP TABLE #tmpOptions
	DROP TABLE #tmpSelectedOptions

GO