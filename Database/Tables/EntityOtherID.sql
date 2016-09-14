IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityOtherID') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityOtherID

GO

CREATE TABLE EntityOtherID (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	EntityIdent BIGINT NULL ,
	IDType NVARCHAR(MAX) NULL,
	IDNumber NVARCHAR(MAX) NULL,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityOtherID_Ident ON dbo.EntityOtherID(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityOtherID_EntityIdent ON dbo.EntityOtherID(EntityIdent) 
GO
