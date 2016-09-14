IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'RequirementType') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE RequirementType
GO

CREATE TABLE RequirementType (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	Name1 NVARCHAR(150) NULL ,
	TemplateName NVARCHAR(150) NULL ,
	DefaultData NVARCHAR(MAX) NULL ,
	HasOptions BIT NULL,
	AllowMultipleOptions BIT NULL,
	RequiresAnswer BIT NULL,
	IsFileUpload BIT NULL,
	EntitySearchDataTypeIdent BIGINT NULL,
	AllowEntityProjectMeasure BIT NULL,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_RequirementType_Ident ON RequirementType(Ident) --NO FILL FACTOR FOR IDENTITY DATA TYPE
GO
CREATE NONCLUSTERED INDEX idx_RequirementType_Name1 ON RequirementType(Name1) 
GO
