IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'HierarchyType') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE HierarchyType
GO

CREATE TABLE HierarchyType (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	Name1 NVARCHAR(150) NULL ,
	ReverseName1 NVARCHAR(150) NULL ,
	FromEntityIsPerson BIT NULL ,
	ToEntityIsPerson BIT NULL ,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_HierarchyType_Ident ON HierarchyType(Ident) --NO FILL FACTOR FOR IDENTITY DATA TYPE
GO
CREATE NONCLUSTERED INDEX idx_HierarchyType_CoverIndex ON HierarchyType(FromEntityIsPerson, ToEntityIsPerson, Active) 
INCLUDE (Name1, ReverseName1)
GO

INSERT INTO HierarchyType(
	Name1,
	ReverseName1,
	FromEntityIsPerson,
	ToEntityIsPerson,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	Name1 = 'Place of Work',
	ReverseName1 = 'Works at',
	FromEntityIsPerson = 0,
	ToEntityIsPerson = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	Name1 = 'Employee',
	ReverseName1 = 'Works for',
	FromEntityIsPerson = 0,
	ToEntityIsPerson = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	Name1 = 'Sub-Organization',
	ReverseName1 = 'Parent Organization',
	FromEntityIsPerson = 0,
	ToEntityIsPerson = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	Name1 = 'Member',
	ReverseName1 = 'Member of',
	FromEntityIsPerson = 0,
	ToEntityIsPerson = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

GO