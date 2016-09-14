IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ASUserActivity') and 
	OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE ASUserActivity
go
CREATE TABLE ASUserActivity(
	Ident BIGINT IDENTITY(1,1) NOT NULL,
	ASUserIdent BIGINT NULL,
	ActivityTypeIdent BIGINT NULL,
	ActivityDateTime DATETIME NULL,
	ActivityDescription NVARCHAR(MAX) NULL,
	ClientIPAddress NVARCHAR(50) NULL ,
	RecordIdent BIGINT,
	CustomerEntityIdent BIGINT,
	UpdatedEntityIdent BIGINT
)
GO

CREATE UNIQUE CLUSTERED INDEX idx_ASUserActivity_Ident ON ASUserActivity(Ident)
GO
CREATE INDEX idx_ASUserActivity_ActivityDateTime ON ASUserActivity (ActivityDateTime)
INCLUDE (ASUserIdent,ActivityTypeIdent,CustomerEntityIdent,UpdatedEntityIdent)
GO
CREATE INDEX idx_ASUserActivity_RecordIdent ON ASUserActivity(RecordIdent)
GO