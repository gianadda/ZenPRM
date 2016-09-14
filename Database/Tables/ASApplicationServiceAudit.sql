IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'ASApplicationServiceAudit') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE ASApplicationServiceAudit
GO

CREATE TABLE ASApplicationServiceAudit (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	ServerName NVARCHAR(200) NULL,
	ServiceName NVARCHAR(200) NULL,
	ServiceDateTime DATETIME NULL,
	ProcessedRecordCount BIGINT NULL,
	ProcessedMessage NVARCHAR(MAX)
)

CREATE UNIQUE CLUSTERED INDEX idx_ASApplicationServiceAudit_Ident ON ASApplicationServiceAudit(Ident) --NO FILL FACTOR FOR IDENTITY DATA TYPE
GO

CREATE NONCLUSTERED INDEX idx_ASApplicationServiceAudit_ServiceName ON ASApplicationServiceAudit(ServiceName)
GO

CREATE NONCLUSTERED INDEX idx_ASApplicationServiceAudit_ServiceDateTime ON ASApplicationServiceAudit(ServiceDateTime)
GO