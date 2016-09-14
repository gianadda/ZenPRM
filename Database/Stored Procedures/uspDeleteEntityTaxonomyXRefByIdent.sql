IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspDeleteEntityTaxonomyXRefByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspDeleteEntityTaxonomyXRefByIdent
 GO
/* uspDeleteEntityTaxonomyXRefByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspDeleteEntityTaxonomyXRefByIdent]

	@intEntityIdent BIGINT,
	@intTaxonomyIdent BIGINT,
	@intEditASUserIdent BIGINT = 0, 
	@sdtEditDateTime SMALLDATETIME = '1/1/1900'

AS

	SET NOCOUNT ON

	UPDATE EntityTaxonomyXRef
	SET 
		EditASUserIdent = @intEditASUserIdent,
		EditDateTime = @sdtEditDateTime,
		Active = 0
	WHERE
		EntityIdent = @intEntityIdent
		AND TaxonomyIdent = @intTaxonomyIdent 
		AND Active = 1	 

	SELECT 
		Ident,
		EntityIdent,
		TaxonomyIdent,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	FROM
		EntityTaxonomyXRef WITH (NOLOCK)
	WHERE 
		EntityIdent = @intEntityIdent
		AND Active = 1

GO