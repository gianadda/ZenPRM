IF NOT (SELECT TYPE_ID(N'EntityProjectMeasureLocationTable')) IS NULL
	BEGIN
		DROP TYPE EntityProjectMeasureLocationTable
	END
GO
-- Used to pass entity search filters from UI to SQL
	CREATE TYPE EntityProjectMeasureLocationTable AS TABLE 
	(
		Ident BIGINT,
		EntityProjectMeasureIdent BIGINT,
		MeasureLocationIdent BIGINT,
		Selected BIT
	)

GO