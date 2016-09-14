IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityUpdateQueue') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityUpdateQueue
GO

CREATE TABLE EntityUpdateQueue (
	Ident BIGINT IDENTITY (1, 1) ,
	NPI NVARCHAR(10),
	AddDateTime DATETIME,
	LockTime DATETIME,
	LockSessionIdent BIGINT
)	

CREATE UNIQUE CLUSTERED INDEX idx_EntityUpdateQueue_Ident ON dbo.EntityUpdateQueue(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_NPI_ProviderIdent ON dbo.EntityUpdateQueue(NPI) 
GO

CREATE NONCLUSTERED INDEX idx_EntityUpdateQueue_AddDateTime ON dbo.EntityUpdateQueue(AddDateTime) 
GO