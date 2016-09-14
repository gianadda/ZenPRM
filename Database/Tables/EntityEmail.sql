IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityEmail') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityEmail

GO

CREATE TABLE EntityEmail (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	EntityIdent BIGINT NULL ,
	Email NVARCHAR(MAX) NULL,
	Notify BIT NULL, 
	Verified BIT NULL, 
	VerifiedASUserIdent BIGINT NULL ,
	VerifiedDateTime SMALLDATETIME NULL ,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityEmail_Ident ON dbo.EntityEmail(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityEmail_EntityIdent ON dbo.EntityEmail(EntityIdent) 
GO
