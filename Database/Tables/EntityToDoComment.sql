IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityToDoComment') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityToDoComment

GO

CREATE TABLE EntityToDoComment (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	EntityToDoIdent BIGINT NULL ,
	CommentText NVARCHAR(MAX) NULL,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityToDoComment_Ident ON dbo.EntityToDoComment(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityToDoComment_EntityToDoIdent ON dbo.EntityToDoComment(EntityToDoIdent) 
GO
