IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityLicense') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityLicense

GO

CREATE TABLE EntityLicense (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	EntityIdent BIGINT NULL ,
	StatesIdent BIGINT NULL, 
	LicenseNumber NVARCHAR(MAX) NULL,
	LicenseNumberExpirationDate SMALLDATETIME NULL ,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityLicense_Ident ON dbo.EntityLicense(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityLicense_EntityIdent ON dbo.EntityLicense(EntityIdent) 
GO
