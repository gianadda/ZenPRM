IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'ReportType') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE ReportType
GO

CREATE TABLE ReportType (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	Name1 NVARCHAR(150) NULL ,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_ReportType_Ident ON ReportType(Ident) --NO FILL FACTOR FOR IDENTITY DATA TYPE
GO
CREATE NONCLUSTERED INDEX idx_ReportType_Name1 ON ReportType(Name1) 
GO


SET IDENTITY_INSERT dbo.ReportType ON

INSERT INTO ReportType(
 Ident,
 Name1,
 AddASUserIdent,
 AddDateTime,
 EditASUserIdent,
 EditDateTime,
 Active
)SELECT
 Ident = 0,
 Name1 = '',
 AddASUserIdent = 0,
 AddDateTime = dbo.ufnGetMyDate(),
 EditASUserIdent = 0,
 EditDateTime = '1/1/1900',
 Active = 1
 
SET IDENTITY_INSERT dbo.ReportType OFF
GO 

INSERT INTO ReportType(
 Name1,
 AddASUserIdent,
 AddDateTime,
 EditASUserIdent,
 EditDateTime,
 Active
)SELECT
 Name1 = 'Resource Report',
 AddASUserIdent = 0,
 AddDateTime = dbo.ufnGetMyDate(),
 EditASUserIdent = 0,
 EditDateTime = '1/1/1900',
 Active = 1

INSERT INTO ReportType(

 Name1,
 AddASUserIdent,
 AddDateTime,
 EditASUserIdent,
 EditDateTime,
 Active
)SELECT
 Name1 = 'Status Report',
 AddASUserIdent = 0,
 AddDateTime = dbo.ufnGetMyDate(),
 EditASUserIdent = 0,
 EditDateTime = '1/1/1900',
 Active = 1


GO

SELECT * FROM ReportType