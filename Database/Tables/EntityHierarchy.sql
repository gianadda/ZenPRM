IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityHierarchy') 	
AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityHierarchy
GO

CREATE TABLE EntityHierarchy (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	EntityIdent BIGINT NULL,
	HierarchyTypeIdent BIGINT NULL ,
	FromEntityIdent BIGINT NULL ,
	ToEntityIdent BIGINT NULL ,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityHierarchy_Ident ON EntityHierarchy(Ident) --NO FILL FACTOR FOR IDENTITY DATA TYPE
GO
CREATE NONCLUSTERED INDEX idx_EntityHierarchy_EntityIdent ON EntityHierarchy(EntityIdent) 
GO
CREATE NONCLUSTERED INDEX idx_EntityHierarchy_FromEntityIdent ON EntityHierarchy(FromEntityIdent) 
GO
CREATE NONCLUSTERED INDEX idx_EntityHierarchy_ToEntityIdent ON EntityHierarchy(ToEntityIdent) 
GO
CREATE NONCLUSTERED INDEX idx_EntityHierarchy_SearchIndex ON EntityHierarchy(HierarchyTypeIdent, FromEntityIdent,ToEntityIdent,Active)
GO