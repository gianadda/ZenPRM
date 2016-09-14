IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'SystemRole') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE SystemRole
GO

CREATE TABLE SystemRole (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	Name1 NVARCHAR(150) NULL ,
	IsCustomer BIT NULL,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_SystemRole_Ident ON SystemRole(Ident) --NO FILL FACTOR FOR IDENTITY DATA TYPE
GO
CREATE NONCLUSTERED INDEX idx_SystemRole_Name1 ON SystemRole(Name1) 
GO

SET IDENTITY_INSERT dbo.SystemRole ON

INSERT INTO SystemRole(
	Ident,
	Name1,
	IsCustomer,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	Ident = 1,
	Name1 = 'Customer',
	IsCustomer = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	Ident = 2,
	Name1 = 'Entity',
	IsCustomer = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	Ident = 3,
	Name1 = 'Zen Team',
	IsCustomer = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	Ident = 4,
	Name1 = 'Project Customer',
	IsCustomer = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 0

UNION ALL
SELECT
	Ident = 5,
	Name1 = 'Team Customer',
	IsCustomer = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 0

UNION ALL
SELECT
	Ident = 6,
	Name1 = 'Network Customer',
	IsCustomer = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 0

SET IDENTITY_INSERT dbo.SystemRole OFF

GO