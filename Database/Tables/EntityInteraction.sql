IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityInteraction') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityInteraction

GO

CREATE TABLE EntityInteraction (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	FromEntityIdent BIGINT NULL ,
	ToEntityIdent BIGINT NULL ,
	InteractionText NVARCHAR(MAX) NULL,
	Important BIT,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityInteraction_Ident ON dbo.EntityInteraction(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityInteraction_FromEntityIdent ON dbo.EntityInteraction(FromEntityIdent) 
GO

CREATE NONCLUSTERED INDEX idx_EntityInteraction_ToEntityIdent ON dbo.EntityInteraction(ToEntityIdent) 
GO
