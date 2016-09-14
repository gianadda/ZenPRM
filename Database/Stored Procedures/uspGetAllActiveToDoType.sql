IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveToDoType') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetAllActiveToDoType
 GO
/* uspGetAllActiveToDoType
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetAllActiveToDoType]

AS

	SET NOCOUNT ON

	SELECT 
		Ident, 
		Name1, 
		IconClass
	FROM
		ToDoType WITH (NOLOCK)
	WHERE
		Active = 1
	ORDER BY
		SortOrder

GO