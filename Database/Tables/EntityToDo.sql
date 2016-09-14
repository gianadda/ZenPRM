IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityToDo') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityToDo

GO

CREATE TABLE EntityToDo (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	EntityIdent BIGINT NULL , --Customer that Owns the ToDo
	ToDoInitiatorTypeIdent BIGINT NULL , --(Inbound/Outbound)
	ToDoTypeIdent BIGINT NULL , --(Email, Phone, Fax)
	ToDoStatusIdent BIGINT NULL , --(Open, Pending, Closed)
	RegardingEntityIdent BIGINT NULL , --Entity that the ToDo is regarding
	AssigneeEntityIdent BIGINT NULL, -- Assignee
	Title NVARCHAR(MAX) NULL, --Subject
	Desc1 NVARCHAR(MAX) NULL, --Body/Description
	
	StartDate SMALLDATETIME NULL ,	
	DueDate SMALLDATETIME NULL ,	

	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityToDo_Ident ON dbo.EntityToDo(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityToDo_EntityIdent ON dbo.EntityToDo(EntityIdent)
GO

CREATE NONCLUSTERED INDEX idx_EntityToDo_RegardingEntityIdent ON dbo.EntityToDo(RegardingEntityIdent)
GO

CREATE NONCLUSTERED INDEX idx_EntityToDo_AssigneeEntityIdent ON dbo.EntityToDo(AssigneeEntityIdent) 
GO

CREATE NONCLUSTERED INDEX idx_EntityToDo_DueDate ON dbo.EntityToDo(DueDate) 
GO