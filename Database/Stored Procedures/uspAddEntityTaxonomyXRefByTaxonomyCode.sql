IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityTaxonomyXRefByTaxonomyCode') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntityTaxonomyXRefByTaxonomyCode
 GO
/* uspAddEntityTaxonomyXRefByTaxonomyCode
 *
 *
 *
 *
*/
CREATE PROCEDURE uspAddEntityTaxonomyXRefByTaxonomyCode

	@intEntityIdent BIGINT, 
	@intAddASUserIdent BIGINT,
	@tblTaxonomy [EntityTaxonomyTable] READONLY

AS

	SET NOCOUNT ON

	DECLARE @tblTaxonomyForEdit [EntityTaxonomyTable]

	INSERT INTO @tblTaxonomyForEdit(
		EntityIdent,
		TaxonomyIdent,
		TaxonomyCode1
	)
	SELECT
		EntityIdent,
		TaxonomyIdent,
		TaxonomyCode1
	FROM
		@tblTaxonomy

	UPDATE
		tblT
	SET
		TaxonomyIdent = T.Ident
	FROM
		@tblTaxonomyForEdit tblT
		INNER JOIN
		Taxonomy T WITH (NOLOCK)
			ON T.Code1 = tblT.TaxonomyCode1

	MERGE INTO EntityTaxonomyXRef AS target
	USING @tblTaxonomyForEdit AS source
		ON target.EntityIdent = source.EntityIdent
			AND target.TaxonomyIdent = source.TaxonomyIdent
	WHEN MATCHED THEN 
		--if we found one already, mark it as updated and who updated it.
		UPDATE 
			SET 
				target.EditASUserIdent = @intAddASUserIdent,
				target.EditDateTime = dbo.ufnGetMyDate(),
				target.Active = 1

	WHEN NOT MATCHED BY TARGET THEN
		-- Put in the new answer
		INSERT (
			EntityIdent,
			TaxonomyIdent,
			AddASUserIdent,
			AddDateTime,
			EditASUserIdent,
			EditDateTime,
			Active
		)
		VALUES  (
			source.EntityIdent,
			source.TaxonomyIdent,
			@intAddASUserIdent,
			dbo.ufnGetMyDate(),
			0,
			'1/1/1900',
			1
		);

GO