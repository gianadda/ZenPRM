IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'Entity') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE Entity
GO

CREATE TABLE Entity (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	EntityTypeIdent BIGINT NULL,

	FullName AS CASE OrganizationName 
					WHEN '' THEN [FirstName] + ' ' + [LastName] 
					ELSE OrganizationName
					END PERSISTED,

	DisplayName AS CASE OrganizationName 
					WHEN '' THEN [LastName] + ', ' +  [FirstName]
					ELSE OrganizationName
					END PERSISTED,

	--Profile Info
	NPI VARCHAR (500) ,

	--Org info
	DBA NVARCHAR(MAX) NULL ,
	OrganizationName NVARCHAR(MAX) NULL ,

	--Person Info
	Prefix NVARCHAR (MAX) NULL,
	FirstName NVARCHAR(MAX) NULL ,
	MiddleName NVARCHAR(MAX) NULL ,
	LastName NVARCHAR(MAX) NULL ,
	Suffix NVARCHAR(MAX) NULL ,
	Title NVARCHAR (MAX) NULL,
	
	MedicalSchool NVARCHAR (MAX) NULL,
	SoleProvider BIT NULL,
	AcceptingNewPatients BIT NULL,

	GenderIdent BIGINT NULL ,

	Role1 NVARCHAR (MAX) NULL,	
	Version1 NVARCHAR (MAX) NULL,
	PCMHStatusIdent BIGINT NULL ,
	
	PrimaryAddress1 NVARCHAR (MAX) NULL,
	PrimaryAddress2 NVARCHAR (MAX) NULL,
	PrimaryAddress3 NVARCHAR (MAX) NULL,
	PrimaryCity NVARCHAR (MAX) NULL,
	PrimaryStateIdent BIGINT NULL,
	PrimaryZip NVARCHAR (MAX) NULL,
	PrimaryCounty NVARCHAR (MAX) NULL,
	
	PrimaryPhone NVARCHAR (MAX) NULL,
	PrimaryPhoneExtension NVARCHAR (MAX) NULL,
	PrimaryPhone2 NVARCHAR (MAX) NULL,
	PrimaryPhone2Extension NVARCHAR (MAX) NULL,
	PrimaryFax NVARCHAR (MAX) NULL,
	PrimaryFax2 NVARCHAR (MAX) NULL,

	MailingAddress1 NVARCHAR (MAX) NULL,
	MailingAddress2 NVARCHAR (MAX) NULL,
	MailingAddress3 NVARCHAR (MAX) NULL,
	MailingCity NVARCHAR (MAX) NULL,
	MailingStateIdent BIGINT NULL,
	MailingZip NVARCHAR (MAX) NULL,
	MailingCounty NVARCHAR (MAX) NULL,
	
	PracticeAddress1 NVARCHAR (MAX) NULL,
	PracticeAddress2 NVARCHAR (MAX) NULL,
	PracticeAddress3 NVARCHAR (MAX) NULL,
	PracticeCity NVARCHAR (MAX) NULL,
	PracticeStateIdent BIGINT NULL,
	PracticeZip NVARCHAR (MAX) NULL,
	PracticeCounty NVARCHAR (MAX) NULL,
	
	ProfilePhoto NVARCHAR (MAX) NULL,
	Website NVARCHAR (MAX) NULL,

	PrescriptionLicenseNumber NVARCHAR(MAX) NULL,
	PrescriptionLicenseNumberExpirationDate SMALLDATETIME NULL,
	DEANumber NVARCHAR(MAX) NULL,
	DEANumberExpirationDate SMALLDATETIME NULL,
	TaxIDNumber NVARCHAR(MAX) NULL ,
	TaxIDNumberExpirationDate SMALLDATETIME,
	
	
	MedicareUPIN NVARCHAR(MAX) NULL,
	CAQHID NVARCHAR(MAX) NULL,
	MeaningfulUseIdent BIGINT NULL,
	EIN NVARCHAR(MAX) NULL,

	--Geo-Code info
	Latitude DECIMAL(20,8) DEFAULT '0.00000000',
	Longitude DECIMAL(20,8) DEFAULT '0.00000000',
	Region NVARCHAR (MAX) , -- Need to determnine how we can populate this, but it would be nice for the "limmited profile"
	GeoLocation GEOGRAPHY,
	GeocodingStatusIdent BIGINT,

	Customer BIT NULL,
	Registered AS CASE Username 
				WHEN '' THEN CAST(0 AS BIT)
				ELSE CAST(1 AS BIT)
				END PERSISTED,
	ExternalLogin BIT NULL,

	--Generic ASUser Columns
	Username NVARCHAR(75) NULL,
	MustChangePassword BIT NULL,
	Password1 NVARCHAR(MAX) NULL,
	PasswordSalt NVARCHAR(200) NULL,
	SystemRoleIdent BIGINT NULL,
	BirthDate SMALLDATETIME NULL,
	LastPasswordChangedDate SMALLDATETIME NULL,
	FailedLoginCount BIGINT NULL,
	LastLoginAttempted DATETIME NULL,
	LastSuccessfulLogin SMALLDATETIME NULL,
	LockedTime SMALLDATETIME NULL,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL ,
	LockSessionIdent BIGINT NULL ,
	LockTime SMALLDATETIME NULL,
	IsLocked BIT NULL 
	
	CONSTRAINT PK_Entity_Ident PRIMARY KEY CLUSTERED (Ident)
)

CREATE NONCLUSTERED INDEX idx_Entity_Username ON Entity(Username) 
GO
CREATE NONCLUSTERED INDEX idx_Entity_NPI ON Entity(NPI)
GO
CREATE NONCLUSTERED INDEX idx_Entity_SearchCoveringIndex ON Entity(EntityTypeIdent,Active)
INCLUDE (Ident,GeoLocation,Latitude, Longitude, DisplayName, FullName,NPI,OrganizationName,FirstName,LastName)
GO
CREATE NONCLUSTERED INDEX idx_Entity_GeocodingStatusIdent ON Entity(GeocodingStatusIdent)
GO

CREATE NONCLUSTERED INDEX idx_Entity_ZenTeam ON Entity(SystemRoleIdent,Active)
GO

CREATE SPATIAL INDEX sidx_Entity_GeoLocation ON Entity(GeoLocation)  USING GEOGRAPHY_AUTO_GRID
   WITH
   (
		 CELLS_PER_OBJECT = 1024 
   );
GO


CREATE INDEX [ix_Entity_PrimaryStateIdent_Active_includes] ON [ZenPRM].[dbo].[Entity] ([PrimaryStateIdent], [Active])  INCLUDE ([PrimaryAddress1], [PrimaryCity], [PrimaryZip], [Customer], [GeoLocation]) WITH (FILLFACTOR=100);
GO

--DROP INDEX idx_Entity_LatLongSearchCoveringIndex  ON Entity
GO
CREATE NONCLUSTERED INDEX idx_Entity_LatLongSearchCoveringIndex ON Entity(Latitude, Longitude)
INCLUDE (Ident, Active, EntityTypeIdent, GeoLocation, DisplayName, FullName,NPI,OrganizationName,FirstName,LastName,
		PrimaryAddress1,
		PrimaryAddress2,
		PrimaryAddress3,
		PrimaryCity,
		PrimaryStateIdent ,
		PrimaryZip,
		ProfilePhoto,
		GenderIdent,
		AcceptingNewPatients,
		SoleProvider,
		Registered)
GO