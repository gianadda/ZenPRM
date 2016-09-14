IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityTaxonomyXRef') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntityTaxonomyXRef
 GO
/* uspAddEntityTaxonomyXRef
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspAddEntityTaxonomyXRef]

	@intEntityIdent BIGINT = 0, 
	@intTaxonomyIdent BIGINT = 0, 
	@intAddASUserIdent BIGINT = 0, 
	@bitActive BIT = False

AS

	SET NOCOUNT ON

	INSERT INTO EntityTaxonomyXRef (
		EntityIdent, 
		TaxonomyIdent, 
		AddASUserIdent, 
		AddDateTime, 
		EditASUserIdent, 
		EditDateTime, 
		Active
	) 
	SELECT 
		EntityIdent = @intEntityIdent, 
		TaxonomyIdent = @intTaxonomyIdent, 
		AddASUserIdent = @intAddASUserIdent, 
		AddDateTime = dbo.ufnGetMyDate(), 
		EditASUserIdent = 0, 
		EditDateTime = '1/1/1900', 
		Active = @bitActive

	SELECT SCOPE_IDENTITY() AS [Ident]

GO