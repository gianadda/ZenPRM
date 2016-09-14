IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityServices1XRef') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntityServices1XRef
 GO
/* uspAddEntityServices1XRef
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspAddEntityServices1XRef]

	@intEntityIdent BIGINT = 0, 
	@intServices1Ident BIGINT = 0, 
	@intAddASUserIdent BIGINT = 0, 
	@bitActive BIT = False

AS

	SET NOCOUNT ON

	INSERT INTO EntityServices1XRef (
		EntityIdent, 
		Services1Ident, 
		AddASUserIdent, 
		AddDateTime, 
		EditASUserIdent, 
		EditDateTime, 
		Active
	) 
	SELECT 
		EntityIdent = @intEntityIdent, 
		Services1Ident = @intServices1Ident, 
		AddASUserIdent = @intAddASUserIdent, 
		AddDateTime = dbo.ufnGetMyDate(), 
		EditASUserIdent = 0, 
		EditDateTime = '1/1/1900', 
		Active = @bitActive

	SELECT SCOPE_IDENTITY() AS [Ident]

GO
GO