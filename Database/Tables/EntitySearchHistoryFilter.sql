-- **************************************************************************************************
-- Table:EntitySearchHistoryFilter
-- Description: Stores the searched filters for a given entity search
-- **************************************************************************************************
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntitySearchHistoryFilter') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntitySearchHistoryFilter
GO

CREATE TABLE EntitySearchHistoryFilter (
	Ident BIGINT IDENTITY(1,1) NOT NULL,
	EntitySearchHistoryIdent BIGINT NULL,
	EntitySearchFilterTypeIdent BIGINT NULL,
	EntitySearchOperatorIdent BIGINT NULL,
	EntityProjectRequirementIdent BIGINT NULL,
	ReferenceIdent BIGINT NULL,
	SearchValue NVARCHAR(MAX) NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_EntitySearchHistoryFilter_Ident ON dbo.EntitySearchHistoryFilter(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntitySearchHistoryFilter_EntitySearchHistoryIdent ON dbo.EntitySearchHistoryFilter(EntitySearchHistoryIdent) 
GO

