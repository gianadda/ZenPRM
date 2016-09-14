IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveActivityTypeGroup') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetAllActiveActivityTypeGroup
 GO
/* uspGetAllActiveActivityTypeGroup
 *
 *
 *
 *
*/
CREATE PROCEDURE uspGetAllActiveActivityTypeGroup

AS

	SET NOCOUNT ON

	SELECT
		0 as [Ident],
		'(All)' as [Name1]
	UNION ALL
	SELECT 
		Ident, 
		Name1
	FROM
		ActivityTypeGroup WITH (NOLOCK)
	WHERE
		Active = 1
	ORDER BY 
		Name1 ASC
GO