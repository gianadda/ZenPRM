IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntitySystem') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntitySystem

GO

CREATE TABLE EntitySystem (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	EntityIdent BIGINT NULL ,
	SystemTypeIdent BIGINT NULL ,
	Name1 NVARCHAR(MAX) NULL,
	InstalationDate SMALLDATETIME NULL ,
	GoLiveDate SMALLDATETIME NULL ,
	DecomissionDate SMALLDATETIME NULL ,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT
)

CREATE UNIQUE CLUSTERED INDEX idx_EntitySystem_Ident ON dbo.EntitySystem(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntitySystem_EntityIdent ON dbo.EntitySystem(EntityIdent) 
GO
