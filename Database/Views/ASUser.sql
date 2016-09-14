IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'ASUser') 
	AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP View ASUser
GO

CREATE VIEW ASUser 

AS 

	SELECT DISTINCT
		E.Ident,
		E.EntityTypeIdent,
		ET.Name1 as [EntityType],
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
		G.Name1 as [Gender],
		E.Role1,
		E.Version1,
		E.PCMHStatusIdent,
		PCMH.Name1 as [PCMHStatus],
		E.PrimaryAddress1,
		E.PrimaryAddress2,
		E.PrimaryAddress3,
		E.PrimaryCity,
		E.PrimaryStateIdent,
		PrimaryState.Name1 as [PrimaryState],
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
		MailingState.Name1 as [MailingState],
		E.MailingZip,
		E.MailingCounty,
		E.PracticeAddress1,
		E.PracticeAddress2,
		E.PracticeAddress3,
		E.PracticeCity,
		E.PracticeStateIdent,
		PracticeState.Name1 as [PracticeState],
		E.PracticeZip,
		E.PracticeCounty,
		E.ProfilePhoto,
		E.Website,
		E.PrescriptionLicenseNumber,
		E.PrescriptionLicenseNumberExpirationDate,
		E.DEANumber,
		E.DEANumberExpirationDate,
		E.TaxIDNumber,
		E.TaxIDNumberExpirationDate,
		E.MedicareUPIN,
		E.CAQHID,
		E.MeaningfulUseIdent,
		MU.Name1 as [MeaningfulUse],
		E.EIN,
		E.Latitude,
		E.Longitude,
		E.Region,
		E.Customer,
		E.ExternalLogin,
		E.Username,
		E.MustChangePassword,
		E.Password1,
		E.PasswordSalt,
		dbo.ufnGetEntityEmailListByEntityIdent(E.Ident) as [Email],
		E.SystemRoleIdent,
		SR.Name1 as [SystemRole],
		E.BirthDate,
		E.LastPasswordChangedDate,
		E.FailedLoginCount,
		E.LastLoginAttempted,
		E.LastSuccessfulLogin,
		E.LockedTime,
		E.AddASUserIdent,
		E.AddDateTime,
		E.EditASUserIdent,
		E.EditDateTime,
		E.Active,
		E.LockSessionIdent,
		E.LockTime,
		E.IsLocked
	FROM
		Entity E WITH (NOLOCK)
		INNER JOIN
		EntityType ET WITH (NOLOCK)
			ON E.EntityTypeIdent = ET.Ident
		INNER JOIN
		Gender G WITH (NOLOCK)
			ON E.GenderIdent = G.Ident
		INNER JOIN
		PCMHStatus PCMH WITH (NOLOCK)
			ON E.PCMHStatusIdent = PCMH.Ident
		INNER JOIN
		States PrimaryState WITH (NOLOCK)
			ON E.PrimaryStateIdent = PrimaryState.Ident
		INNER JOIN
		States MailingState WITH (NOLOCK)
			ON E.MailingStateIdent = MailingState.Ident
		INNER JOIN
		States PracticeState WITH (NOLOCK)
			ON E.PracticeStateIdent = PracticeState.Ident
		INNER JOIN
		MeaningfulUse MU WITH (NOLOCK)
			ON E.MeaningfulUseIdent = MU.Ident
		INNER JOIN
		SystemRole SR WITH (NOLOCK)
			ON E.SystemRoleIdent = SR.Ident
	WHERE 
		E.Username <> ''
		AND E.Active = 1


GO