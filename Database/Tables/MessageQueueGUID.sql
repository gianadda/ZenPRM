-- **************************************************************************************************
-- Table:MessageQueueGUID
-- Description: Stores the RecordIdent and GUID for password reset attempts, and the expiration date of the key
-- **************************************************************************************************
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'MessageQueueGUID') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE MessageQueueGUID
GO

CREATE TABLE MessageQueueGUID (
	Ident BIGINT IDENTITY(1,1) NOT NULL,
	RecordIdent BIGINT NULL,
	MessageQueueIdent BIGINT NULL,
	MessageTemplateIdent BIGINT NULL,
	MessageGUID UNIQUEIDENTIFIER NULL,
	ExpirationDateTime SMALLDATETIME NULL,
	AddDateTime SMALLDATETIME NULL,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_MessageQueueGUID_Ident ON dbo.MessageQueueGUID(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_MessageQueueGUID_GUID ON dbo.MessageQueueGUID(MessageGUID) 
GO
