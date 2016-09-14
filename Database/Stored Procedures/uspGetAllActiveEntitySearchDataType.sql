IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveEntitySearchDataType') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetAllActiveEntitySearchDataType
 GO
/* uspGetAllActiveEntitySearchDataType
 *
 *
 *
 *
*/
CREATE PROCEDURE uspGetAllActiveEntitySearchDataType

AS

	SET NOCOUNT ON

	SELECT
		Ident,
		Name1,
		'' AS [OrderBy]
	FROM
		EntitySearchDataType WITH (NOLOCK)
	WHERE
		Ident = 0
	UNION ALL
	SELECT 
		Ident, 
		Name1,
		Name1 AS [OrderBy]
	FROM
		EntitySearchDataType WITH (NOLOCK)
	WHERE
		Active = 1
		AND Ident > 0
	ORDER BY
		[OrderBy] ASC

GO