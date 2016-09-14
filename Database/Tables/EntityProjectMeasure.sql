IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityProjectMeasure') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityProjectMeasure

GO

CREATE TABLE EntityProjectMeasure (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	EntityIdent BIGINT NULL,
	Name1 NVARCHAR(MAX) NULL,
	Desc1 NVARCHAR(MAX) NULL,
	EntitySearchIdent BIGINT NULL,
	MeasureTypeIdent BIGINT NULL,
	Question1EntityProjectRequirementIdent BIGINT NULL,
	Question2EntityProjectRequirementIdent BIGINT NULL,
	TargetValue MONEY NULL,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT	NULL,
	Recalculate BIT NULL,
	LastRecalculateDate DATETIME NULL,
	Question1Value MONEY NULL,
	Question2Value MONEY NULL,
	TotalResourcesComplete BIGINT NULL,
	TotalResourcesAvailable BIGINT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityProjectMeasure_Ident ON dbo.EntityProjectMeasure(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityProjectMeasure_EntityIdent ON dbo.EntityProjectMeasure(EntityIdent) 
GO

CREATE NONCLUSTERED INDEX idx_EntityProjectMeasure_EntityProjectRequirementIdent ON dbo.EntityProjectMeasure(Question1EntityProjectRequirementIdent, Question2EntityProjectRequirementIdent) 
GO

CREATE NONCLUSTERED INDEX idx_EntityProjectMeasure_Recalculate ON dbo.EntityProjectMeasure(Recalculate)
INCLUDE (Ident, LastRecalculateDate)
GO

CREATE NONCLUSTERED INDEX idx_EntityProjectMeasure_EntitySearchIdent ON dbo.EntityProjectMeasure(EntitySearchIdent) 
GO
