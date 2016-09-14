IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveToDoInitiatorType') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetAllActiveToDoInitiatorType
 GO
/* uspGetAllActiveToDoInitiatorType
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetAllActiveToDoInitiatorType]

AS

	SET NOCOUNT ON

	SELECT 
		Ident, 
		Name1, 
		IconClass
	FROM
		ToDoInitiatorType WITH (NOLOCK)
	WHERE
		Active = 1
GO