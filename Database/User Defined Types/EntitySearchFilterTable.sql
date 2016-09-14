IF NOT (SELECT TYPE_ID(N'EntitySearchFilterTable')) IS NULL
	BEGIN
		DROP TYPE EntitySearchFilterTable
	END
GO
-- Used to pass entity search filters from UI to SQL
	CREATE TYPE EntitySearchFilterTable AS TABLE 
	(
		Ident BIGINT,
		EntitySearchFilterTypeIdent BIGINT,
		EntitySearchOperatorIdent BIGINT,
		EntityProjectRequirementIdent BIGINT,
		ReferenceIdent BIGINT,
		SearchValue NVARCHAR(MAX)
	)

GO