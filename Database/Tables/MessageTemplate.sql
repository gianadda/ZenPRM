-- **************************************************************************************************
-- Table:MessageTemplate
-- **************************************************************************************************
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'MessageTemplate') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE MessageTemplate
GO

CREATE TABLE MessageTemplate (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	Name1 NVARCHAR(100) NULL,
	Desc1 NVARCHAR(250) NULL,
	MessageSubject NVARCHAR(500) NULL,
	MessageBody NVARCHAR(MAX) NULL,
	FromAddress NVARCHAR(500) NULL,
	FromDisplayName NVARCHAR(500) NULL,
	ReplyToAddress NVARCHAR(500) NULL,
	MessageExpirationHours INT NULL,
	SendAsHTML BIT NULL,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_MessageTemplate_Ident ON dbo.MessageTemplate(Ident) 
GO