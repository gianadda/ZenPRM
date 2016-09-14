
DROP TRIGGER trg_EntityASUserActivityLog
GO 
CREATE TRIGGER trg_EntityASUserActivityLog ON Entity FOR INSERT, UPDATE
AS

-- we need to make sure something is actually edited
-- this will be null if we have a UPDATE with a WHERE clause that doesnt trigger an update
IF EXISTS(SELECT * FROM inserted)
BEGIN

	DECLARE @intActivityTypeEditProfileIdent BIGINT
	DECLARE @intASUserActivityIdent BIGINT
	DECLARE @intRecordIdent BIGINT
	DECLARE @intEditASUserIdent BIGINT
	DECLARE @intAddASUserIdent BIGINT
	DECLARE @intActivityIdent BIGINT
	DECLARE @nvrSQL NVARCHAR(MAX)
	DECLARE @varIdent NVARCHAR(500)
	DECLARE @dteGetDate DATETIME

	SET @dteGetDate = dbo.ufnGetMyDate()
	
	SET @intActivityTypeEditProfileIdent = dbo.ufnActivityTypeEditProfile()

	SELECT 
		@intRecordIdent = Ident ,
		@intEditASUserIdent = EditASUserIdent,
		@intAddASUserIdent = AddASUserIdent
	FROM
		inserted
	
	--If there is no deleted, then it's an Add
	IF NOT EXISTS (SELECT * FROM deleted)
	BEGIN

		SET @intActivityTypeEditProfileIdent = dbo.ufnActivityTypeAddProfile()

		INSERT INTO ASUserActivity(
			ASUserIdent,
			ActivityTypeIdent,
			ActivityDateTime,
			ActivityDescription,
			ClientIPAddress,
			RecordIdent,
			CustomerEntityIdent,
			UpdatedEntityIdent
		)
		SELECT
			ASUserIdent = @intAddASUserIdent,
			ActivityTypeIdent = AT.Ident,
			ActivityDateTime = @dteGetDate,
			ActivityDescription = CASE ceNew.FullName 
									WHEN '' THEN REPLACE(REPLACE(AT.Desc1,'@@Name',U.FullName),'@@Entity',ceNew.NPI + '''s')  
									ELSE REPLACE(REPLACE(AT.Desc1,'@@Name',U.FullName),'@@Entity',ceNew.FullName  + '''s') 
								END,
			ClientIPAddress = '', -- unobtainable at this point
			RecordIdent = @intRecordIdent,
			CustomerEntityIdent = 0,
			UpdatedEntityIdent = @intRecordIdent
		FROM
			ActivityType AT WITH (NOLOCK)
			INNER JOIN
			ASUser U WITH (NOLOCK)
				ON U.Ident = @intAddASUserIdent
			INNER JOIN
			Entity E WITH (NOLOCK)
				ON E.Ident = @intRecordIdent
			INNER JOIN
			inserted ceNew WITH (NOLOCK)
				ON ceNew.Ident = E.Ident
		WHERE
			AT.Ident = @intActivityTypeEditProfileIdent

		SET @intASUserActivityIdent = SCOPE_IDENTITY()

	END

		
	INSERT INTO ASUserActivity(
		ASUserIdent,
		ActivityTypeIdent,
		ActivityDateTime,
		ActivityDescription,
		ClientIPAddress,
		RecordIdent,
		CustomerEntityIdent,
		UpdatedEntityIdent
	)
	SELECT
		ASUserIdent = @intEditASUserIdent,
		ActivityTypeIdent = AT.Ident,
		ActivityDateTime = @dteGetDate,
		ActivityDescription = CASE
								--0	N/A
								--1	Male
								--2	Female
								WHEN @intEditASUserIdent = @intRecordIdent AND E.GenderIdent = 0 THEN REPLACE(REPLACE(AT.Desc1,'@@Name',U.FullName),'@@Entity','their')
								WHEN @intEditASUserIdent = @intRecordIdent AND E.GenderIdent = 1 THEN REPLACE(REPLACE(AT.Desc1,'@@Name',U.FullName),'@@Entity','his')
								WHEN @intEditASUserIdent = @intRecordIdent AND E.GenderIdent = 2 THEN REPLACE(REPLACE(AT.Desc1,'@@Name',U.FullName),'@@Entity','her')
								ELSE REPLACE(REPLACE(AT.Desc1,'@@Name',U.FullName),'@@Entity',ceNew.Fullname + '''s')
								END,
		ClientIPAddress = '', -- unobtainable at this point
		RecordIdent = @intRecordIdent,
		CustomerEntityIdent = 0,
		UpdatedEntityIdent = @intRecordIdent
	FROM
		ActivityType AT WITH (NOLOCK)
		INNER JOIN
		ASUser U WITH (NOLOCK)
			ON U.Ident = @intEditASUserIdent
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = @intRecordIdent
		INNER JOIN
		inserted ceNew WITH (NOLOCK)
			ON ceNew.Ident = E.Ident
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		AT.Ident = @intActivityTypeEditProfileIdent
		AND (
			ceNew.FullName <> ceOld.FullName
			OR ceNew.NPI <> ceOld.NPI
			OR ceNew.DBA <> ceOld.DBA
			OR ceNew.OrganizationName <> ceOld.OrganizationName
			OR ceNew.Prefix <> ceOld.Prefix
			OR ceNew.FirstName <> ceOld.FirstName
			OR ceNew.MiddleName <> ceOld.MiddleName
			OR ceNew.LastName <> ceOld.LastName
			OR ceNew.Suffix <> ceOld.Suffix
			OR ceNew.Title <> ceOld.Title
			OR ceNew.MedicalSchool <> ceOld.MedicalSchool
			OR ceNew.SoleProvider <> ceOld.SoleProvider
			OR ceNew.AcceptingNewPatients <> ceOld.AcceptingNewPatients
			OR ceNew.Role1 <> ceOld.Role1
			OR ceNew.Version1 <> ceOld.Version1
			OR ceNew.PrimaryAddress1 <> ceOld.PrimaryAddress1
			OR ceNew.PrimaryAddress2 <> ceOld.PrimaryAddress2
			OR ceNew.PrimaryAddress3 <> ceOld.PrimaryAddress3
			OR ceNew.PrimaryCity <> ceOld.PrimaryCity
			OR ceNew.PrimaryZip <> ceOld.PrimaryZip
			OR ceNew.PrimaryCounty <> ceOld.PrimaryCounty
			OR ceNew.PrimaryPhone <> ceOld.PrimaryPhone
			OR ceNew.PrimaryPhoneExtension <> ceOld.PrimaryPhoneExtension
			OR ceNew.PrimaryPhone2 <> ceOld.PrimaryPhone2
			OR ceNew.PrimaryPhone2Extension <> ceOld.PrimaryPhone2Extension
			OR ceNew.PrimaryFax <> ceOld.PrimaryFax
			OR ceNew.PrimaryFax2 <> ceOld.PrimaryFax2
			OR ceNew.MailingAddress1 <> ceOld.MailingAddress1
			OR ceNew.MailingAddress2 <> ceOld.MailingAddress2
			OR ceNew.MailingAddress3 <> ceOld.MailingAddress3
			OR ceNew.MailingCity <> ceOld.MailingCity
			OR ceNew.MailingZip <> ceOld.MailingZip
			OR ceNew.MailingCounty <> ceOld.MailingCounty
			OR ceNew.PracticeAddress1 <> ceOld.PracticeAddress1
			OR ceNew.PracticeAddress2 <> ceOld.PracticeAddress2
			OR ceNew.PracticeAddress3 <> ceOld.PracticeAddress3
			OR ceNew.PracticeCity <> ceOld.PracticeCity
			OR ceNew.PracticeZip <> ceOld.PracticeZip
			OR ceNew.PracticeCounty <> ceOld.PracticeCounty
			OR ceNew.ProfilePhoto <> ceOld.ProfilePhoto
			OR ceNew.Website <> ceOld.Website
			OR ceNew.PrescriptionLicenseNumber <> ceOld.PrescriptionLicenseNumber
			OR ceNew.PrescriptionLicenseNumberExpirationDate <> ceOld.PrescriptionLicenseNumberExpirationDate
			OR ceNew.DEANumber <> ceOld.DEANumber
			OR ceNew.DEANumberExpirationDate <> ceOld.DEANumberExpirationDate
			OR ceNew.TaxIDNumber <> ceOld.TaxIDNumber
			OR ceNew.TaxIDNumberExpirationDate <> ceOld.TaxIDNumberExpirationDate
			OR ceNew.MedicareUPIN <> ceOld.MedicareUPIN
			OR ceNew.CAQHID <> ceOld.CAQHID
			OR ceNew.EIN <> ceOld.EIN
			OR ceNew.Region <> ceOld.Region
			OR ceNew.BirthDate <> ceOld.BirthDate

			OR ceNew.EntityTypeIdent <> ceOld.EntityTypeIdent
			OR ceNew.GenderIdent <> ceOld.GenderIdent
			OR ceNew.PCMHStatusIdent <> ceOld.PCMHStatusIdent
			OR ceNew.PrimaryStateIdent <> ceOld.PrimaryStateIdent
			OR ceNew.MailingStateIdent <> ceOld.MailingStateIdent
			OR ceNew.PracticeStateIdent <> ceOld.PracticeStateIdent
			OR ceNew.MeaningfulUseIdent <> ceOld.MeaningfulUseIdent
		)

	SET @intASUserActivityIdent = SCOPE_IDENTITY()


	INSERT INTO ASUserActivityDetail (
		ASUserActivityIdent,
		FieldName,
		OldValue,
		NewValue
	)
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'NPI',
		OldValue = ceOld.NPI,
		NewValue = ceNew.NPI
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.NPI <> ceOld.NPI

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'DBA',
		OldValue = ceOld.DBA,
		NewValue = ceNew.DBA
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.DBA <> ceOld.DBA

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'OrganizationName',
		OldValue = ceOld.OrganizationName,
		NewValue = ceNew.OrganizationName
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.OrganizationName <> ceOld.OrganizationName

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Prefix',
		OldValue = ceOld.Prefix,
		NewValue = ceNew.Prefix
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.Prefix <> ceOld.Prefix

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'FirstName',
		OldValue = ceOld.FirstName,
		NewValue = ceNew.FirstName
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.FirstName <> ceOld.FirstName

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'MiddleName',
		OldValue = ceOld.MiddleName,
		NewValue = ceNew.MiddleName
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.MiddleName <> ceOld.MiddleName

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'LastName',
		OldValue = ceOld.LastName,
		NewValue = ceNew.LastName
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.LastName <> ceOld.LastName

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Suffix',
		OldValue = ceOld.Suffix,
		NewValue = ceNew.Suffix
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.Suffix <> ceOld.Suffix

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Title',
		OldValue = ceOld.Title,
		NewValue = ceNew.Title
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.Title <> ceOld.Title

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'MedicalSchool',
		OldValue = ceOld.MedicalSchool,
		NewValue = ceNew.MedicalSchool
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.MedicalSchool <> ceOld.MedicalSchool

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'SoleProvider',
		OldValue = CASE ceOld.SoleProvider WHEN 1 THEN 'Yes' ELSE 'No' END,
		NewValue = CASE ceNew.SoleProvider WHEN 1 THEN 'Yes' ELSE 'No' END
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.SoleProvider <> ceOld.SoleProvider

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'AcceptingNewPatients',
		OldValue = CASE ceOld.AcceptingNewPatients WHEN 1 THEN 'Yes' ELSE 'No' END,
		NewValue = CASE ceNew.AcceptingNewPatients WHEN 1 THEN 'Yes' ELSE 'No' END
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.AcceptingNewPatients <> ceOld.AcceptingNewPatients

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Role1',
		OldValue = ceOld.Role1,
		NewValue = ceNew.Role1
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.Role1 <> ceOld.Role1

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Version1',
		OldValue = ceOld.Version1,
		NewValue = ceNew.Version1
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.Version1 <> ceOld.Version1

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'PrimaryAddress1',
		OldValue = ceOld.PrimaryAddress1,
		NewValue = ceNew.PrimaryAddress1
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.PrimaryAddress1 <> ceOld.PrimaryAddress1

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'PrimaryAddress2',
		OldValue = ceOld.PrimaryAddress2,
		NewValue = ceNew.PrimaryAddress2
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.PrimaryAddress2 <> ceOld.PrimaryAddress2

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'PrimaryAddress3',
		OldValue = ceOld.PrimaryAddress3,
		NewValue = ceNew.PrimaryAddress3
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.PrimaryAddress3 <> ceOld.PrimaryAddress3

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'PrimaryCity',
		OldValue = ceOld.PrimaryCity,
		NewValue = ceNew.PrimaryCity
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.PrimaryCity <> ceOld.PrimaryCity

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'PrimaryZip',
		OldValue = ceOld.PrimaryZip,
		NewValue = ceNew.PrimaryZip
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.PrimaryZip <> ceOld.PrimaryZip

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'PrimaryCounty',
		OldValue = ceOld.PrimaryCounty,
		NewValue = ceNew.PrimaryCounty
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.PrimaryCounty <> ceOld.PrimaryCounty

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'PrimaryPhone',
		OldValue = ceOld.PrimaryPhone,
		NewValue = ceNew.PrimaryPhone
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.PrimaryPhone <> ceOld.PrimaryPhone

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'PrimaryPhoneExtension',
		OldValue = ceOld.PrimaryPhoneExtension,
		NewValue = ceNew.PrimaryPhoneExtension
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.PrimaryPhoneExtension <> ceOld.PrimaryPhoneExtension

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'PrimaryPhone2',
		OldValue = ceOld.PrimaryPhone2,
		NewValue = ceNew.PrimaryPhone2
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.PrimaryPhone2 <> ceOld.PrimaryPhone2

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'PrimaryPhone2Extension',
		OldValue = ceOld.PrimaryPhone2Extension,
		NewValue = ceNew.PrimaryPhone2Extension
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.PrimaryPhone2Extension <> ceOld.PrimaryPhone2Extension

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'PrimaryFax',
		OldValue = ceOld.PrimaryFax,
		NewValue = ceNew.PrimaryFax
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.PrimaryFax <> ceOld.PrimaryFax

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'PrimaryFax2',
		OldValue = ceOld.PrimaryFax2,
		NewValue = ceNew.PrimaryFax2
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.PrimaryFax2 <> ceOld.PrimaryFax2

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'MailingAddress1',
		OldValue = ceOld.MailingAddress1,
		NewValue = ceNew.MailingAddress1
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.MailingAddress1 <> ceOld.MailingAddress1

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'MailingAddress2',
		OldValue = ceOld.MailingAddress2,
		NewValue = ceNew.MailingAddress2
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.MailingAddress2 <> ceOld.MailingAddress2

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'MailingAddress3',
		OldValue = ceOld.MailingAddress3,
		NewValue = ceNew.MailingAddress3
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.MailingAddress3 <> ceOld.MailingAddress3

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'MailingCity',
		OldValue = ceOld.MailingCity,
		NewValue = ceNew.MailingCity
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.MailingCity <> ceOld.MailingCity

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'MailingZip',
		OldValue = ceOld.MailingZip,
		NewValue = ceNew.MailingZip
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.MailingZip <> ceOld.MailingZip

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'MailingCounty',
		OldValue = ceOld.MailingCounty,
		NewValue = ceNew.MailingCounty
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.MailingCounty <> ceOld.MailingCounty

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'PracticeAddress1',
		OldValue = ceOld.PracticeAddress1,
		NewValue = ceNew.PracticeAddress1
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.PracticeAddress1 <> ceOld.PracticeAddress1

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'PracticeAddress2',
		OldValue = ceOld.PracticeAddress2,
		NewValue = ceNew.PracticeAddress2
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.PracticeAddress2 <> ceOld.PracticeAddress2

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'PracticeAddress3',
		OldValue = ceOld.PracticeAddress3,
		NewValue = ceNew.PracticeAddress3
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.PracticeAddress3 <> ceOld.PracticeAddress3

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'PracticeCity',
		OldValue = ceOld.PracticeCity,
		NewValue = ceNew.PracticeCity
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.PracticeCity <> ceOld.PracticeCity

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'PracticeZip',
		OldValue = ceOld.PracticeZip,
		NewValue = ceNew.PracticeZip
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.PracticeZip <> ceOld.PracticeZip

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'PracticeCounty',
		OldValue = ceOld.PracticeCounty,
		NewValue = ceNew.PracticeCounty
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.PracticeCounty <> ceOld.PracticeCounty

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'ProfilePhoto',
		OldValue = ceOld.ProfilePhoto,
		NewValue = ceNew.ProfilePhoto
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.ProfilePhoto <> ceOld.ProfilePhoto

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Website',
		OldValue = ceOld.Website,
		NewValue = ceNew.Website
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.Website <> ceOld.Website

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'PrescriptionLicenseNumber',
		OldValue = ceOld.PrescriptionLicenseNumber,
		NewValue = ceNew.PrescriptionLicenseNumber
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.PrescriptionLicenseNumber <> ceOld.PrescriptionLicenseNumber

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'PrescriptionLicenseNumberExpirationDate',
		OldValue = CONVERT(VARCHAR(10),ceOld.PrescriptionLicenseNumberExpirationDate,101),
		NewValue = CONVERT(VARCHAR(10),ceNew.PrescriptionLicenseNumberExpirationDate, 101)
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.PrescriptionLicenseNumberExpirationDate <> ceOld.PrescriptionLicenseNumberExpirationDate

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'DEANumber',
		OldValue = ceOld.DEANumber,
		NewValue = ceNew.DEANumber
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.DEANumber <> ceOld.DEANumber

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'DEANumberExpirationDate',
		OldValue = CONVERT(VARCHAR(10),ceOld.DEANumberExpirationDate, 101),
		NewValue = CONVERT(VARCHAR(10),ceNew.DEANumberExpirationDate, 101)
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.DEANumberExpirationDate <> ceOld.DEANumberExpirationDate

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'TaxIDNumber',
		OldValue = ceOld.TaxIDNumber,
		NewValue = ceNew.TaxIDNumber
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.TaxIDNumber <> ceOld.TaxIDNumber

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'TaxIDNumberExpirationDate',
		OldValue =  CONVERT(VARCHAR(10),ceNew.TaxIDNumberExpirationDate, 101),
		NewValue =  CONVERT(VARCHAR(10),ceNew.TaxIDNumberExpirationDate, 101)
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.TaxIDNumberExpirationDate <> ceOld.TaxIDNumberExpirationDate

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'MedicareUPIN',
		OldValue = ceOld.MedicareUPIN,
		NewValue = ceNew.MedicareUPIN
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.MedicareUPIN <> ceOld.MedicareUPIN

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'CAQHID',
		OldValue = ceOld.CAQHID,
		NewValue = ceNew.CAQHID
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.CAQHID <> ceOld.CAQHID

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'EIN',
		OldValue = ceOld.EIN,
		NewValue = ceNew.EIN
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.EIN <> ceOld.EIN

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Region',
		OldValue = ceOld.Region,
		NewValue = ceNew.Region
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.Region <> ceOld.Region

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'BirthDate',
		OldValue = CONVERT(VARCHAR(10),ceOld.BirthDate, 101),
		NewValue = CONVERT(VARCHAR(10),ceNew.BirthDate, 101)
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.BirthDate <> ceOld.BirthDate



--Now Let's Do all of the Idents so we can get the "Name1" values from look up tables
	INSERT INTO ASUserActivityDetail (
		ASUserActivityIdent,
		FieldName,
		OldValue,
		NewValue
	)
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'EntityTypeIdent',
		OldValue = ltOld.Name1,
		NewValue = ltNew.Name1
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
		INNER JOIN
		EntityType ltNew WITH (NOLOCK)
			ON ceNew.EntityTypeIdent = ltNew.Ident
		INNER JOIN
		EntityType ltOld WITH (NOLOCK)
			ON ceOld.EntityTypeIdent = ltOld.Ident
	WHERE
		ceNew.EntityTypeIdent <> ceOld.EntityTypeIdent

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'GenderIdent',
		OldValue = ltOld.Name1,
		NewValue = ltNew.Name1
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
		INNER JOIN
		Gender ltNew WITH (NOLOCK)
			ON ceNew.GenderIdent = ltNew.Ident
		INNER JOIN
		Gender ltOld WITH (NOLOCK)
			ON ceOld.GenderIdent = ltOld.Ident
	WHERE
		ceNew.GenderIdent <> ceOld.GenderIdent

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'PCMHStatusIdent',
		OldValue = ltOld.Name1,
		NewValue = ltNew.Name1
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
		INNER JOIN
		PCMHStatus ltNew WITH (NOLOCK)
			ON ceNew.PCMHStatusIdent = ltNew.Ident
		INNER JOIN
		PCMHStatus ltOld WITH (NOLOCK)
			ON ceOld.PCMHStatusIdent = ltOld.Ident
	WHERE
		ceNew.PCMHStatusIdent <> ceOld.PCMHStatusIdent

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'PrimaryStateIdent',
		OldValue = ltOld.Name1,
		NewValue = ltNew.Name1
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
		INNER JOIN
		States ltNew WITH (NOLOCK)
			ON ceNew.PrimaryStateIdent = ltNew.Ident
		INNER JOIN
		States ltOld WITH (NOLOCK)
			ON ceOld.PrimaryStateIdent = ltOld.Ident
	WHERE
		ceNew.PrimaryStateIdent <> ceOld.PrimaryStateIdent

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'MailingStateIdent',
		OldValue = ltOld.Name1,
		NewValue = ltNew.Name1
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
		INNER JOIN
		States ltNew WITH (NOLOCK)
			ON ceNew.MailingStateIdent = ltNew.Ident
		INNER JOIN
		States ltOld WITH (NOLOCK)
			ON ceOld.MailingStateIdent = ltOld.Ident
	WHERE
		ceNew.MailingStateIdent <> ceOld.MailingStateIdent

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'PracticeStateIdent',
		OldValue = ltOld.Name1,
		NewValue = ltNew.Name1
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
		INNER JOIN
		States ltNew WITH (NOLOCK)
			ON ceNew.PracticeStateIdent = ltNew.Ident
		INNER JOIN
		States ltOld WITH (NOLOCK)
			ON ceOld.PracticeStateIdent = ltOld.Ident
	WHERE
		ceNew.PracticeStateIdent <> ceOld.PracticeStateIdent

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'MeaningfulUseIdent',
		OldValue = ltOld.Name1,
		NewValue = ltNew.Name1
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
		INNER JOIN
		MeaningfulUse ltNew WITH (NOLOCK)
			ON ceNew.MeaningfulUseIdent = ltNew.Ident
		INNER JOIN
		MeaningfulUse ltOld WITH (NOLOCK)
			ON ceOld.MeaningfulUseIdent = ltOld.Ident
	WHERE
		ceNew.MeaningfulUseIdent <> ceOld.MeaningfulUseIdent

END

GO

