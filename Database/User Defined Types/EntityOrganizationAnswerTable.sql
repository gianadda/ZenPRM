IF NOT (SELECT TYPE_ID(N'EntityOrganizationAnswerTable')) IS NULL
	BEGIN
		DROP TYPE EntityOrganizationAnswerTable
	END
GO
	CREATE TYPE EntityOrganizationAnswerTable AS TABLE 
	(
		OrganizationIdent BIGINT,
		EntityIdent BIGINT,
		Answered BIT,
		Value1 NVARCHAR(MAX),
		Value2 NVARCHAR(MAX)
	)

GO