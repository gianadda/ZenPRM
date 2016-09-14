IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntitySearchFilterType') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntitySearchFilterType
GO

CREATE TABLE EntitySearchFilterType (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	Name1 NVARCHAR(150) NULL ,
	ReferenceTable NVARCHAR(150) NULL,
	ReferenceColumn NVARCHAR(150) NULL,
	BitValue BIT NULL,
	ProjectSpecific BIT NULL,
	HierarchySpecific BIT NULL,
	EntityFilter BIT NULL,
	EntityChildFilter BIT NULL,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_EntitySearchFilterType_Ident ON EntitySearchFilterType(Ident) --NO FILL FACTOR FOR IDENTITY DATA TYPE
GO

SET IDENTITY_INSERT dbo.EntitySearchFilterType ON

INSERT INTO EntitySearchFilterType(
	Ident,
	Name1,
	ReferenceTable,
	ReferenceColumn,
	BitValue,
	ProjectSpecific,
	HierarchySpecific,
	EntityFilter,
	EntityChildFilter,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	Ident = 1,
	Name1 = 'Project Data',
	ReferenceTable = '',
	ReferenceColumn = '',
	BitValue = 0,
	ProjectSpecific = 1,
	HierarchySpecific = 0,
	EntityFilter = 0,
	EntityChildFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 2,
	Name1 = 'Resource Type',
	ReferenceTable = 'EntityType',
	ReferenceColumn = 'EntityTypeIdent',
	BitValue = 0,
	ProjectSpecific = 0,
	HierarchySpecific = 0,
	EntityFilter = 1,
	EntityChildFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 3,
	Name1 = 'Specialty',
	ReferenceTable = 'Speciality',
	ReferenceColumn = '',
	BitValue = 0,
	ProjectSpecific = 0,
	HierarchySpecific = 0,
	EntityFilter = 0,
	EntityChildFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 4,
	Name1 = 'Accepting New Patients',
	ReferenceTable = '',
	ReferenceColumn = 'AcceptingNewPatients',
	BitValue = 1,
	ProjectSpecific = 0,
	HierarchySpecific = 0,
	EntityFilter = 1,
	EntityChildFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 5,
	Name1 = 'Sole Provider',
	ReferenceTable = '',
	ReferenceColumn = 'SoleProvider',
	BitValue = 1,
	ProjectSpecific = 0,
	HierarchySpecific = 0,
	EntityFilter = 1,
	EntityChildFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 6,
	Name1 = 'Payor',
	ReferenceTable = 'Payor',
	ReferenceColumn = '',
	BitValue = 0,
	ProjectSpecific = 0,
	HierarchySpecific = 0,
	EntityFilter = 0,
	EntityChildFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 7,
	Name1 = 'Language',
	ReferenceTable = 'Language1',
	ReferenceColumn = '',
	BitValue = 0,
	ProjectSpecific = 0,
	HierarchySpecific = 0,
	EntityFilter = 0,
	EntityChildFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 8,
	Name1 = 'Gender',
	ReferenceTable = 'Gender',
	ReferenceColumn = 'GenderIdent',
	BitValue = 0,
	ProjectSpecific = 0,
	HierarchySpecific = 0,
	EntityFilter = 1,
	EntityChildFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 9,
	Name1 = 'Degree',
	ReferenceTable = 'Degree',
	ReferenceColumn = '',
	BitValue = 0,
	ProjectSpecific = 0,
	HierarchySpecific = 0,
	EntityFilter = 0,
	EntityChildFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 10,
	Name1 = 'Registered User',
	ReferenceTable = '',
	ReferenceColumn = 'Registered',
	BitValue = 1,
	ProjectSpecific = 0,
	HierarchySpecific = 0,
	EntityFilter = 1,
	EntityChildFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 11,
	Name1 = 'Organization Structure',
	ReferenceTable = 'EntityHierarchy',
	ReferenceColumn = '',
	BitValue = 0,
	ProjectSpecific = 0,
	HierarchySpecific = 1,
	EntityFilter = 0,
	EntityChildFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Ident = 12,
	Name1 = 'Email',
	ReferenceTable = '',
	ReferenceColumn = '',
	BitValue = 0,
	ProjectSpecific = 0,
	HierarchySpecific = 0,
	EntityFilter = 0,
	EntityChildFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

SET IDENTITY_INSERT dbo.EntitySearchFilterType OFF

GO