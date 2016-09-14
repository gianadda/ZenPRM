IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'SystemType') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE SystemType
GO

CREATE TABLE SystemType (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	Name1 NVARCHAR(150) NULL ,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_SystemType_Ident ON SystemType(Ident) --NO FILL FACTOR FOR IDENTITY DATA TYPE
GO
CREATE NONCLUSTERED INDEX idx_SystemType_Name1 ON SystemType(Name1) 
GO


SET IDENTITY_INSERT dbo.SystemType ON

INSERT INTO SystemType(
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
 
SET IDENTITY_INSERT dbo.SystemType OFF
GO 

INSERT INTO SystemType(
 Name1,
 AddASUserIdent,
 AddDateTime,
 EditASUserIdent,
 EditDateTime,
 Active
)SELECT
 Name1 = 'EMR',
 AddASUserIdent = 0,
 AddDateTime = dbo.ufnGetMyDate(),
 EditASUserIdent = 0,
 EditDateTime = '1/1/1900',
 Active = 1

INSERT INTO SystemType(

 Name1,
 AddASUserIdent,
 AddDateTime,
 EditASUserIdent,
 EditDateTime,
 Active
)SELECT
 Name1 = 'Direct Mail',
 AddASUserIdent = 0,
 AddDateTime = dbo.ufnGetMyDate(),
 EditASUserIdent = 0,
 EditDateTime = '1/1/1900',
 Active = 1


GO

SELECT * FROM SystemType