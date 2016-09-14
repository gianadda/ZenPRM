IF NOT (SELECT TYPE_ID(N'EntitySearchOutput')) IS NULL
	BEGIN
		DROP TYPE EntitySearchOutput
	END
GO
	CREATE TYPE EntitySearchOutput AS TABLE 
	(
		EntityIdent BIGINT,
		DisplayName NVARCHAR(MAX),
		Person BIT,
		Distance DECIMAL(20,8),
		SearchResults BIGINT,
		EntitySearchHistoryIdent BIGINT
	)

GO