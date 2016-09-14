-- **************************************************************************************************
-- Table:ToDoStatus
-- **************************************************************************************************
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'ToDoStatus') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE ToDoStatus
GO

CREATE TABLE ToDoStatus (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	Name1 NVARCHAR(100) NULL,
	IconClass NVARCHAR(MAX) NULL,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_ToDoStatus_Ident ON dbo.ToDoStatus(Ident) 
GO

INSERT INTO ToDoStatus(
	Name1,
	IconClass,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	Name1 = 'Open',
	IconClass = '',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Name1 = 'Pending',
	IconClass = '',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Name1 = 'Closed',
	IconClass = '',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1


GO