IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityServices1XRef') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityServices1XRef
GO

CREATE TABLE EntityServices1XRef (
	Ident BIGINT IDENTITY (1, 1) ,
	EntityIdent BIGINT ,
	Services1Ident BIGINT ,
	AddASUserIdent BIGINT,
	AddDateTime SMALLDATETIME,
	EditASUserIdent BIGINT,	
	EditDateTime SMALLDATETIME,
	Active BIT
)	

CREATE UNIQUE CLUSTERED INDEX idx_EntityServices1XRef_Ident ON dbo.EntityServices1XRef(Ident)
GO

CREATE NONCLUSTERED INDEX idx_EntityServices1XRef_ProviderIdent ON dbo.EntityServices1XRef(EntityIdent) 
GO

CREATE NONCLUSTERED INDEX idx_EntityServices1XRef_Services1Ident ON dbo.EntityServices1XRef(Services1Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityServices1XRef_CoverIndex ON dbo.EntityServices1XRef(EntityIdent, Services1Ident, Active) 
GO