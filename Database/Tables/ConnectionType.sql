IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'ConnectionType') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE ConnectionType
GO

CREATE TABLE ConnectionType (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	Name1 NVARCHAR(150) NULL ,
	ReverseName1 NVARCHAR(150) NULL ,
	FromEntityTypeIdent BIGINT NULL ,
	ToEntityTypeIdent BIGINT NULL ,
	IncludeInNetwork BIT NULL ,
	Delegate BIT NULL ,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_ConnectionType_Ident ON ConnectionType(Ident) --NO FILL FACTOR FOR IDENTITY DATA TYPE
GO
CREATE NONCLUSTERED INDEX idx_ConnectionType_Name1 ON ConnectionType(Name1) 
GO

CREATE NONCLUSTERED INDEX idx_ConnectionType_CoverIndex ON ConnectionType(FromEntityTypeIdent, ToEntityTypeIdent, IncludeInNetwork, Delegate, Active) 
INCLUDE (Name1, ReverseName1)
GO

INSERT INTO ConnectionType(
	Name1,
	ReverseName1,
	IncludeInNetwork,
	FromEntityTypeIdent ,
	ToEntityTypeIdent ,
	Delegate ,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	Name1 = 'is a contact for',
	ReverseName1 = 'has a contact of',
	IncludeInNetwork = 0,
	FromEntityTypeIdent = 6,
	ToEntityTypeIdent = 2,
	Delegate = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Name1 = 'is a contact for',
	ReverseName1 = 'has a contact of',
	IncludeInNetwork = 0,
	FromEntityTypeIdent = 6,
	ToEntityTypeIdent = 3,
	Delegate = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Name1 = 'is a contact for',
	ReverseName1 = 'has a contact of',
	IncludeInNetwork = 0,
	FromEntityTypeIdent = 6,
	ToEntityTypeIdent = 4,
	Delegate = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Name1 = 'is an IT contact for',
	ReverseName1 = 'has an IT contact of',
	IncludeInNetwork = 0,
	FromEntityTypeIdent = 5,
	ToEntityTypeIdent = 2,
	Delegate = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Name1 = 'is an IT contact for',
	ReverseName1 = 'has an IT contact of',
	IncludeInNetwork = 0,
	FromEntityTypeIdent = 5,
	ToEntityTypeIdent = 3,
	Delegate = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Name1 = 'is an IT contact for',
	ReverseName1 = 'has an IT contact of',
	IncludeInNetwork = 0,
	FromEntityTypeIdent = 5,
	ToEntityTypeIdent = 4,
	Delegate = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Name1 = 'is a subsidiary of',
	ReverseName1 = 'has a subsidiary of',
	IncludeInNetwork = 0,
	FromEntityTypeIdent = 4,
	ToEntityTypeIdent = 2,
	Delegate = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Name1 = 'is in network of',
	ReverseName1 = 'is part of the network of',
	IncludeInNetwork = 1,
	FromEntityTypeIdent = 3,
	ToEntityTypeIdent = 2,
	Delegate = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Name1 = 'is delegate of',
	ReverseName1 = 'is a delegate for',
	IncludeInNetwork = 0,
	FromEntityTypeIdent = 3,
	ToEntityTypeIdent = 2,
	Delegate = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Name1 = 'has a shared address with',
	ReverseName1 = 'has a shared address with',
	IncludeInNetwork = 0,
	FromEntityTypeIdent = 3,
	ToEntityTypeIdent = 2,
	Delegate = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Name1 = 'has a shared address with',
	ReverseName1 = 'has a shared address with',
	IncludeInNetwork = 0,
	FromEntityTypeIdent = 2,
	ToEntityTypeIdent = 3,
	Delegate = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Name1 = 'has a shared address with',
	ReverseName1 = 'has a shared address with',
	IncludeInNetwork = 0,
	FromEntityTypeIdent = 2,
	ToEntityTypeIdent = 2,
	Delegate = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	Name1 = 'has a shared address with',
	ReverseName1 = 'has a shared address with',
	IncludeInNetwork = 0,
	FromEntityTypeIdent = 3,
	ToEntityTypeIdent = 3,
	Delegate = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

GO

SELECT 
	fromET.Ident,
	fromET.Name1,
	CT.Ident,
	CT.Name1,
	toET.Ident,
	toET.Name1
FROM 
	ConnectionType CT WITH (NOLOCK)
	INNER JOIN
	EntityType fromET WITH (NOLOCK)
		ON CT.FromEntityTypeIdent = fromET.Ident
	INNER JOIN
	EntityType toET WITH (NOLOCK)
		ON CT.ToEntityTypeIdent = toET.Ident