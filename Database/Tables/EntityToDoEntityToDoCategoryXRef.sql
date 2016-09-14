IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityToDoEntityToDoCategoryXRef') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityToDoEntityToDoCategoryXRef
GO

CREATE TABLE EntityToDoEntityToDoCategoryXRef (
	Ident BIGINT IDENTITY (1, 1) ,
	EntityToDoIdent BIGINT ,
	EntityToDoCategoryIdent BIGINT ,
	AddASUserIdent BIGINT,
	AddDateTime SMALLDATETIME,
	EditASUserIdent BIGINT,	
	EditDateTime SMALLDATETIME,
	Active BIT
)	

CREATE UNIQUE CLUSTERED INDEX idx_EntityToDoEntityToDoCategoryXRef_Ident ON dbo.EntityToDoEntityToDoCategoryXRef(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityToDoEntityToDoCategoryXReff_ProviderIdent ON dbo.EntityToDoEntityToDoCategoryXRef(EntityToDoIdent)
GO

CREATE NONCLUSTERED INDEX idx_EntityToDoEntityToDoCategoryXRef_DegreeIdent ON dbo.EntityToDoEntityToDoCategoryXRef(EntityToDoCategoryIdent) 
GO