IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityLanguage1XRef') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntityLanguage1XRef
 GO
/* uspAddEntityLanguage1XRef
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspAddEntityLanguage1XRef]

	@intEntityIdent BIGINT = 0, 
	@intLanguage1Ident BIGINT = 0, 
	@intAddASUserIdent BIGINT = 0, 
	@bitActive BIT = False

AS

	SET NOCOUNT ON

	INSERT INTO EntityLanguage1XRef (
		EntityIdent, 
		Language1Ident, 
		AddASUserIdent, 
		AddDateTime, 
		EditASUserIdent, 
		EditDateTime, 
		Active
	) 
	SELECT 
		EntityIdent = @intEntityIdent, 
		Language1Ident = @intLanguage1Ident, 
		AddASUserIdent = @intAddASUserIdent, 
		AddDateTime = dbo.ufnGetMyDate(), 
		EditASUserIdent = 0, 
		EditDateTime = '1/1/1900', 
		Active = @bitActive

	SELECT SCOPE_IDENTITY() AS [Ident]

GO