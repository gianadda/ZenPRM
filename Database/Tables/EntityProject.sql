IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityProject') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityProject

GO

CREATE TABLE EntityProject (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	EntityIdent BIGINT NULL ,
	Name1 NVARCHAR(MAX) NULL,
	DueDate SMALLDATETIME NULL ,	
	PrivateProject BIT NULL, 
	ProjectManagerEntityIdent BIGINT NULL,
	Archived BIT NULL, 
	ArchivedASUserIdent BIGINT NULL ,
	ArchivedDateTime SMALLDATETIME NULL ,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT,
	ShowOnProfile BIT,
	IncludeEntireNetwork BIT,
	AllowOpenRegistration BIT,
	ProjectGUID UNIQUEIDENTIFIER
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityProject_Ident ON dbo.EntityProject(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityProject_EntityIdent ON dbo.EntityProject(EntityIdent) 
GO


CREATE NONCLUSTERED INDEX idx_EntityProject_ProjectGUID ON dbo.EntityProject(ProjectGUID) 
GO
