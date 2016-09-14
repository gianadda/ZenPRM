IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityProjectMeasureRange') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityProjectMeasureRange

GO

CREATE TABLE EntityProjectMeasureRange (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	EntityProjectMeasureIdent BIGINT NULL ,
	Name1 NVARCHAR(MAX) NULL,
	Color NVARCHAR(50) NULL,
	RangeStartValue MONEY NULL,
	RangeEndValue MONEY NULL,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT	
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityProjectMeasureRange_Ident ON dbo.EntityProjectMeasureRange(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityProjectMeasureRange_EntityProjectMeasureIdent ON dbo.EntityProjectMeasureRange(EntityProjectMeasureIdent) 
INCLUDE (Ident, Name1, Color, RangeStartValue, RangeEndValue)
GO
