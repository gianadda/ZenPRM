IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityCustomImportMap') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityCustomImportMap
GO

CREATE TABLE EntityCustomImportMap (
	Ident BIGINT IDENTITY (1,1) NOT NULL,
	EntityProjectRequirementIdent BIGINT,
	DataSchema NVARCHAR(MAX),
	ImportUID NVARCHAR(MAX)
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityCustomImportMap_Ident ON EntityCustomImportMap(Ident) --NO FILL FACTOR FOR IDENTITY DATA TYPE
GO
CREATE NONCLUSTERED INDEX idx_EntityCustomImportMap_EntityProjectRequirementIdent ON EntityCustomImportMap(EntityProjectRequirementIdent) 
GO
