-- **************************************************************************************************
-- Table:EntitySearch
-- Description: Saved searches for a given entity
-- **************************************************************************************************
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntitySearch') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntitySearch
GO

CREATE TABLE EntitySearch (
	Ident BIGINT IDENTITY(1,1) NOT NULL,
	EntityIdent BIGINT NULL,
	Name1 NVARCHAR(MAX) NULL,
	Desc1 NVARCHAR(MAX) NULL,
	Category NVARCHAR(MAX) NULL,
	BookmarkSearch BIT NULL,
	Keyword NVARCHAR(MAX) NULL,
	Location NVARCHAR(MAX) NULL,
	Latitude DECIMAL(20,8) NULL,
	Longitude DECIMAL(20,8) NULL,
	DistanceInMiles INT NULL,
	Active BIT NULL,
	AddASUserIdent BIGINT NULL,
	AddDateTime DATETIME NULL,
	EditASUserIdent BIGINT NULL,
	EditDateTime DATETIME NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_EntitySearch_Ident ON dbo.EntitySearch(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntitySearch_EntityIdent ON dbo.EntitySearch(EntityIdent) 
GO

