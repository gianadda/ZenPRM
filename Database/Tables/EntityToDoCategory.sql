-- **************************************************************************************************
-- Table:EntityToDoCategory
-- **************************************************************************************************
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityToDoCategory') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityToDoCategory
GO

CREATE TABLE EntityToDoCategory (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	EntityIdent BIGINT NULL, --Customer Ident
	Name1 NVARCHAR(100) NULL,
	IconClass NVARCHAR(MAX) NULL,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityToDoCategory_Ident ON dbo.EntityToDoCategory(Ident) 
GO
