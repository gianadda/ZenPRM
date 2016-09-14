IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ASMessageLog') and 
	OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE ASMessageLog
go
CREATE TABLE ASMessageLog(
	Ident BIGINT IDENTITY(1,1) NOT NULL,
	ASUserIdent BIGINT NULL,
	MessageDescription NVARCHAR(MAX) NULL,
	ExceptionToString NVARCHAR(MAX) NULL,
	ClientComputerName NVARCHAR(100) NULL,
	ServerComputerName NVARCHAR(100) NULL,
	GeneratingMethod NVARCHAR(500) NULL,
	ParentMethod NVARCHAR(500) NULL,
	UserName NVARCHAR(400) NULL ,
	MessageTime DATETIME NULL,
	MessageURL NVARCHAR(MAX) NULL, 
	Cause NVARCHAR(MAX) NULL
)
GO

CREATE UNIQUE CLUSTERED INDEX idx_ASMessageLog_Ident ON ASMessageLog(Ident)
GO
CREATE INDEX idx_ASMessageLog_MessageTime ON ASMessageLog(MessageTime) 
GO