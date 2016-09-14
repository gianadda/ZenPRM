IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntitySpecialityXRef') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntitySpecialityXRef
 GO
/* uspAddEntitySpecialityXRef
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspAddEntitySpecialityXRef]

	@intEntityIdent BIGINT = 0, 
	@intSpecialityIdent BIGINT = 0, 
	@intAddASUserIdent BIGINT = 0, 
	@bitActive BIT = False

AS

	SET NOCOUNT ON

	INSERT INTO EntitySpecialityXRef (
		EntityIdent, 
		SpecialityIdent, 
		AddASUserIdent, 
		AddDateTime, 
		EditASUserIdent, 
		EditDateTime, 
		Active
	) 
	SELECT 
		EntityIdent = @intEntityIdent, 
		SpecialityIdent = @intSpecialityIdent, 
		AddASUserIdent = @intAddASUserIdent, 
		AddDateTime = dbo.ufnGetMyDate(), 
		EditASUserIdent = 0, 
		EditDateTime = '1/1/1900', 
		Active = @bitActive

	SELECT SCOPE_IDENTITY() AS [Ident]

GO