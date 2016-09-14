IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityToDoComment') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntityToDoComment
 GO
/* uspAddEntityToDoComment
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspAddEntityToDoComment]

	@intEntityToDoIdent BIGINT = 0, 
	@nvrCommentText NVARCHAR(MAX) , 
	@intAddASUserIdent BIGINT = 0, 
	@bitActive BIT = False

AS

	SET NOCOUNT ON
	
	INSERT INTO EntityToDoComment (
		EntityToDoIdent,
		CommentText,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	) 
	SELECT 
		EntityToDoIdent = @intEntityToDoIdent,
		CommentText = @nvrCommentText,
		AddASUserIdent = @intAddASUserIdent, 
		AddDateTime = dbo.ufnGetMyDate(), 
		EditASUserIdent = 0, 
		EditDateTime = '1/1/1900', 
		Active = @bitActive


	SELECT SCOPE_IDENTITY() as [Ident]

GO