IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityTaxonomyXRef') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityTaxonomyXRef
GO

CREATE TABLE EntityTaxonomyXRef (
	Ident BIGINT IDENTITY (1, 1) ,
	EntityIdent BIGINT ,
	TaxonomyIdent BIGINT ,
	AddASUserIdent BIGINT,
	AddDateTime SMALLDATETIME,
	EditASUserIdent BIGINT,	
	EditDateTime SMALLDATETIME,
	Active BIT
)	

CREATE UNIQUE CLUSTERED INDEX idx_EntityTaxonomyXRef_Ident ON dbo.EntityTaxonomyXRef(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityTaxonomyXRef_ProviderIdent ON dbo.EntityTaxonomyXRef(EntityIdent)
GO

CREATE NONCLUSTERED INDEX idx_EntityTaxonomyXRef_TaxonomyIdent ON dbo.EntityTaxonomyXRef(TaxonomyIdent) 
GO


CREATE NONCLUSTERED INDEX idx_EntityTaxonomyXRef_CoverIndex ON dbo.EntityTaxonomyXRef(EntityIdent, TaxonomyIdent, Active) 
GO

CREATE INDEX [ix_EntityTaxonomyXRef_TaxonomyIdent_Active_includes] ON [ZenPRM].[dbo].[EntityTaxonomyXRef] ([TaxonomyIdent], [Active])  INCLUDE ([EntityIdent]) WITH (FILLFACTOR=100);
GO

CREATE INDEX [ix_EntityTaxonomyXRef_Active_includes] ON [ZenPRM].[dbo].[EntityTaxonomyXRef] ([Active])  INCLUDE ([TaxonomyIdent]) WITH (FILLFACTOR=100);
GO