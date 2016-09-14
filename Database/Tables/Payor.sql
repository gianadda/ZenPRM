IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'Payor') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE Payor
GO

CREATE TABLE Payor (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	Name1 NVARCHAR(150) NULL ,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_Payor_Ident ON Payor(Ident) --NO FILL FACTOR FOR IDENTITY DATA TYPE
GO
CREATE NONCLUSTERED INDEX idx_Payor_Name1 ON Payor(Name1) 
GO

SET IDENTITY_INSERT dbo.Payor ON

INSERT INTO Payor(
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
	Name1 = '',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 1,
	Name1 = 'Payor 1',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 2,
	Name1 = 'Payor 2',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 3,
	Name1 = 'Payor 3',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

SET IDENTITY_INSERT dbo.Payor OFF

GO