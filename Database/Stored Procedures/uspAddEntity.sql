IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntity') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntity
 GO
/* uspAddEntity
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspAddEntity]

	@intEntityTypeIdent BIGINT = 0, 
	@vcrNPI VARCHAR(MAX) = '', 
	@nvrDBA NVARCHAR(MAX) = '', 
	@nvrOrganizationName NVARCHAR(MAX) = '', 
	@nvrPrefix NVARCHAR(MAX) = '', 
	@nvrFirstName NVARCHAR(MAX) = '', 
	@nvrMiddleName NVARCHAR(MAX) = '', 
	@nvrLastName NVARCHAR(MAX) = '', 
	@nvrSuffix NVARCHAR(MAX) = '', 
	@nvrTitle NVARCHAR(MAX) = '', 
	@nvrMedicalSchool NVARCHAR(MAX) = '', 
	@bitSoleProvider BIT = False, 
	@bitAcceptingNewPatients BIT = False, 
	@intGenderIdent BIGINT = 0, 
	@nvrRole1 NVARCHAR(MAX) = '', 
	@nvrVersion1 NVARCHAR(MAX) = '', 
	@intPCMHStatusIdent BIGINT = 0, 
	@nvrPrimaryAddress1 NVARCHAR(MAX) = '', 
	@nvrPrimaryAddress2 NVARCHAR(MAX) = '', 
	@nvrPrimaryAddress3 NVARCHAR(MAX) = '', 
	@nvrPrimaryCity NVARCHAR(MAX) = '', 
	@intPrimaryStateIdent BIGINT = 0, 
	@nvrPrimaryZip NVARCHAR(MAX) = '', 
	@nvrPrimaryCounty NVARCHAR(MAX) = '', 
	@nvrPrimaryPhone NVARCHAR(MAX) = '', 
	@nvrPrimaryPhoneExtension NVARCHAR(MAX) = '', 
	@nvrPrimaryPhone2 NVARCHAR(MAX) = '', 
	@nvrPrimaryPhone2Extension NVARCHAR(MAX) = '', 
	@nvrPrimaryFax NVARCHAR(MAX) = '', 
	@nvrPrimaryFax2 NVARCHAR(MAX) = '', 
	@nvrMailingAddress1 NVARCHAR(MAX) = '', 
	@nvrMailingAddress2 NVARCHAR(MAX) = '', 
	@nvrMailingAddress3 NVARCHAR(MAX) = '', 
	@nvrMailingCity NVARCHAR(MAX) = '', 
	@intMailingStateIdent BIGINT = 0, 
	@nvrMailingZip NVARCHAR(MAX) = '', 
	@nvrMailingCounty NVARCHAR(MAX) = '', 
	@nvrPracticeAddress1 NVARCHAR(MAX) = '', 
	@nvrPracticeAddress2 NVARCHAR(MAX) = '', 
	@nvrPracticeAddress3 NVARCHAR(MAX) = '', 
	@nvrPracticeCity NVARCHAR(MAX) = '', 
	@intPracticeStateIdent BIGINT = 0, 
	@nvrPracticeZip NVARCHAR(MAX) = '', 
	@nvrPracticeCounty NVARCHAR(MAX) = '', 
	@nvrProfilePhoto NVARCHAR(MAX) = '', 
	@nvrWebsite NVARCHAR(MAX) = '', 
	@nvrPrescriptionLicenseNumber NVARCHAR(MAX) = '', 
	@sdtPrescriptionLicenseNumberExpirationDate SMALLDATETIME = '1/1/1900', 
	@nvrDEANumber NVARCHAR(MAX) = '', 
	@sdtDEANumberExpirationDate SMALLDATETIME = '1/1/1900', 
	@nvrTaxIDNumber NVARCHAR(MAX) = '', 
	@sdtTaxIDNumberExpirationDate SMALLDATETIME = '1/1/1900', 
	@nvrMedicareUPIN NVARCHAR(MAX) = '', 
	@nvrCAQHID NVARCHAR(MAX) = '', 
	@intMeaningfulUseIdent BIGINT = 0, 
	@nvrEIN NVARCHAR(MAX) = '', 
	@decLatitude DECIMAL(20,8) = 0.00, 
	@decLongitude DECIMAL(20,8) = 0.00, 
	@nvrRegion NVARCHAR(MAX) = '', 
	@sdtBirthDate SMALLDATETIME = '1/1/1900',
	@nvrEmail NVARCHAR(MAX) = '', 
	@intAddToEntityIdent BIGINT = 0, 
	@intAddASUserIdent BIGINT = 0, 
	@bitActive BIT = False,
	@bntEntityDelegateIdent BIGINT = 0

AS

	SET NOCOUNT ON

	DECLARE @bntIdent AS BIGINT,
			@bitAddToEntityIdentIsCustomer AS BIT

	SET @bntIdent = 0
	sET @bitAddToEntityIdentIsCustomer = 0
	
	INSERT INTO Entity (
		EntityTypeIdent, 
		NPI, 
		DBA, 
		OrganizationName, 
		Prefix, 
		FirstName, 
		MiddleName, 
		LastName, 
		Suffix, 
		Title, 
		MedicalSchool, 
		SoleProvider, 
		AcceptingNewPatients, 
		GenderIdent, 
		Role1, 
		Version1, 
		PCMHStatusIdent, 
		PrimaryAddress1, 
		PrimaryAddress2, 
		PrimaryAddress3, 
		PrimaryCity, 
		PrimaryStateIdent, 
		PrimaryZip, 
		PrimaryCounty, 
		PrimaryPhone, 
		PrimaryPhoneExtension, 
		PrimaryPhone2, 
		PrimaryPhone2Extension, 
		PrimaryFax, 
		PrimaryFax2, 
		MailingAddress1, 
		MailingAddress2, 
		MailingAddress3, 
		MailingCity, 
		MailingStateIdent, 
		MailingZip, 
		MailingCounty, 
		PracticeAddress1, 
		PracticeAddress2, 
		PracticeAddress3, 
		PracticeCity, 
		PracticeStateIdent, 
		PracticeZip, 
		PracticeCounty, 
		ProfilePhoto, 
		Website, 
		PrescriptionLicenseNumber, 
		PrescriptionLicenseNumberExpirationDate, 
		DEANumber, 
		DEANumberExpirationDate, 
		TaxIDNumber, 
		TaxIDNumberExpirationDate, 
		MedicareUPIN, 
		CAQHID, 
		MeaningfulUseIdent, 
		EIN, 
		Latitude, 
		Longitude, 
		Region, 
		Customer, 
		Username, 
		MustChangePassword, 
		Password1, 
		PasswordSalt, 
		SystemRoleIdent, 
		BirthDate, 
		LastPasswordChangedDate, 
		FailedLoginCount, 
		LastLoginAttempted, 
		LastSuccessfulLogin, 
		LockedTime, 
		AddASUserIdent, 
		AddDateTime, 
		EditASUserIdent, 
		EditDateTime, 
		Active, 
		LockSessionIdent, 
		LockTime, 
		IsLocked,
		GeocodingStatusIdent,
		ExternalLogin
	) 
	SELECT 
		EntityTypeIdent = @intEntityTypeIdent, 
		NPI = @vcrNPI, 
		DBA = @nvrDBA, 
		OrganizationName = @nvrOrganizationName, 
		Prefix = @nvrPrefix, 
		FirstName = @nvrFirstName, 
		MiddleName = @nvrMiddleName, 
		LastName = @nvrLastName, 
		Suffix = @nvrSuffix, 
		Title = @nvrTitle, 
		MedicalSchool = @nvrMedicalSchool, 
		SoleProvider = @bitSoleProvider, 
		AcceptingNewPatients = @bitAcceptingNewPatients, 
		GenderIdent = @intGenderIdent, 
		Role1 = @nvrRole1, 
		Version1 = @nvrVersion1, 
		PCMHStatusIdent = @intPCMHStatusIdent, 
		PrimaryAddress1 = @nvrPrimaryAddress1, 
		PrimaryAddress2 = @nvrPrimaryAddress2, 
		PrimaryAddress3 = @nvrPrimaryAddress3, 
		PrimaryCity = @nvrPrimaryCity, 
		PrimaryStateIdent = @intPrimaryStateIdent, 
		PrimaryZip = @nvrPrimaryZip, 
		PrimaryCounty = @nvrPrimaryCounty, 
		PrimaryPhone = @nvrPrimaryPhone, 
		PrimaryPhoneExtension = @nvrPrimaryPhoneExtension, 
		PrimaryPhone2 = @nvrPrimaryPhone2, 
		PrimaryPhone2Extension = @nvrPrimaryPhone2Extension, 
		PrimaryFax = @nvrPrimaryFax, 
		PrimaryFax2 = @nvrPrimaryFax2, 
		MailingAddress1 = @nvrMailingAddress1, 
		MailingAddress2 = @nvrMailingAddress2, 
		MailingAddress3 = @nvrMailingAddress3, 
		MailingCity = @nvrMailingCity, 
		MailingStateIdent = @intMailingStateIdent, 
		MailingZip = @nvrMailingZip, 
		MailingCounty = @nvrMailingCounty, 
		PracticeAddress1 = @nvrPracticeAddress1, 
		PracticeAddress2 = @nvrPracticeAddress2, 
		PracticeAddress3 = @nvrPracticeAddress3, 
		PracticeCity = @nvrPracticeCity, 
		PracticeStateIdent = @intPracticeStateIdent, 
		PracticeZip = @nvrPracticeZip, 
		PracticeCounty = @nvrPracticeCounty, 
		ProfilePhoto = @nvrProfilePhoto, 
		Website = @nvrWebsite, 
		PrescriptionLicenseNumber = @nvrPrescriptionLicenseNumber, 
		PrescriptionLicenseNumberExpirationDate = @sdtPrescriptionLicenseNumberExpirationDate, 
		DEANumber = @nvrDEANumber, 
		DEANumberExpirationDate = @sdtDEANumberExpirationDate, 
		TaxIDNumber = @nvrTaxIDNumber, 
		TaxIDNumberExpirationDate = @sdtTaxIDNumberExpirationDate, 
		MedicareUPIN = @nvrMedicareUPIN, 
		CAQHID = @nvrCAQHID, 
		MeaningfulUseIdent = @intMeaningfulUseIdent, 
		EIN = @nvrEIN, 
		Latitude = @decLatitude, 
		Longitude = @decLongitude, 
		Region = @nvrRegion, 
		Customer = 0, 
		Username = '', 
		MustChangePassword = 1, 
		Password1 = '', 
		PasswordSalt = '', 
		SystemRoleIdent = 2, -- Read only Access
		BirthDate = '1/1/1900', 
		LastPasswordChangedDate = dbo.ufnGetMyDate(), 
		FailedLoginCount = 0, 
		LastLoginAttempted = '1/1/1900', 
		LastSuccessfulLogin = '1/1/1900', 
		LockedTime = '1/1/1900', 
		AddASUserIdent = @intAddASUserIdent, 
		AddDateTime = dbo.ufnGetMyDate(), 
		EditASUserIdent = 0, 
		EditDateTime = '1/1/1900', 
		Active = @bitActive, 
		LockSessionIdent = 0, 
		LockTime = '1/1/1900', 
		IsLocked = 0,
		GeocodingStatusIdent = CASE
								WHEN @decLatitude = 0.0 AND @decLongitude = 0.0 THEN 0 -- needs to geocode
								ELSE 1 -- success
							   END,
		ExternalLogin = 0

	SET @bntIdent = SCOPE_IDENTITY()

	--Make sure that the ident passed in is a customer
	SELECT 
		@bitAddToEntityIdentIsCustomer = E.Customer
	FROM 
		Entity E WITH (NOLOCK)
	WHERE 
		E.Ident = @intAddToEntityIdent

	--Verify that we got a user ident and that the entity we are adding it to is a customer
	IF (@bntIdent <> 0 AND @bitAddToEntityIdentIsCustomer = 1)
	BEGIN

		--Add this entity to the network
		EXEC uspAddEntityToNetwork
				@intFromEntityIdent = @intAddToEntityIdent, 
				@intToEntityIdent = @bntIdent, 
				@intAddASUserIdent = @intAddASUserIdent,  
				@bitActive = 1,
				@bitSuppressOutput = 1

	END

	IF(@bntIdent <> 0 AND @bntEntityDelegateIdent <> 0)
	BEGIN

		-- if we're defaulting a delegate, then add it at this time
		EXEC uspAddEntityDelegate
				@intEntityIdent = @bntIdent,
				@intEntityDelegateIdent = @bntEntityDelegateIdent,
				@bitSuppressOutput = 1

	END

	IF (@bntIdent <> 0 AND @nvrEmail <> '')
	BEGIN

		EXEC uspAddEntityEmail
			@intEntityIdent = @bntIdent,
			@nvrEmail = @nvrEmail,
			@bitNotify = 0,
			@bitVerified = 0,
			@intVerifiedASUserIdent = 0,
			@intAddASUserIdent = @intAddASUserIdent,
			@bitActive = 1,
			@bitSuppressOutput = 1

	END

	--Final Select
	SELECT 
		@bntIdent AS [Ident]

	
GO