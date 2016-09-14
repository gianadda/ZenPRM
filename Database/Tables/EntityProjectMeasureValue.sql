IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityProjectMeasureValue') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityProjectMeasureValue
GO

CREATE TABLE EntityProjectMeasureValue (
	Ident BIGINT IDENTITY (1,1) ,
	EntityProjectMeasureIdent BIGINT ,
	Value1 NVARCHAR(MAX),
	ValueCount BIGINT,
	AddASUserIdent BIGINT,
	AddDateTime SMALLDATETIME,
	EditASUserIdent BIGINT,	
	EditDateTime SMALLDATETIME,
	Active BIT
)	

CREATE UNIQUE CLUSTERED INDEX idx_EntityProjectMeasureValue_Ident ON dbo.EntityProjectMeasureValue(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityProjectMeasureValue_EntityProjectMeasureIdent ON dbo.EntityProjectMeasureValue(EntityProjectMeasureIdent)
INCLUDE(Ident,Value1,ValueCount,Active)
GO