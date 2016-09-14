IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityPayorXRef') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityPayorXRef
GO

CREATE TABLE EntityPayorXRef (
	Ident BIGINT IDENTITY (1, 1) ,
	EntityIdent BIGINT ,
	PayorIdent BIGINT ,
	AddASUserIdent BIGINT,
	AddDateTime SMALLDATETIME,
	EditASUserIdent BIGINT,	
	EditDateTime SMALLDATETIME,
	Active BIT
)	

CREATE UNIQUE CLUSTERED INDEX idx_EntityPayorXRef_Ident ON dbo.EntityPayorXRef(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityPayorXRef_ProviderIdent ON dbo.EntityPayorXRef(EntityIdent) 
GO

CREATE NONCLUSTERED INDEX idx_EntityPayorXRef_PayorIdent ON dbo.EntityPayorXRef(PayorIdent) 
GO

CREATE NONCLUSTERED INDEX idx_EntityPayorXRef_CoverIndex ON dbo.EntityPayorXRef(EntityIdent, PayorIdent, Active) 
GO