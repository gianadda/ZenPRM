IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityProjectEntityAnswer') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityProjectEntityAnswer

GO

CREATE TABLE EntityProjectEntityAnswer (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	EntityProjectEntityIdent BIGINT NULL ,
	EntityProjectRequirementIdent BIGINT NULL ,

	ToDoGenerated BIT NULL,
	ToDoGeneratedDateTime DATETIME NULL,

	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityProjectEntityAnswer_Ident ON dbo.EntityProjectEntityAnswer(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityProjectEntityAnswer_EntityProjectEntityIdent ON dbo.EntityProjectEntityAnswer(EntityProjectEntityIdent) 
GO

CREATE NONCLUSTERED INDEX idx_EntityProjectEntityAnswer_EntityProjectRequirementIdent ON dbo.EntityProjectEntityAnswer(EntityProjectRequirementIdent) 
GO

CREATE NONCLUSTERED INDEX idx_EntityProjectEntityAnswer_CoverIndex ON dbo.EntityProjectEntityAnswer(EntityProjectEntityIdent,EntityProjectRequirementIdent, Active) 
GO
CREATE NONCLUSTERED INDEX idx_EntityProjectEntityAnswer_Active ON dbo.EntityProjectEntityAnswer(Active) 
INCLUDE (Ident ,EntityProjectEntityIdent, EntityProjectRequirementIdent)
GO