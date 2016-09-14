IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveToDoStatus') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetAllActiveToDoStatus
 GO
/* uspGetAllActiveToDoStatus
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetAllActiveToDoStatus]

AS

	SET NOCOUNT ON

	SELECT 
		Ident, 
		Name1, 
		IconClass
	FROM
		ToDoStatus WITH (NOLOCK)
	WHERE
		Active = 1
GO