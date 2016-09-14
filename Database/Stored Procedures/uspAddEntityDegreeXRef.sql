IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityDegreeXRef') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntityDegreeXRef
 GO
/* uspAddEntityDegreeXRef
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspAddEntityDegreeXRef]

	@intEntityIdent BIGINT = 0, 
	@intDegreeIdent BIGINT = 0, 
	@intAddASUserIdent BIGINT = 0, 
	@bitActive BIT = False

AS

	SET NOCOUNT ON

	INSERT INTO EntityDegreeXRef (
		EntityIdent, 
		DegreeIdent, 
		AddASUserIdent, 
		AddDateTime, 
		EditASUserIdent, 
		EditDateTime, 
		Active
	) 
	SELECT 
		EntityIdent = @intEntityIdent, 
		DegreeIdent = @intDegreeIdent, 
		AddASUserIdent = @intAddASUserIdent, 
		AddDateTime = dbo.ufnGetMyDate(), 
		EditASUserIdent = 0, 
		EditDateTime = '1/1/1900', 
		Active = @bitActive

	SELECT SCOPE_IDENTITY() AS [Ident]

GO