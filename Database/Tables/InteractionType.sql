IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'InteractionType') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE InteractionType
GO

CREATE TABLE InteractionType (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	Name1 NVARCHAR(150) NULL ,
	Icon NVARCHAR(150) NULL ,
	Class NVARCHAR(150) NULL ,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_InteractionType_Ident ON InteractionType(Ident) --NO FILL FACTOR FOR IDENTITY DATA TYPE
GO
CREATE NONCLUSTERED INDEX idx_InteractionType_Name1 ON InteractionType(Name1) 
GO

SET IDENTITY_INSERT dbo.InteractionType ON

INSERT INTO InteractionType(
	Ident,
	Name1,
	Icon,
	Class,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	Ident = 0,
	Name1 = '',
	Icon = 'glyphicon glyphicon-plus',
	Class = 'btn btn-primary',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 1,
	Name1 = 'Phone Call',
	Icon = 'glyphicon glyphicon-earphone',
	Class = 'btn btn-success',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 2,
	Name1 = 'Password Reset Request',
	Icon = 'glyphicon glyphicon-lock',
	Class = 'btn btn-warning',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

SET IDENTITY_INSERT dbo.InteractionType OFF

GO