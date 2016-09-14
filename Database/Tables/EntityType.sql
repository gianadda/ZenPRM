IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityType') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityType
GO

CREATE TABLE EntityType (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	Person BIT,
	IncludeInCNP BIT,
	Name1 NVARCHAR(150) NULL ,
	MapIcon NVARCHAR(150) NULL,
	MapIconColor NVARCHAR(150) NULL,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityType_Ident ON EntityType(Ident) --NO FILL FACTOR FOR IDENTITY DATA TYPE
GO
CREATE NONCLUSTERED INDEX idx_EntityType_Name1 ON EntityType(Name1)
GO

CREATE NONCLUSTERED INDEX idx_EntityType_CoverIndex ON dbo.EntityType(Ident, Person, IncludeInCNP, Name1,  Active) 
GO


SET IDENTITY_INSERT dbo.EntityType ON

INSERT INTO EntityType(
	Ident,
	Person ,
	IncludeInCNP ,
	Name1,
	MapIcon,
	MapIconColor,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	Ident = 0,
	Person = 0,
	IncludeInCNP = 0,
	Name1 = '',
	MapIcon = '',
	MapIconColor = '',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 1,
	Person = 1,
	IncludeInCNP = 0,
	Name1 = 'System Administrator',
	MapIcon = 'fa fa-user',
	MapIconColor = 'red',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 0
UNION ALL
SELECT
	Ident = 2,
	Person = 0,
	IncludeInCNP = 1,
	Name1 = 'Organization',
	MapIcon = 'fa fa-building',
	MapIconColor = 'purple',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 3,
	Person = 1,
	IncludeInCNP = 1,
	Name1 = 'Provider',
	MapIcon = 'fa fa-user-md',
	MapIconColor = 'orange',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 4,
	Person = 0,
	IncludeInCNP = 1,
	Name1 = 'Facility',
	MapIcon = 'fa fa-building',
	MapIconColor = 'green',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 5,
	Person = 1,
	IncludeInCNP = 0,
	Name1 = 'IT Administrator',
	MapIcon = 'fa fa-user',
	MapIconColor = 'teal',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 0
UNION ALL
SELECT
	Ident = 6,
	Person = 1,
	IncludeInCNP = 1,
	Name1 = 'General Contact',
	MapIcon = 'fa fa-user',
	MapIconColor = 'pink',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 7,
	Person = 0,
	IncludeInCNP = 1,
	Name1 = 'Committee',
	MapIcon = 'fa fa-users',
	MapIconColor = 'blue',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 7,
	Person = 0,
	IncludeInCNP = 1,
	Name1 = 'Other (Internal Use Only)',
	MapIcon = '',
	MapIconColor = '',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

SET IDENTITY_INSERT dbo.EntityType OFF

GO

-- SELECT * FROM EntityType