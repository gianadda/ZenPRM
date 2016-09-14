-- **************************************************************************************************
-- Table:MessageQueue
-- Description: Stores messages/emails to send
-- **************************************************************************************************
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'MessageQueue') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE MessageQueue
GO

CREATE TABLE MessageQueue (
	Ident BIGINT IDENTITY(1,1) NOT NULL,
	ASUserIdent BIGINT NULL,
	MessageTypeIdent BIGINT NULL,
	MessageTemplateIdent BIGINT NULL,
	MessageSent BIT NULL,
	LastAttemptedDateTime DATETIME NULL,
	NumberOfAttempts INT NULL,
	ToAddress NVARCHAR(MAX) NULL,
	CCAddress NVARCHAR(MAX) NULL,
	BCCAddress NVARCHAR(MAX) NULL,
	FromAddress NVARCHAR(500) NULL,
	FromDisplayName NVARCHAR(500) NULL,
	ReplyToAddress NVARCHAR(500) NULL,
	MessageSubject NVARCHAR(500) NULL,
	MessageBody NVARCHAR(MAX) NULL,
	SendAsHTML BIT NULL,
	Active BIT NULL,
	AddDateTime DATETIME NULL,
	AddASUserIdent INT NULL,
	EditDateTime DATETIME NULL,
	EditASUserIdent INT NULL,
	LockSessionIdent INT NULL,
	LockTime SMALLDATETIME NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_MessageQueue_Ident ON dbo.MessageQueue(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_MessageQueue_ASUserIdent ON dbo.MessageQueue(ASUserIdent)
GO

CREATE NONCLUSTERED INDEX idx_MessageQueue_MessageTypeIdent ON dbo.MessageQueue(MessageTypeIdent) 
GO

CREATE NONCLUSTERED INDEX idx_MessageQueue_MessageTemplateIdent ON dbo.MessageQueue(MessageTemplateIdent) 
GO
