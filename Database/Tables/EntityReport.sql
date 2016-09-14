IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityReport') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityReport

GO

CREATE TABLE EntityReport (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	EntityIdent BIGINT NULL ,
	ReportTypeIdent BIGINT NULL,
	Name1 NVARCHAR(MAX) NULL,
	Desc1 NVARCHAR(MAX) NULL,
	TemplateHTML NVARCHAR(MAX) NULL,
	PrivateReport BIT NULL,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityReport_Ident ON dbo.EntityReport(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityReport_EntityIdent ON dbo.EntityReport(EntityIdent) 
GO

