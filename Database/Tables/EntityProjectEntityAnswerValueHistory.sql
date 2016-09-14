IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityProjectEntityAnswerValueHistory') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityProjectEntityAnswerValueHistory
GO

CREATE TABLE EntityProjectEntityAnswerValueHistory (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	EntityProjectEntityAnswerValueIdent BIGINT NULL,
	EntityProjectEntityAnswerIdent BIGINT NULL,
	Name1 VARCHAR(MAX) NULL ,
	Value1 VARCHAR(MAX) NULL ,
	Active BIT,

	AddDateTime DATETIME,
	AddASUserIdent BIGINT
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityProjectEntityAnswerValueHistory_Ident ON dbo.EntityProjectEntityAnswerValueHistory(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityProjectEntityAnswerValueHistory_EntityProjectEntityAnswerValue ON EntityProjectEntityAnswerValueHistory(EntityProjectEntityAnswerValueIdent)
GO

CREATE NONCLUSTERED INDEX idx_EntityProjectEntityAnswerValueHistory_EntityProjectEntityAnswerIdent ON EntityProjectEntityAnswerValueHistory(EntityProjectEntityAnswerIdent)
INCLUDE (Name1, Value1, AddDateTime)
GO

