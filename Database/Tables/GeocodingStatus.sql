IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'GeocodingStatus') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE GeocodingStatus
GO

CREATE TABLE GeocodingStatus (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	Name1 NVARCHAR(150) NULL ,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_GeocodingStatus_Ident ON GeocodingStatus(Ident) --NO FILL FACTOR FOR IDENTITY DATA TYPE
GO

SET IDENTITY_INSERT dbo.GeocodingStatus ON

INSERT INTO GeocodingStatus(
	Ident,
	Name1,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	Ident = 0,
	Name1 = 'Needs Geocoding',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Ident = 1,
	Name1 = 'Geocoding Complete',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Ident = 2,
	Name1 = 'Geocoding Failed',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Ident = 3,
	Name1 = 'Manually Excluded / Queued',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1

SET IDENTITY_INSERT dbo.GeocodingStatus OFF