IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspCompleteEntityToDoByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspCompleteEntityToDoByIdent
 GO
/* uspCompleteEntityToDoByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspCompleteEntityToDoByIdent]

	@intIdent BIGINT, 
	@bitCompleted BIT, 
	@intCompletedASUserIdent BIGINT

AS

	SET NOCOUNT ON

	UPDATE EntityToDo
	SET 
		Completed = @bitCompleted, 
		CompletedASUserIdent = @intCompletedASUserIdent, 
		CompletedDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = @intCompletedASUserIdent, 
		EditDateTime = dbo.ufnGetMyDate()
	WHERE
		Ident = @intIdent

	SELECT @intIdent as [Ident]
GO