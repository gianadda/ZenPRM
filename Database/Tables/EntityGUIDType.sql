-- **************************************************************************************************
-- Table:EntityGUIDType
-- **************************************************************************************************
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityGUIDType') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityGUIDType
GO

CREATE TABLE EntityGUIDType (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	Name1 NVARCHAR(100) NULL,
	Desc1 NVARCHAR(250) NULL,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityGUIDType_Ident ON dbo.EntityGUIDType(Ident) 
GO

INSERT INTO EntityGUIDType(
	Name1,
	Desc1,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	Name1 = 'Public Map',
	Desc1 = 'This entity Guid allows access to take the entities network and map the data',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

GO