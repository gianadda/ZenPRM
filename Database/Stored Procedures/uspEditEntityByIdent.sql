IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspEditEntityByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspEditEntityByIdent
 GO
/* uspEditEntityByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspEditEntityByIdent]

	@intIdent BIGINT, 
	@vcrNPI VARCHAR(MAX), 
	@nvrDBA NVARCHAR(MAX), 
	@nvrOrganizationName NVARCHAR(MAX), 
	@nvrPrefix NVARCHAR(MAX), 
	@nvrFirstName NVARCHAR(MAX), 
	@nvrMiddleName NVARCHAR(MAX), 
	@nvrLastName NVARCHAR(MAX), 
	@nvrSuffix NVARCHAR(MAX), 
	@nvrTitle NVARCHAR(MAX), 
	@nvrMedicalSchool NVARCHAR(MAX), 
	@bitSoleProvider BIT, 
	@bitAcceptingNewPatients BIT, 
	@intGenderIdent BIGINT, 
	@nvrRole1 NVARCHAR(MAX), 
	@nvrVersion1 NVARCHAR(MAX), 
	@intPCMHStatusIdent BIGINT, 
	@nvrPrimaryAddress1 NVARCHAR(MAX), 
	@nvrPrimaryAddress2 NVARCHAR(MAX), 
	@nvrPrimaryAddress3 NVARCHAR(MAX), 
	@nvrPrimaryCity NVARCHAR(MAX), 
	@intPrimaryStateIdent BIGINT, 
	@nvrPrimaryZip NVARCHAR(MAX), 
	@nvrPrimaryCounty NVARCHAR(MAX), 
	@nvrPrimaryPhone NVARCHAR(MAX), 
	@nvrPrimaryPhoneExtension NVARCHAR(MAX), 
	@nvrPrimaryPhone2 NVARCHAR(MAX), 
	@nvrPrimaryPhone2Extension NVARCHAR(MAX), 
	@nvrPrimaryFax NVARCHAR(MAX), 
	@nvrPrimaryFax2 NVARCHAR(MAX), 
	@nvrMailingAddress1 NVARCHAR(MAX), 
	@nvrMailingAddress2 NVARCHAR(MAX), 
	@nvrMailingAddress3 NVARCHAR(MAX), 
	@nvrMailingCity NVARCHAR(MAX), 
	@intMailingStateIdent BIGINT, 
	@nvrMailingZip NVARCHAR(MAX), 
	@nvrMailingCounty NVARCHAR(MAX), 
	@nvrPracticeAddress1 NVARCHAR(MAX), 
	@nvrPracticeAddress2 NVARCHAR(MAX), 
	@nvrPracticeAddress3 NVARCHAR(MAX), 
	@nvrPracticeCity NVARCHAR(MAX), 
	@intPracticeStateIdent BIGINT, 
	@nvrPracticeZip NVARCHAR(MAX), 
	@nvrPracticeCounty NVARCHAR(MAX), 
	@nvrProfilePhoto NVARCHAR(MAX), 
	@nvrWebsite NVARCHAR(MAX), 
	@nvrPrescriptionLicenseNumber NVARCHAR(MAX), 
	@sdtPrescriptionLicenseNumberExpirationDate NVARCHAR(MAX), 
	@nvrDEANumber NVARCHAR(MAX), 
	@sdtDEANumberExpirationDate NVARCHAR(MAX), 
	@nvrTaxIDNumber NVARCHAR(MAX), 
	@sdtTaxIDNumberExpirationDate NVARCHAR(MAX), 
	@nvrMedicareUPIN NVARCHAR(MAX), 
	@nvrCAQHID NVARCHAR(MAX), 
	@intMeaningfulUseIdent BIGINT, 
	@nvrEIN NVARCHAR(MAX), 
	@decLatitude DECIMAL(20,8), 
	@decLongitude DECIMAL(20,8), 
	@nvrRegion NVARCHAR(MAX), 
	@sdtBirthDate NVARCHAR(MAX) = '1/1/1900',
	@nvrEmail NVARCHAR(MAX) = '', 
	@intEditASUserIdent BIGINT, 
	@bitActive BIT

AS

	SET NOCOUNT ON
	
	DECLARE @geoLocation AS GEOGRAPHY = GEOGRAPHY::Point(@decLatitude, @decLongitude, 4326)
	DECLARE @bntEntityEmailIdent BIGINT

	SET @bntEntityEmailIdent = 0
	
	UPDATE Entity
	SET 
		NPI = CASE NPI
				WHEN '' THEN @vcrNPI
				ELSE NPI
			  END,   -- dont allow a user to edit an NPI if the resource already has one
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
		GeoLocation = @geoLocation,
		Region = @nvrRegion, 
		BirthDate = @sdtBirthDate,
		EditASUserIdent = @intEditASUserIdent, 
		EditDateTime = dbo.ufnGetMyDate(), 
		Active = @bitActive,
		-- 5/19/16: apparently this was never pushed to prod, so altering SP so that it gets picked up in the deploy process
		GeocodingStatusIdent = CASE
								WHEN @decLatitude = 0.0 AND @decLongitude = 0.0 THEN 0 -- needs to geocode
								ELSE 1 -- success
							   END
	WHERE
		Ident = @intIdent

	SELECT
		@bntEntityEmailIdent = Ident
	FROM 
		EntityEmail WITH (NOLOCK) 
	WHERE 
		@nvrEmail <> ''
		AND EntityIdent = @intIdent 
		AND Email = @nvrEmail 
		AND Active = 1

	IF (@bntEntityEmailIdent = 0 AND @nvrEmail <> '')
		BEGIN
		
			-- if we pass in an email on edit and it doesnt already exist, then add it
			EXEC uspAddEntityEmail
				@intEntityIdent = @intIdent,
				@nvrEmail = @nvrEmail,
				@bitNotify = 0,
				@bitVerified = 0,
				@intVerifiedASUserIdent = 0,
				@intAddASUserIdent = @intEditASUserIdent,
				@bitActive = 1,
				@bitSuppressOutput = 1


		END

		
	SELECT @intIdent as [Ident]
GO