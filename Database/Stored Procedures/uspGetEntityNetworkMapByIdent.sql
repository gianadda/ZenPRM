IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityNetworkMapByIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityNetworkMapByIdent
GO

/* uspGetEntityNetworkMapByIdent 306486, 306486, 306486
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetEntityNetworkMapByIdent]

	@bntIdent BIGINT,
	@bntASUserIdent BIGINT, --Current User (i.e. Delegated)
	@bntAddEditASUserIdent BIGINT = 0 -- Logged in User (ie. Office Manager)

AS

	SET NOCOUNT ON

	
-- EntityConnection
	SELECT DISTINCT
		EC.EntityConnectionIdent as [Ident],
		@bntIdent as [EntityIdent],
		EC.FromEntityIdent,
		EC.FromEntityFullName,
		EC.ConnectionTypeIdent,
		EC.Name as [ConnectionTypeName],
		EC.ToEntityIdent,
		EC.ToEntityFullName,
		E.EntityTypeIdent,
		ET.Name1 as [EntityType],
		E.FullName,
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
		E.Region
	FROM
		EntityCommunity EC WITH (NOLOCK)
		INNER JOIN
		ConnectionType CT WITH (NOLOCK)
			ON CT.Ident = EC.ConnectionTypeIdent
		--Now go get the "to" entity so we can show useful info about who they are
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = EC.ToEntityIdent
		LEFT OUTER JOIN
		EntityEmail EE WITH (NOLOCK)
			ON E.Ident = EE.EntityIdent 
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
		EC.FromEntityIdent = @bntIdent
		--AND EC.ToEntityIdent <> @bntIdent
	ORDER BY
		E.FullName
	
	
	--Get the networkMap
	EXEC uspGetCommunityNetworkMapByEntityIdent @bntIdent, @bntASUserIdent, @bitIncludeNetwork = 0
	
GO

--uspGetEntityNetworkMapByIdent 306485, 2, 2