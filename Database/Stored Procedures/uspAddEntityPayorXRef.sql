IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityPayorXRef') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntityPayorXRef
 GO
/* uspAddEntityPayorXRef
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspAddEntityPayorXRef]

	@intEntityIdent BIGINT = 0, 
	@intPayorIdent BIGINT = 0, 
	@intAddASUserIdent BIGINT = 0, 
	@bitActive BIT = False

AS

	SET NOCOUNT ON

	INSERT INTO EntityPayorXRef (
		EntityIdent, 
		PayorIdent, 
		AddASUserIdent, 
		AddDateTime, 
		EditASUserIdent, 
		EditDateTime, 
		Active
	) 
	SELECT 
		EntityIdent = @intEntityIdent, 
		PayorIdent = @intPayorIdent, 
		AddASUserIdent = @intAddASUserIdent, 
		AddDateTime = dbo.ufnGetMyDate(), 
		EditASUserIdent = 0, 
		EditDateTime = '1/1/1900', 
		Active = @bitActive

	SELECT SCOPE_IDENTITY() AS [Ident]

GO