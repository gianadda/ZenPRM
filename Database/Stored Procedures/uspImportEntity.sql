IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspImportEntity') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspImportEntity
 GO
/* uspImportEntity
 *
 * Accepts data from the NPI registry update process, then determines where to add or edit Entity
 *
 *
*/
CREATE PROCEDURE uspImportEntity

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
	@nvrRegion NVARCHAR(MAX) = '', 
	@sdtBirthDate SMALLDATETIME = '1/1/1900'

AS

	SET NOCOUNT ON

	DECLARE @bntIdent BIGINT
	DECLARE @dteLastEditDate DATETIME
	DECLARE @bntLastEditUserIdent BIGINT
	DECLARE @intAddEditASUserIdent BIGINT
	DECLARE @intInitialAddEditASUserIdent BIGINT
	DECLARE @decLatitude DECIMAL(20,8)
	DECLARE @decLongitude DECIMAL(20,8)

	SET @intAddEditASUserIdent = - 1 -- import service user
	SET @intInitialAddEditASUserIdent = 1 -- the add asuserIdent for the initial NPI import
	
	SET @decLatitude = 0.0
	SET @decLongitude = 0.0

	-- see if we have this entity already in our DB
	SELECT
		@bntIdent = Ident,
		@dteLastEditDate = CASE EditDateTime
							WHEN '1/1/1900' THEN AddDateTime
							ELSE EditDateTime
						   END,
		@bntLastEditUserIdent = CASE EditDateTime
							WHEN '1/1/1900' THEN AddASUserIdent
							ELSE EditASUserIdent
						   END
	FROM				
		Entity WITH (NOLOCK)
	WHERE
		NPI = @vcrNPI
		AND Active = 1

	-- NPI not found, then lets add them
	IF (@bntIdent IS NULL)
		BEGIN

			-- see if we've already geo-coded this address
			SELECT
				@decLatitude = Latitude,
				@decLongitude = Longitude
			FROM
				Entity WITH (NOLOCK)
			WHERE
				Active = 1
				AND GeocodingStatusIdent = 1 -- success
				AND PrimaryAddress1 = @nvrPrimaryAddress1
				AND PrimaryCity = @nvrPrimaryCity
				AND PrimaryStateIdent = @intPrimaryStateIdent
				AND PrimaryZip = @nvrPrimaryZip

			EXEC uspAddEntity @intEntityTypeIdent = @intEntityTypeIdent,
								@vcrNPI = @vcrNPI,
								@nvrDBA = @nvrDBA,
								@nvrOrganizationName = @nvrOrganizationName,
								@nvrPrefix = @nvrPrefix,
								@nvrFirstName = @nvrFirstName,
								@nvrMiddleName = @nvrMiddleName,
								@nvrLastName = @nvrLastName,
								@nvrSuffix = @nvrSuffix,
								@nvrTitle = @nvrTitle,
								@nvrMedicalSchool = @nvrMedicalSchool,
								@bitSoleProvider = @bitSoleProvider,
								@bitAcceptingNewPatients = @bitAcceptingNewPatients,
								@intGenderIdent = @intGenderIdent,
								@nvrRole1 = @nvrRole1,
								@nvrVersion1 = @nvrVersion1,
								@intPCMHStatusIdent = @intPCMHStatusIdent,
								@nvrPrimaryAddress1 = @nvrPrimaryAddress1,
								@nvrPrimaryAddress2 = @nvrPrimaryAddress2,
								@nvrPrimaryAddress3 = @nvrPrimaryAddress3,
								@nvrPrimaryCity = @nvrPrimaryCity,
								@intPrimaryStateIdent = @intPrimaryStateIdent,
								@nvrPrimaryZip = @nvrPrimaryZip,
								@nvrPrimaryCounty = @nvrPrimaryCounty,
								@nvrPrimaryPhone = @nvrPrimaryPhone,
								@nvrPrimaryPhoneExtension = @nvrPrimaryPhoneExtension,
								@nvrPrimaryPhone2 = @nvrPrimaryPhone2,
								@nvrPrimaryPhone2Extension = @nvrPrimaryPhone2Extension,
								@nvrPrimaryFax = @nvrPrimaryFax,
								@nvrPrimaryFax2 = @nvrPrimaryFax2,
								@nvrMailingAddress1 = @nvrMailingAddress1,
								@nvrMailingAddress2 = @nvrMailingAddress2,
								@nvrMailingAddress3 = @nvrMailingAddress3,
								@nvrMailingCity = @nvrMailingCity,
								@intMailingStateIdent = @intMailingStateIdent,
								@nvrMailingZip = @nvrMailingZip,
								@nvrMailingCounty = @nvrMailingCounty,
								@nvrPracticeAddress1 = @nvrPracticeAddress1,
								@nvrPracticeAddress2 = @nvrPracticeAddress2,
								@nvrPracticeAddress3 = @nvrPracticeAddress3,
								@nvrPracticeCity = @nvrPracticeCity,
								@intPracticeStateIdent = @intPracticeStateIdent,
								@nvrPracticeZip = @nvrPracticeZip,
								@nvrPracticeCounty = @nvrPracticeCounty,
								@nvrProfilePhoto = @nvrProfilePhoto,
								@nvrWebsite = @nvrWebsite,
								@nvrPrescriptionLicenseNumber = @nvrPrescriptionLicenseNumber,
								@sdtPrescriptionLicenseNumberExpirationDate = @sdtPrescriptionLicenseNumberExpirationDate,
								@nvrDEANumber = @nvrDEANumber,
								@sdtDEANumberExpirationDate = @sdtDEANumberExpirationDate,
								@nvrTaxIDNumber = @nvrTaxIDNumber,
								@sdtTaxIDNumberExpirationDate = @sdtTaxIDNumberExpirationDate,
								@nvrMedicareUPIN = @nvrMedicareUPIN,
								@nvrCAQHID = @nvrCAQHID,
								@intMeaningfulUseIdent = @intMeaningfulUseIdent,
								@nvrEIN = @nvrEIN,
								@decLatitude = @decLatitude,
								@decLongitude = @decLongitude,
								@nvrRegion = @nvrRegion,
								@sdtBirthDate = @sdtBirthDate,
								@nvrEmail = '',
								@intAddToEntityIdent = 0,
								@intAddASUserIdent = @intAddEditASUserIdent,
								@bitActive = 1,
								@bntEntityDelegateIdent = 0

				-- return the added entity
				-- we cant use scope identity in this case since uspAddEntity includes child table inserts
				SELECT
					@bntIdent = Ident
				FROM
					Entity WITH (NOLOCK)
				WHERE
					NPI = @vcrNPI
					AND Active = 1

		END

	-- if we found the NPI resource, and it hasnt been updated by a customer, refresh from the NPI registry
	IF (@bntIdent > 0 AND @bntLastEditUserIdent IN (@intInitialAddEditASUserIdent,@intAddEditASUserIdent))
		BEGIN

			-- see if we've already geo-coded this address
			SELECT
				@decLatitude = Latitude,
				@decLongitude = Longitude
			FROM
				Entity WITH (NOLOCK)
			WHERE
				Active = 1
				AND GeocodingStatusIdent = 1 -- success
				AND PrimaryAddress1 = @nvrPrimaryAddress1
				AND PrimaryCity = @nvrPrimaryCity
				AND PrimaryStateIdent = @intPrimaryStateIdent
				AND PrimaryZip = @nvrPrimaryZip

			EXEC uspEditEntityByIdent @intIdent = @bntIdent,
										@vcrNPI = @vcrNPI,
										@nvrDBA = @nvrDBA,
										@nvrOrganizationName = @nvrOrganizationName,
										@nvrPrefix = @nvrPrefix,
										@nvrFirstName = @nvrFirstName,
										@nvrMiddleName = @nvrMiddleName,
										@nvrLastName = @nvrLastName,
										@nvrSuffix = @nvrSuffix,
										@nvrTitle = @nvrTitle,
										@nvrMedicalSchool = @nvrMedicalSchool,
										@bitSoleProvider = @bitSoleProvider,
										@bitAcceptingNewPatients = @bitAcceptingNewPatients,
										@intGenderIdent = @intGenderIdent,
										@nvrRole1 = @nvrRole1,
										@nvrVersion1 = @nvrVersion1,
										@intPCMHStatusIdent = @intPCMHStatusIdent,
										@nvrPrimaryAddress1 = @nvrPrimaryAddress1,
										@nvrPrimaryAddress2 = @nvrPrimaryAddress2,
										@nvrPrimaryAddress3 = @nvrPrimaryAddress3,
										@nvrPrimaryCity = @nvrPrimaryCity,
										@intPrimaryStateIdent = @intPrimaryStateIdent,
										@nvrPrimaryZip = @nvrPrimaryZip,
										@nvrPrimaryCounty = @nvrPrimaryCounty,
										@nvrPrimaryPhone = @nvrPrimaryPhone,
										@nvrPrimaryPhoneExtension = @nvrPrimaryPhoneExtension,
										@nvrPrimaryPhone2 = @nvrPrimaryPhone2,
										@nvrPrimaryPhone2Extension = @nvrPrimaryPhone2Extension,
										@nvrPrimaryFax = @nvrPrimaryFax,
										@nvrPrimaryFax2 = @nvrPrimaryFax2,
										@nvrMailingAddress1 = @nvrMailingAddress1,
										@nvrMailingAddress2 = @nvrMailingAddress2,
										@nvrMailingAddress3 = @nvrMailingAddress3,
										@nvrMailingCity = @nvrMailingCity,
										@intMailingStateIdent = @intMailingStateIdent,
										@nvrMailingZip = @nvrMailingZip,
										@nvrMailingCounty = @nvrMailingCounty,
										@nvrPracticeAddress1 = @nvrPracticeAddress1,
										@nvrPracticeAddress2 = @nvrPracticeAddress2,
										@nvrPracticeAddress3 = @nvrPracticeAddress3,
										@nvrPracticeCity = @nvrPracticeCity,
										@intPracticeStateIdent = @intPracticeStateIdent,
										@nvrPracticeZip = @nvrPracticeZip,
										@nvrPracticeCounty = @nvrPracticeCounty,
										@nvrProfilePhoto = @nvrProfilePhoto,
										@nvrWebsite = @nvrWebsite,
										@nvrPrescriptionLicenseNumber = @nvrPrescriptionLicenseNumber,
										@sdtPrescriptionLicenseNumberExpirationDate = @sdtPrescriptionLicenseNumberExpirationDate,
										@nvrDEANumber = @nvrDEANumber,
										@sdtDEANumberExpirationDate = @sdtDEANumberExpirationDate,
										@nvrTaxIDNumber = @nvrTaxIDNumber,
										@sdtTaxIDNumberExpirationDate = @sdtTaxIDNumberExpirationDate,
										@nvrMedicareUPIN = @nvrMedicareUPIN,
										@nvrCAQHID = @nvrCAQHID,
										@intMeaningfulUseIdent = @intMeaningfulUseIdent,
										@nvrEIN = @nvrEIN,
										@decLatitude = @decLatitude,
										@decLongitude = @decLongitude,
										@nvrRegion = @nvrRegion,
										@sdtBirthDate = @sdtBirthDate,
										@nvrEmail = '',
										@intEditASUserIdent = @intAddEditASUserIdent,
										@bitActive = 1


		END


	--Final Select
	SELECT 
		@bntIdent AS [Ident]

GO