IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntitySearchDataType') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntitySearchDataType
GO

CREATE TABLE EntitySearchDataType (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	Name1 NVARCHAR(150) NULL ,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_EntitySearchDataType_Ident ON EntitySearchDataType(Ident) --NO FILL FACTOR FOR IDENTITY DATA TYPE
GO

SET IDENTITY_INSERT dbo.EntitySearchDataType ON

INSERT INTO EntitySearchDataType(
	Ident,
	Name1,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	Ident = 0,
	Name1 = 'N/A',
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 1,
	Name1 = 'Number',
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 2,
	Name1 = 'Text',
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 3,
	Name1 = 'Date/Time',
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 4,
	Name1 = 'Options/List',
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 5,
	Name1 = 'Bit',
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 6,
	Name1 = 'File',
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 7,
	Name1 = 'Hours of Operation',
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 8,
	Name1 = 'Address',
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 9,
	Name1 = 'Email',
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

SET IDENTITY_INSERT dbo.EntitySearchDataType OFF

GO