-- **************************************************************************************************
-- Table:MeasureType
-- **************************************************************************************************
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'MeasureType') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE MeasureType
GO

CREATE TABLE MeasureType (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	Name1 NVARCHAR(100) NULL,
	Desc1 NVARCHAR(250) NULL,
	EntitySearchDataTypeIdent BIGINT,
	HasDenominator BIT NULL,
	HasTargetValue BIT NULL,
	IsAverage BIT NULL,
	IsPercentage BIT NULL,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_MeasureType_Ident ON dbo.MeasureType(Ident) 
GO

INSERT INTO MeasureType(
	Name1,
	Desc1,
	EntitySearchDataTypeIdent,
	HasDenominator,
	HasTargetValue,
	IsAverage,
	IsPercentage,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	Name1 = 'Average',
	Desc1 = 'Average',
	EntitySearchDataTypeIdent = 1,
	HasDenominator = 0,
	HasTargetValue = 0,
	IsAverage = 1,
	IsPercentage = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Name1 = 'Percentage',
	Desc1 = 'Percentage',
	EntitySearchDataTypeIdent = 1,
	HasDenominator = 1,
	HasTargetValue = 0,
	IsAverage = 0,
	IsPercentage = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Name1 = 'Fraction',
	Desc1 = 'Fraction',
	EntitySearchDataTypeIdent = 1,
	HasDenominator = 1,
	HasTargetValue = 1,
	IsAverage = 0,
	IsPercentage = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 0
UNION ALL
SELECT
	Name1 = 'Sum',
	Desc1 = 'Sum',
	EntitySearchDataTypeIdent = 1,
	HasDenominator = 0,
	HasTargetValue = 0,
	IsAverage = 0,
	IsPercentage = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Name1 = 'Ratio',
	Desc1 = 'Ratio',
	EntitySearchDataTypeIdent = 1,
	HasDenominator = 1,
	HasTargetValue = 0,
	IsAverage = 0,
	IsPercentage = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Name1 = 'Count',
	Desc1 = 'Count',
	EntitySearchDataTypeIdent = 0,
	HasDenominator = 0,
	HasTargetValue = 0,
	IsAverage = 0,
	IsPercentage = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Name1 = 'Pie Chart',
	Desc1 = 'Pie Chart',
	EntitySearchDataTypeIdent = 4,
	HasDenominator = 0,
	HasTargetValue = 0,
	IsAverage = 0,
	IsPercentage = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Name1 = 'Bar Chart',
	Desc1 = 'Bar Chart',
	EntitySearchDataTypeIdent = 4,
	HasDenominator = 0,
	HasTargetValue = 0,
	IsAverage = 0,
	IsPercentage = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 0
UNION ALL
SELECT
	Name1 = 'Percentage (Yes/No)',
	Desc1 = 'Percentage (Yes/No)',
	EntitySearchDataTypeIdent = 5,
	HasDenominator = 0,
	HasTargetValue = 0,
	IsAverage = 0,
	IsPercentage = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

GO