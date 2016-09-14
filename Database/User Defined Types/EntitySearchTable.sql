IF NOT (SELECT TYPE_ID(N'EntitySearchTable')) IS NULL
	BEGIN
		DROP TYPE EntitySearchTable
	END
GO
-- Used to pass entity search filters from UI to SQL
	CREATE TYPE EntitySearchTable AS TABLE 
	(
		EntityIdent BIGINT,
		Distance DECIMAL(5,1)
	)

GO