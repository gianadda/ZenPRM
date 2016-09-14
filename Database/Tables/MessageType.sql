-- **************************************************************************************************
-- Table:MessageType
-- **************************************************************************************************
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'MessageType') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE MessageType
GO

CREATE TABLE MessageType (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	Name1 NVARCHAR(100) NULL,
	Desc1 NVARCHAR(250) NULL,
	ServerName NVARCHAR(500) NULL,
	ServerUsername NVARCHAR(500) NULL,
	ServerPassword NVARCHAR(500) NULL,
	ServerPort NVARCHAR(5) NULL,
	ServerTimeout NVARCHAR(10) NULL,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_MessageType_Ident ON dbo.MessageType(Ident) 
GO

INSERT INTO MessageType(
	Name1,
	Desc1,
	ServerName,
	ServerUsername,
	ServerPassword,
	ServerPort,
	ServerTimeout,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	Name1 = 'Email',
	Desc1 = 'Plain Text Email',
	ServerName = 'relay.algonquinstudios.com',
	ServerUsername = '',
	ServerPassword = '',
	ServerPort = '25',
	ServerTimeout = '20000',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

GO