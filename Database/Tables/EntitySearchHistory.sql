-- **************************************************************************************************
-- Table:EntitySearchHistory
-- Description: Stores the search history of users on the advanced search
-- **************************************************************************************************
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntitySearchHistory') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntitySearchHistory
GO

CREATE TABLE EntitySearchHistory (
	Ident BIGINT IDENTITY(1,1) NOT NULL,
	EntityIdent BIGINT NULL,
	SearchDateTime DATETIME NULL,
	GlobalSearch BIT NULL,
	SearchResultsReturned BIGINT NULL,
	Keyword NVARCHAR(MAX),
	Location NVARCHAR(MAX),
	Latitude DECIMAL(20,8),
	Longitude DECIMAL(20,8),
	DistanceInMiles INT
)

CREATE UNIQUE CLUSTERED INDEX idx_EntitySearchHistory_Ident ON dbo.EntitySearchHistory(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntitySearchHistory_EntityIdent ON dbo.EntitySearchHistory(EntityIdent) 
GO

CREATE NONCLUSTERED INDEX idx_EntitySearchHistory_SearchDateTime ON dbo.EntitySearchHistory(SearchDateTime) 
GO

