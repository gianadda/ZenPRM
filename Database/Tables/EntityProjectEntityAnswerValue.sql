IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityProjectEntityAnswerValue') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityProjectEntityAnswerValue

GO

CREATE TABLE EntityProjectEntityAnswerValue (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	EntityProjectEntityAnswerIdent BIGINT NULL ,
	Name1 VARCHAR(MAX) NULL ,
	Value1 VARCHAR(MAX) NULL ,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityProjectEntityAnswerValue_Ident ON dbo.EntityProjectEntityAnswerValue(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityProjectEntityAnswerValue_EntityProjectEntityAnswerIdent ON EntityProjectEntityAnswerValue(EntityProjectEntityAnswerIdent)
INCLUDE (Name1, Value1)
GO

