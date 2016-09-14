IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityProjectExport') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityProjectExport

GO

CREATE TABLE EntityProjectExport (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	EntityProjectIdent BIGINT NULL ,
	EntityProjectExportStatusIdent BIGINT NULL,
	ExportASUserIdent BIGINT NULL ,
	ExportDateTime DATETIME NULL,
	ExportCompleteDateTime DATETIME NULL,
	NumberOfEntitiesIncluded BIGINT NULL,
	NumberOfFilesAttached BIGINT NULL,
	NumberOfFilesGenerated BIGINT NULL,
	ProjectFileName NVARCHAR(MAX) NULL,
	ProjectFileSize NVARCHAR(100) NULL,
	ProjectFileKey NVARCHAR(MAX) NULL,
	Active BIT NULL,
	DeleteDateTime SMALLDATETIME NULL,
	LockDateTime DATETIME NULL,
	LockSessionIdent BIGINT
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityProjectExport_Ident ON dbo.EntityProjectExport(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityProjectExport_EntityProjectIdent ON dbo.EntityProjectExport(EntityProjectIdent) 
GO

CREATE NONCLUSTERED INDEX idx_EntityProjectExport_ExportASUserIdent ON dbo.EntityProjectExport(ExportASUserIdent) 
GO

CREATE NONCLUSTERED INDEX idx_EntityProjectExport_EntityProjectExportStatusIdent ON dbo.EntityProjectExport(EntityProjectExportStatusIdent) 
GO
