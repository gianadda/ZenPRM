-- **************************************************************************************************
-- Table:EntityNetworkImportHistory
-- Description: Stores the import history for an Entity Network Bulk Import
-- **************************************************************************************************
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityNetworkImportHistory') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityNetworkImportHistory
GO

CREATE TABLE EntityNetworkImportHistory (
	Ident BIGINT IDENTITY(1,1) NOT NULL,
	EntityIdent BIGINT NULL,
	ASUserIdent BIGINT NULL,
	ImportDateTime DATETIME NULL,
	ImportData NVARCHAR(MAX)
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityNetworkImportHistory_Ident ON dbo.EntityNetworkImportHistory(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityNetworkImportHistory_EntityIdent ON dbo.EntityNetworkImportHistory(EntityIdent) 
GO
