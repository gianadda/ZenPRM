IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'PCMHStatus') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE PCMHStatus
GO

CREATE TABLE PCMHStatus (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	Name1 NVARCHAR(150) NULL ,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_PCMHStatus_Ident ON PCMHStatus(Ident) --NO FILL FACTOR FOR IDENTITY DATA TYPE
GO
CREATE NONCLUSTERED INDEX idx_PCMHStatus_Name1 ON PCMHStatus(Name1) 
GO

SET IDENTITY_INSERT dbo.PCMHStatus ON

INSERT INTO PCMHStatus(
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
	Name1 = 'Level 1',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 2,
	Name1 = 'Level 2',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 3,
	Name1 = 'Level 3',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

SET IDENTITY_INSERT dbo.PCMHStatus OFF

GO