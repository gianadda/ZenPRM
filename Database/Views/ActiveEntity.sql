--Create view with schemabinding.
IF OBJECT_ID ('ActiveEntity', 'view') IS NOT NULL
DROP VIEW ActiveEntity ;
GO
CREATE VIEW ActiveEntity
WITH SCHEMABINDING
AS
    SELECT
		E.Ident,
		E.EntityTypeIdent,
		E.FullName,
		E.DisplayName,
		E.NPI,
		E.DBA,
		E.OrganizationName,
		E.Prefix,
		E.FirstName,
		E.MiddleName,
		E.LastName,
		E.Suffix,
		E.Title,
		E.MedicalSchool,
		E.SoleProvider,
		E.AcceptingNewPatients,
		E.GenderIdent,
		E.Role1,
		E.Version1,
		E.PCMHStatusIdent,
		E.PrimaryAddress1,
		E.PrimaryAddress2,
		E.PrimaryAddress3,
		E.PrimaryCity,
		E.PrimaryStateIdent,
		E.PrimaryZip,
		E.PrimaryCounty,
		E.PrimaryPhone,
		E.PrimaryPhoneExtension,
		E.PrimaryPhone2,
		E.PrimaryPhone2Extension,
		E.PrimaryFax,
		E.PrimaryFax2,
		E.MailingAddress1,
		E.MailingAddress2,
		E.MailingAddress3,
		E.MailingCity,
		E.MailingStateIdent,
		E.MailingZip,
		E.MailingCounty,
		E.PracticeAddress1,
		E.PracticeAddress2,
		E.PracticeAddress3,
		E.PracticeCity,
		E.PracticeStateIdent,
		E.PracticeZip,
		E.PracticeCounty,
		E.ProfilePhoto,
		E.Website,
		E.PrescriptionLicenseNumber,
		E.DEANumber,
		E.TaxIDNumber,
		E.MedicareUPIN,
		E.CAQHID,
		E.MeaningfulUseIdent,
		E.EIN,
		E.Latitude,
		E.Longitude,
		E.Region,
		E.Customer,
		E.Registered,
		CONVERT(NVARCHAR(10), E.BirthDate, 101) as [BirthDate],
		E.Active,
		E.GeoLocation,
		ET.Name1 as [EntityType],
		ET.IncludeInCNP as [IncludeInCNP],
		ET.Person as [Person]
	FROM
		dbo.Entity E 
		INNER JOIN
		dbo.EntityType ET 
			ON ET.Ident = E.EntityTypeIdent
	WHERE 
		E.Active = 1
		AND ET.IncludeInCNP = 1

GO

--Testing to use for FULLTEXT search
CREATE UNIQUE CLUSTERED INDEX idx_ActiveEntity_Ident ON ActiveEntity(Ident)
GO 


--CREATE UNIQUE CLUSTERED INDEX idx_ActiveEntity_Ident ON ActiveEntity(Latitude, Longitude, Ident) --NO FILL FACTOR FOR IDENTITY DATA TYPE
--GO 

CREATE NONCLUSTERED INDEX idx_ActiveEntity_SearchCoveringIndex ON ActiveEntity(EntityTypeIdent,Active)
INCLUDE (Ident,GeoLocation,Latitude, Longitude, DisplayName, FullName,NPI,OrganizationName,FirstName,LastName, EntityType, IncludeInCNP, Person)
GO

--DROP INDEX idx_ActiveEntity_LatLongSearchCoveringIndex ON ActiveEntity
GO
CREATE NONCLUSTERED INDEX idx_ActiveEntity_LatLongSearchCoveringIndex ON ActiveEntity(Ident, Latitude, Longitude)
INCLUDE (Active, EntityTypeIdent, GeoLocation, DisplayName, FullName,NPI,OrganizationName,FirstName,LastName,
		PrimaryAddress1,
		PrimaryAddress2,
		PrimaryAddress3,
		PrimaryCity,
		PrimaryStateIdent ,
		PrimaryZip,
		ProfilePhoto,
		GenderIdent,
		AcceptingNewPatients,
		SoleProvider, EntityType, IncludeInCNP, Person, Registered)
GO

--DROP INDEX idx_ActiveEntity_LatLongSearchCountIndex ON ActiveEntity
GO
CREATE NONCLUSTERED INDEX idx_ActiveEntity_LatLongSearchCountIndex ON ActiveEntity(Latitude, Longitude)
INCLUDE (Active, EntityTypeIdent, GeoLocation, DisplayName, FullName,NPI,OrganizationName,FirstName,LastName,
		PrimaryAddress1,
		PrimaryAddress2,
		PrimaryAddress3,
		PrimaryCity,
		PrimaryStateIdent ,
		PrimaryZip,
		ProfilePhoto,
		GenderIdent,
		AcceptingNewPatients,
		SoleProvider, EntityType, IncludeInCNP, Person, Registered)
GO




CREATE FULLTEXT CATALOG [ftx_ActiveEntity]WITH ACCENT_SENSITIVITY = OFF

GO

CREATE FULLTEXT INDEX ON ActiveEntity(CAQHID, DBA, DEANumber, EIN, EntityType, FirstName, DisplayName, FullName, LastName, MailingAddress1, MailingAddress2, MailingAddress3, MailingCity, MailingCounty, MailingZip, MiddleName, NPI, OrganizationName, 
PracticeAddress1, PracticeAddress2, PracticeAddress3, PracticeCity, PracticeCounty, PracticeZip, Prefix, PrescriptionLicenseNumber, PrimaryAddress1, PrimaryAddress2, PrimaryAddress3, PrimaryCity, PrimaryCounty, 
PrimaryFax, PrimaryPhone, PrimaryPhoneExtension, PrimaryZip, Suffix, TaxIDNumber, Title, Website) KEY INDEX idx_ActiveEntity_Ident ON ftx_ActiveEntity; 

ALTER FULLTEXT INDEX ON ActiveEntity ENABLE; 
GO 
ALTER FULLTEXT INDEX ON ActiveEntity START FULL POPULATION;