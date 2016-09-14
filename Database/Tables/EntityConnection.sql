IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityConnection') 	
AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityConnection
GO

CREATE TABLE EntityConnection (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	ConnectionTypeIdent BIGINT NULL ,
	FromEntityIdent BIGINT NULL ,
	ToEntityIdent BIGINT NULL ,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityConnection_Ident ON EntityConnection(Ident) --NO FILL FACTOR FOR IDENTITY DATA TYPE
GO
CREATE NONCLUSTERED INDEX idx_EntityConnection_ConnectionTypeIdent ON EntityConnection(ConnectionTypeIdent) 
GO
CREATE NONCLUSTERED INDEX idx_EntityConnection_FromEntityIdent ON EntityConnection(FromEntityIdent) 
GO
CREATE NONCLUSTERED INDEX idx_EntityConnection_ToEntityIdent ON EntityConnection(ToEntityIdent) 
GO

CREATE NONCLUSTERED INDEX idx_EntityConnection_SearchIndex ON EntityConnection(ConnectionTypeIdent, FromEntityIdent,ToEntityIdent,Active)
GO

INSERT INTO EntityConnection(
	ConnectionTypeIdent,
	FromEntityIdent ,
	ToEntityIdent  ,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	ConnectionTypeIdent = 7, -- is a subsidiary of
	FromEntityIdent = 4,
	ToEntityIdent  =2,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	ConnectionTypeIdent = 8, -- is in network of
	FromEntityIdent = 3,
	ToEntityIdent  = 2,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	ConnectionTypeIdent = 4,
	FromEntityIdent = 5,
	ToEntityIdent = 2,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	ConnectionTypeIdent = 5,
	FromEntityIdent = 5,
	ToEntityIdent = 3,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	ConnectionTypeIdent = 6,
	FromEntityIdent = 5,
	ToEntityIdent = 4,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1


GO

SELECT 
	fromE.Ident,
	fromE.FullName,
	CT.Ident,
	CT.Name1,
	toE.Ident,
	toE.FullName
FROM 
	ConnectionType CT WITH (NOLOCK)
	INNER JOIN
	EntityConnection EC WITH (NOLOCK)
		ON CT.Ident = EC.ConnectionTypeIdent
	INNER JOIN
	Entity fromE WITH (NOLOCK)
		ON EC.FromEntityIdent = fromE.Ident
			AND CT.FromEntityTypeIdent = fromE.EntityTypeIdent
	INNER JOIN
	Entity toE WITH (NOLOCK)
		ON EC.ToEntityIdent = toE.Ident
			AND CT.ToEntityTypeIdent = toE.EntityTypeIdent
