IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityDegreeXRef') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityDegreeXRef
GO

CREATE TABLE EntityDegreeXRef (
	Ident BIGINT IDENTITY (1, 1) ,
	EntityIdent BIGINT ,
	DegreeIdent BIGINT ,
	AddASUserIdent BIGINT,
	AddDateTime SMALLDATETIME,
	EditASUserIdent BIGINT,	
	EditDateTime SMALLDATETIME,
	Active BIT
)	

CREATE UNIQUE CLUSTERED INDEX idx_EntityDegreeXRef_Ident ON dbo.EntityDegreeXRef(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityDegreeXRef_ProviderIdent ON dbo.EntityDegreeXRef(EntityIdent) 
GO

CREATE NONCLUSTERED INDEX idx_EntityDegreeXRef_DegreeIdent ON dbo.EntityDegreeXRef(DegreeIdent) 
GO

CREATE NONCLUSTERED INDEX idx_EntityDegreeXRef_CoverIndex ON dbo.EntityDegreeXRef(EntityIdent, DegreeIdent, Active) 
GO