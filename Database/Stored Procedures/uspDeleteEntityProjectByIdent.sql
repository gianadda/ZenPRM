IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspDeleteEntityProjectByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspDeleteEntityProjectByIdent
 GO
/* uspDeleteEntityProjectByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspDeleteEntityProjectByIdent]

	@intIdent BIGINT,
	@intEntityIdent BIGINT,
	@intEditASUserIdent BIGINT

AS

	SET NOCOUNT ON
	
	UPDATE EntityProject
	SET 
		EditASUserIdent = @intEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate(),
		Active = 0
	WHERE
		Ident = @intIdent
		AND EntityIdent = @intEntityIdent -- ensure that the user has access to this project
		
GO