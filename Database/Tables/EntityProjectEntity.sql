IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityProjectEntity') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityProjectEntity

GO

CREATE TABLE EntityProjectEntity (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	EntityProjectIdent BIGINT NULL ,
	EntityIdent BIGINT NULL ,
	LastEmailNotificationSent DATETIME,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityProjectEntity_Ident ON dbo.EntityProjectEntity(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityProjectEntity_EntityProjectIdent ON dbo.EntityProjectEntity(EntityProjectIdent) 
GO

CREATE NONCLUSTERED INDEX idx_EntityProjectEntity_EntityIdent ON dbo.EntityProjectEntity(EntityIdent, Active) 
GO

CREATE NONCLUSTERED INDEX idx_EntityProjectEntity_CoverIndex ON dbo.EntityProjectEntity(EntityProjectIdent, EntityIdent, Active) 
GO