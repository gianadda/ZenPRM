IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityProjectAnswerValueStringByIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityProjectAnswerValueStringByIdent
GO

/* uspGetEntityProjectAnswerValueStringByIdent
 *
 * get a all answers to a question into one string
 *
 *
*/
CREATE PROCEDURE uspGetEntityProjectAnswerValueStringByIdent

	@bntEntityProjectRequirementIdent BIGINT,
	@bntASUserIdent BIGINT

AS

	SET NOCOUNT ON

	DECLARE @vcrAnswers VARCHAR(MAX) = ''

	SELECT 
		@vcrAnswers = @vcrAnswers + ' ' + CASE EPEAV.Name1
			WHEN '' THEN EPEAV.Value1
			ELSE EPEAV.Name1 + ': ' + EPEAV.Value1
		END
	FROM
		EntityProjectEntityAnswerValue EPEAV (NOLOCK)
		INNER JOIN
		EntityProjectEntityAnswer EPEA (NOLOCK)
			ON EPEAV.EntityProjectEntityAnswerIdent = EPEA.Ident
		INNER JOIN
		EntityProjectEntity EPE (NOLOCK)
			ON EPEA.EntityProjectEntityIdent = EPE.Ident
		INNER JOIN
		EntityProject EP (NOLOCK)
			ON EPE.EntityProjectIdent = EP.Ident
	WHERE 
		EPEA.EntityProjectRequirementIdent = @bntEntityProjectRequirementIdent
		AND (EPEAV.Name1 <> '' OR EPEAV.Value1 <> '')
		AND EP.EntityIdent = @bntASUserIdent
	
	SELECT REPLACE(REPLACE(REPLACE(@vcrAnswers, '"', ''''), '“', ''''), '”', '''') as Answers

GO

exec uspGetEntityProjectAnswerValueStringByIdent 2513, 306485

 