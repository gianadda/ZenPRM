-- **************************************************************************************************
-- Table:MeasureType
-- **************************************************************************************************
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'MeasureLocation') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE MeasureLocation
GO

CREATE TABLE MeasureLocation (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	Name1 NVARCHAR(100) NULL,
	Desc1 NVARCHAR(250) NULL,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_MeasureLocation_Ident ON dbo.MeasureLocation(Ident) 
GO

INSERT INTO MeasureLocation(
	Name1,
	Desc1,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	Name1 = 'Dashboard',
	Desc1 = 'If selected, this measure will display on the main customer dashboard.',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Name1 = 'Project Overview',
	Desc1 = 'If selected, this measure will display on the project overview screen.',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Name1 = 'Resource Profile',
	Desc1 = 'If selected, this measure will display on any resources profile who is eligible to answer the measure questions.',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Name1 = 'Organization Structure',
	Desc1 = 'If selected, this measure will display on an organization''s profile if there are eligible resources to answer the measure questions within their structure.',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

GO