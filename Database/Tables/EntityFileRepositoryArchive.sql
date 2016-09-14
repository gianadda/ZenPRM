IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityFileRepositoryArchive') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityFileRepositoryArchive

GO

CREATE TABLE EntityFileRepositoryArchive (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	EntityIdent BIGINT NULL ,
	EntityFileRepositoryAnswerIdent BIGINT NULL,
	DeleteASUserIdent BIGINT NULL ,	
	DeleteDateTime SMALLDATETIME NULL 
)

CREATE UNIQUE CLUSTERED INDEX idx_EEntityFileRepositoryArchive_Ident ON dbo.EntityFileRepositoryArchive(Ident) 
GO
CREATE NONCLUSTERED INDEX idx_EntityFileRepositoryArchive_EntityIdent ON dbo.EntityFileRepositoryArchive(EntityIdent) 
GO
CREATE NONCLUSTERED INDEX idx_EntityFileRepositoryArchive_EntityFileRepositoryAnswerIdent ON dbo.EntityFileRepositoryArchive(EntityFileRepositoryAnswerIdent) 
GO

