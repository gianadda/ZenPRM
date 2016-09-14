IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveEntitySearchOperator') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetAllActiveEntitySearchOperator
 GO
/* uspGetAllActiveEntitySearchOperator
 *
 *
 *
 *
*/
CREATE PROCEDURE uspGetAllActiveEntitySearchOperator

AS

	SET NOCOUNT ON

	SELECT
		Ident,
		EntitySearchDataTypeIdent,
		Name1,
		ShowProjectQuestionFilter
	FROM
		EntitySearchOperator WITH (NOLOCK)
	WHERE
		Active = 1
	ORDER BY
		EntitySearchDataTypeIdent ASC,
		CheckIfEntityOnProject DESC,
		CheckIfAnswerComplete DESC,
		CheckIfAnswerNULL DESC,
		Name1 ASC

GO