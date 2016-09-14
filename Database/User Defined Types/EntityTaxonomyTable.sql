IF NOT (SELECT TYPE_ID(N'EntityTaxonomyTable')) IS NULL
	BEGIN
		DROP TYPE EntityTaxonomyTable
	END
GO
-- Used to pass entity search filters from UI to SQL
	CREATE TYPE EntityTaxonomyTable AS TABLE 
	(
		EntityIdent BIGINT,
		TaxonomyIdent BIGINT,
		TaxonomyCode1 NVARCHAR(MAX)
	)

GO