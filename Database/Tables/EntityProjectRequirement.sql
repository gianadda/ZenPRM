IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityProjectRequirement') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityProjectRequirement

GO

CREATE TABLE EntityProjectRequirement (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	EntityProjectIdent BIGINT NULL ,
	RequirementTypeIdent BIGINT NULL ,
	label NVARCHAR(MAX) NULL,
	Desc1 NVARCHAR(MAX) NULL,
	PlaceholderText NVARCHAR(MAX) NULL,
	HelpText NVARCHAR(MAX) NULL,
	Options NVARCHAR(MAX) NULL, --NOTE this will be a JSON Array like: [1,2,3]
	SortOrder INT NULL, 

	CreateToDoUponCompletion BIT NULL,
	ToDoTitle NVARCHAR(MAX) NULL,
	ToDoDesc1 NVARCHAR(MAX) NULL,
	ToDoDueDateNoOfDays INT NULL ,	
	ToDoAssigneeEntityIdent BIGINT NULL,

	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityProjectRequirement_Ident ON dbo.EntityProjectRequirement(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityProjectRequirement_EntityProjectIdent ON dbo.EntityProjectRequirement(EntityProjectIdent)
GO
