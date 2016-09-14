IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityLanguage1XRef') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityLanguage1XRef
GO

CREATE TABLE EntityLanguage1XRef (
	Ident BIGINT IDENTITY (1, 1) ,
	EntityIdent BIGINT ,
	Language1Ident BIGINT ,
	AddASUserIdent BIGINT,
	AddDateTime SMALLDATETIME,
	EditASUserIdent BIGINT,	
	EditDateTime SMALLDATETIME,
	Active BIT
)	

CREATE UNIQUE CLUSTERED INDEX idx_EntityLanguage1XRef_Ident ON dbo.EntityLanguage1XRef(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityLanguage1XRef_ProviderIdent ON dbo.EntityLanguage1XRef(EntityIdent) 
GO

CREATE NONCLUSTERED INDEX idx_EntityLanguage1XRef_Language1Ident ON dbo.EntityLanguage1XRef(Language1Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityLanguage1XRef_CoverIndex ON dbo.EntityLanguage1XRef(EntityIdent, Language1Ident, Active) 
GO