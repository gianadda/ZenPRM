IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspEditEntityToDoCommentByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspEditEntityToDoCommentByIdent
 GO
/* uspEditEntityToDoCommentByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspEditEntityToDoCommentByIdent]

	@intIdent BIGINT, 
	@nvrCommentText NVARCHAR(MAX) , 
	@intEditASUserIdent BIGINT, 
	@bitActive BIT

AS

	SET NOCOUNT ON

	UPDATE EditEntityToDoComment
	SET 
		CommentText = @nvrCommentText, 
		EditASUserIdent = @intEditASUserIdent, 
		EditDateTime = dbo.ufnGetMyDate(), 
		Active = @bitActive
	WHERE
		Ident = @intIdent
GO