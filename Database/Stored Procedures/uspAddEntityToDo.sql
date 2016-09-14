IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityToDo') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntityToDo
 GO
/* uspAddEntityToDo
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspAddEntityToDo]

	@intEntityIdent BIGINT = 0, 
	@intToDoInitiatorTypeIdent BIGINT = 0, 
	@intToDoTypeIdent BIGINT = 0, 
	@intToDoStatusIdent BIGINT = 0, 
	@intRegardingEntityIdent BIGINT = 0, 
	@intAssigneeEntityIdent BIGINT = 0, 
	@nvrTitle NVARCHAR(MAX) = '', 
	@nvrDesc1 NVARCHAR(MAX) = '', 
	@sdtStartDate SMALLDATETIME = '1/1/1900', 
	@sdtDueDate SMALLDATETIME = '1/1/1900', 
	@intAddASUserIdent BIGINT = 0, 
	@bitActive BIT = 1

AS

	SET NOCOUNT ON

	IF @sdtStartDate = '1/1/1900'
	BEGIN
		SET @sdtStartDate = dbo.ufnGetMyDate()
	END

	INSERT INTO EntityToDo (
		EntityIdent,
		ToDoInitiatorTypeIdent,
		ToDoTypeIdent,
		ToDoStatusIdent,
		RegardingEntityIdent,
		AssigneeEntityIdent,
		Title,
		Desc1,
		StartDate,
		DueDate,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	) 
	SELECT 
		EntityIdent = @intEntityIdent, 
		ToDoInitiatorTypeIdent = @intToDoInitiatorTypeIdent,
		ToDoTypeIdent = @intToDoTypeIdent, 
		ToDoStatusIdent = @intToDoStatusIdent,
		RegardingEntityIdent = @intRegardingEntityIdent,
		AssigneeEntityIdent = @intAssigneeEntityIdent,
		Title = @nvrTitle, 
		Desc1 = @nvrDesc1, 
		StartDate = @sdtStartDate,
		DueDate = @sdtDueDate, 
		AddASUserIdent = @intAddASUserIdent, 
		AddDateTime = dbo.ufnGetMyDate(), 
		EditASUserIdent = 0, 
		EditDateTime = '1/1/1900', 
		Active = @bitActive

	SELECT SCOPE_IDENTITY() As [Ident]

GO