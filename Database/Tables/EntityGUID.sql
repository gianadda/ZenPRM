-- **************************************************************************************************
-- Table:EntityGUID
-- Description: Stores the EntityIdent and GUID for add-on features and other permissions within ZenPRM
-- **************************************************************************************************
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityGUID') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityGUID
GO

CREATE TABLE EntityGUID (
	Ident BIGINT IDENTITY(1,1) NOT NULL,
	EntityIdent BIGINT NULL,
	EntityGUIDTypeIdent BIGINT NULL,
	EntityGUID UNIQUEIDENTIFIER NULL,
	AddDateTime SMALLDATETIME NULL,
	EditDateTime SMALLDATETIME NULL,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityGUID_Ident ON dbo.EntityGUID(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityGUID_EntityIdent ON dbo.EntityGUID(EntityIdent) 
GO

CREATE NONCLUSTERED INDEX idx_EntityGUID_GUID ON dbo.EntityGUID(EntityGUID) 
GO
