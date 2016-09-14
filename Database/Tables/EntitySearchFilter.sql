-- **************************************************************************************************
-- Table:EntitySearchFilter
-- Description: Stores the searched filters for a saved entity search
-- **************************************************************************************************
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntitySearchFilter') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntitySearchFilter
GO

CREATE TABLE EntitySearchFilter (
	Ident BIGINT IDENTITY(1,1) NOT NULL,
	EntitySearchIdent BIGINT NULL,
	EntitySearchFilterTypeIdent BIGINT NULL,
	EntitySearchOperatorIdent BIGINT NULL,
	EntityProjectRequirementIdent BIGINT NULL,
	ReferenceIdent BIGINT NULL,
	SearchValue NVARCHAR(MAX) NULL,
	Active BIT NULL,
	AddASUserIdent BIGINT NULL,
	AddDateTime DATETIME NULL,
	EditASUserIdent BIGINT NULL,
	EditDateTime DATETIME NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_EntitySearchFilter_Ident ON dbo.EntitySearchFilter(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntitySearchFilter_EntitySearchIdent ON dbo.EntitySearchFilter(EntitySearchIdent) 
GO

