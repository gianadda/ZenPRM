IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityExternalLogin') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityExternalLogin

GO

CREATE TABLE EntityExternalLogin (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	EntityIdent BIGINT NULL ,
	ExternalSource NVARCHAR(MAX) NULL,
	ExternalNameIdentifier NVARCHAR(MAX) NULL,
	ExternalEmailAddress NVARCHAR(MAX) NULL,
	Active BIT NULL,
	AddDateTime DATETIME NULL,
	AddASUserIdent BIGINT NULL,
	EditDateTime DATETIME NULL,
	EditASUserIdent BIGINT NULL
)
GO

CREATE UNIQUE CLUSTERED INDEX idx_EntityExternalLogin_Ident ON dbo.EntityExternalLogin(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityExternalLogin_EntityIdent ON dbo.EntityExternalLogin(EntityIdent) 
INCLUDE (ExternalSource, ExternalNameIdentifier, ExternalEmailAddress)
GO
