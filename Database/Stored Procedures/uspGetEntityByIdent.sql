IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityByIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityByIdent
GO


/* uspGetEntityByIdent 574809, 306485, 306487
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetEntityByIdent]

	@bntIdent BIGINT,
	@bntASUserIdent BIGINT, --Current User (i.e. Delegated)
	@bntAddEditASUserIdent BIGINT = 0 -- Logged in User (ie. Office Manager)

AS

	SET NOCOUNT ON

	
--Time tracking
DECLARE @StartTime datetime
DECLARE @EndTime datetime
SELECT @StartTime=GETDATE() 


	/*
	
	Tables: 
		1. Entity
		2. EntityEmail
		3. Taxonomy
		4. Services
		5. Payor
		6. Language
		7. Speciality
		8. Degree
		9. EntityLicense
		10. EntitySystem
		11. EntityOtherID
		12. EntityProject
		13. EntityDelegate
		14. EntityToDo
		15. EntityToDoCategory
		
	*/


	DECLARE @bntProviderNetworkCount BIGINT,
			@bntOpenProjectsCount BIGINT,
			@bntArchivedProjectsCount BIGINT,
			@bntRequirementsInUseCount BIGINT,
			@bntAdminCount BIGINT,
			@bntInteractionCount BIGINT,
			@bitIsInNetwork BIT,
			@vcrEntityFullName VARCHAR(MAX),
			@bitEntityIsCustomer BIT

	SET @bntProviderNetworkCount = 0
	SET @bntOpenProjectsCount = 0
	SET @bntArchivedProjectsCount = 0
	SET @bntRequirementsInUseCount = 0
	SET @bntAdminCount = 0
	SET @bntInteractionCount = 0
	SET @bitIsInNetwork = 0
	SET @vcrEntityFullName = ''
	SET @bitEntityIsCustomer = 0

--	PRINT 'EntityIsCustomer  --------------------------------------------------------------------------------------------------------------------------'	
	--Are we currently looking up a customer?
	SELECT 
		@bitEntityIsCustomer = CASE 
									WHEN @bntIdent = @bntASUserIdent THEN E.Customer  -- make sure its the customer accessing this data
									ELSE CAST(0 AS BIT)
								END,
		@vcrEntityFullName = E.FullName
	FROM 
		Entity E  WITH (NOLOCK)
	WHERE
		E.Ident = @bntIdent

--	PRINT 'EntityNetwork --------------------------------------------------------------------------------------------------------------------------'
	SELECT 
		@bntProviderNetworkCount = COUNT(EN.ToEntityIdent) 
	FROM
		EntityNetwork EN WITH (NOLOCK)
	WHERE 
		@bitEntityIsCustomer = 1
		AND EN.FromEntityIdent = @bntIdent
		
--	PRINT 'OpenProjectsCount --------------------------------------------------------------------------------------------------------------------------'
	SELECT 
		@bntOpenProjectsCount = COUNT(EP.Ident) 
	FROM
		EntityProject EP WITH (NOLOCK)
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = EP.EntityIdent
	WHERE 
		@bitEntityIsCustomer = 1
		AND EP.EntityIdent = @bntIdent
		AND EP.Active = 1
		AND EP.Archived = 0
		AND E.Active = 1
		
--	PRINT 'ArchivedProjectsCount --------------------------------------------------------------------------------------------------------------------------'
	SELECT 
		@bntArchivedProjectsCount = COUNT(EP.Ident) 
	FROM
		EntityProject EP WITH (NOLOCK)
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = EP.EntityIdent
	WHERE 
		@bitEntityIsCustomer = 1
		AND EP.EntityIdent = @bntIdent
		AND EP.Active = 1
		AND EP.Archived = 1
		AND E.Active = 1
		
		
--	PRINT 'AdminCount  --------------------------------------------------------------------------------------------------------------------------'
	SELECT 
		@bntAdminCount = COUNT(ED.ToEntityIdent) 
	FROM
		EntityDelegate ED WITH (NOLOCK)
	WHERE 
		ED.FromEntityIdent = @bntIdent
		AND @bitEntityIsCustomer = 1
		
--	PRINT 'InteractionCount  --------------------------------------------------------------------------------------------------------------------------'
	SELECT  
		@bntInteractionCount  = COUNT(DISTINCT EI.Ident) 
	FROM
		EntityInteraction EI WITH (NOLOCK)
	WHERE 
		EI.FromEntityIdent = @bntASUserIdent
		AND EI.ToEntityIdent = @bntIdent
	
--	PRINT 'IsInNetwork  --------------------------------------------------------------------------------------------------------------------------'	
	SELECT 
		@bitIsInNetwork = 1
	FROM
		EntityNetwork EN WITH (NOLOCK)
	WHERE 
		EN.FromEntityIdent = @bntASUserIdent
		AND EN.ToEntityIdent = @bntIdent
		


	
--	PRINT 'CREATE #tmpProjects  --------------------------------------------------------------------------------------------------------------------------'	
	CREATE TABLE #tmpProjects (
		Ident BIGINT,
		EntityIdent BIGINT,
		Name1 NVARCHAR(MAX),
		EntityName NVARCHAR(MAX),
		ProjectManager NVARCHAR(MAX),
		ProjectManagerIdent BIGINT,
		DueDate NVARCHAR(MAX),
		PrivateProject BIT,
		ShowOnProfile BIT, 
		IncludeEntireNetwork BIT,
		Archived BIT,
		ArchivedASUserIdent BIGINT,
		ArchivedDateTime SMALLDATETIME,
		AddASUserIdent BIGINT,
		AddDateTime SMALLDATETIME,
		EditASUserIdent BIGINT,
		EditDateTime SMALLDATETIME,
		Active BIT, 
		ProjectType NVARCHAR(MAX)
	)
	
--	PRINT '1. Entity  --------------------------------------------------------------------------------------------------------------------------'	
	--1. Entity
	SELECT DISTINCT
		E.Ident,
		E.EntityTypeIdent,
		ET.Name1 as [EntityType],
		~ET.IncludeInCNP as [PrivateResource],
		ET.Person,
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
		CONVERT(NVARCHAR(10), E.PrescriptionLicenseNumberExpirationDate, 101) as [PrescriptionLicenseNumberExpirationDate],
		E.DEANumber,
		CONVERT(NVARCHAR(10), E.DEANumberExpirationDate, 101) as [DEANumberExpirationDate],
		E.TaxIDNumber,
		CONVERT(NVARCHAR(10), E.TaxIDNumberExpirationDate, 101) as [TaxIDNumberExpirationDate],
		E.MedicareUPIN,
		E.CAQHID,
		E.MeaningfulUseIdent,
		MU.Name1 as [MeaningfulUse],
		E.EIN,
		E.Latitude,
		E.Longitude,
		E.Region,
		E.Customer,
		E.Registered,
		E.ExternalLogin,
		E.SystemRoleIdent,
		dbo.ufnGetEntityEmailListByEntityIdent(E.Ident) as [Email],
		CONVERT(NVARCHAR(10), E.BirthDate, 101) as [BirthDate],
		@bntProviderNetworkCount as [ProviderNetworkCount],
		@bntOpenProjectsCount as [OpenProjectsCount],
		@bntArchivedProjectsCount as [ArchivedProjectsCount],
		@bntRequirementsInUseCount as [RequirementsInUseCount],
		@bntAdminCount as [AdminCount],
		dbo.ufnGetProfilePercentCompleteByEntityIdentAndEntityTypeIdent(E.Ident, E.EntityTypeIdent) as [ProfilePercentComplete],
		@bntInteractionCount as [InteractionCount],
		E.Active,
		@bitIsInNetwork as [IsInNetwork]
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
		E.Ident = @bntIdent	
		AND E.Active = 1
		AND (ET.IncludeInCNP = 1 OR @bitIsInNetwork = 1) -- if they are a private resource, then they have to be in network


		
--	PRINT '2. EntityEmail  --------------------------------------------------------------------------------------------------------------------------'	
	--2. EntityEmail
	SELECT DISTINCT
		EE.Ident,
		EE.EntityIdent,
		EE.Email,
		EE.Notify,
		EE.Verified,
		EE.VerifiedASUserIdent,
		CONVERT(NVARCHAR(10), EE.VerifiedDateTime, 101) as [VerifiedDateTime],
		EE.AddASUserIdent,
		EE.AddDateTime,
		EE.EditASUserIdent,
		EE.EditDateTime,
		EE.Active,
		CAST(COALESCE(EL.Active, 0) AS BIT) AS [ExternalLoginEmail]
	FROM
		EntityEmail EE WITH (NOLOCK)
		LEFT OUTER JOIN
		EntityExternalLogin EL WITH (NOLOCK)
			ON EL.EntityIdent = EE.EntityIdent
			AND EL.ExternalEmailAddress = EE.Email
			AND EL.Active = 1
	WHERE 
		EE.EntityIdent = @bntIdent
		AND EE.Active = 1
	ORDER BY
		EE.Email


		
--	PRINT '3. Taxonomy  --------------------------------------------------------------------------------------------------------------------------'	
	--3. Taxonomy
	SELECT DISTINCT
		T.Ident,
		@bntIdent as [EntityIdent],
		T.Name1,
		T.AddASUserIdent,
		T.AddDateTime,
		T.EditASUserIdent,
		T.EditDateTime,
		T.Active
	FROM
		EntityTaxonomyXRef ETX WITH (NOLOCK)
		INNER JOIN
		Taxonomy T WITH (NOLOCK)
			ON ETX.TaxonomyIdent = T.Ident
	WHERE 
		ETX.EntityIdent = @bntIdent
		AND ETX.Active = 1
	ORDER BY
		T.Name1

		
--	PRINT '4. Services  --------------------------------------------------------------------------------------------------------------------------'	
--4. Services
	SELECT DISTINCT
		S.Ident,
		@bntIdent as [EntityIdent],
		S.Name1,
		S.AddASUserIdent,
		S.AddDateTime,
		S.EditASUserIdent,
		S.EditDateTime,
		S.Active
	FROM
		EntityServices1XRef ESX WITH (NOLOCK)
		INNER JOIN
		Services1 S WITH (NOLOCK)
			ON ESX.Services1Ident = S.Ident
	WHERE 
		ESX.EntityIdent = @bntIdent
		AND ESX.Active = 1
	ORDER BY
		S.Name1

		
--	PRINT '5. Payor  --------------------------------------------------------------------------------------------------------------------------'	
--5. Payor
	SELECT DISTINCT
		P.Ident,
		@bntIdent as [EntityIdent],
		P.Name1,
		P.AddASUserIdent,
		P.AddDateTime,
		P.EditASUserIdent,
		P.EditDateTime,
		P.Active
	FROM
		EntityPayorXRef EPX WITH (NOLOCK)
		INNER JOIN
		Payor P WITH (NOLOCK)
			ON EPX.PayorIdent = P.Ident
	WHERE 
		EPX.EntityIdent = @bntIdent
		AND EPX.Active = 1
	ORDER BY
		P.Name1
		
--	PRINT '6. Language  --------------------------------------------------------------------------------------------------------------------------'	
--6. Language
	SELECT DISTINCT
		L.Ident,
		@bntIdent as [EntityIdent],
		L.Name1,
		L.AddASUserIdent,
		L.AddDateTime,
		L.EditASUserIdent,
		L.EditDateTime,
		L.Active
	FROM
		EntityLanguage1XRef ELX WITH (NOLOCK)
		INNER JOIN
		Language1 L WITH (NOLOCK)
			ON ELX.Language1Ident = L.Ident
	WHERE 
		ELX.EntityIdent = @bntIdent
		AND ELX.Active = 1
	ORDER BY
		L.Name1
		
--	PRINT '7. Speciality  --------------------------------------------------------------------------------------------------------------------------'	
--7. Speciality
	SELECT DISTINCT
		S.Ident,
		@bntIdent as [EntityIdent],
		S.Name1,
		S.AddASUserIdent,
		S.AddDateTime,
		S.EditASUserIdent,
		S.EditDateTime,
		S.Active
	FROM
		EntitySpecialityXRef ESX WITH (NOLOCK)
		INNER JOIN
		Speciality S WITH (NOLOCK)
			ON ESX.SpecialityIdent = S.Ident
	WHERE 
		ESX.EntityIdent = @bntIdent
		AND ESX.Active = 1
	ORDER BY
		S.Name1
		
--	PRINT '8. Degree  --------------------------------------------------------------------------------------------------------------------------'	
--8. Degree
	SELECT DISTINCT
		D.Ident,
		@bntIdent as [EntityIdent],
		D.Name1,
		D.AddASUserIdent,
		D.AddDateTime,
		D.EditASUserIdent,
		D.EditDateTime,
		D.Active
	FROM
		EntityDegreeXRef EDX WITH (NOLOCK)
		INNER JOIN
		Degree D WITH (NOLOCK)
			ON EDX.DegreeIdent = D.Ident
	WHERE 
		EDX.EntityIdent = @bntIdent
		AND EDX.Active = 1
	ORDER BY
		D.Name1

--	PRINT '9. EntityLicense --------------------------------------------------------------------------------------------------------------------------'	
--9. EntityLicense
	SELECT DISTINCT
		EL.Ident,
		EL.EntityIdent,
		EL.StatesIdent,
		S.Name1 as [State],
		EL.LicenseNumber,
		CONVERT(NVARCHAR(10), EL.LicenseNumberExpirationDate, 101) as [LicenseNumberExpirationDate],
		EL.AddASUserIdent,
		EL.AddDateTime,
		EL.EditASUserIdent,
		EL.EditDateTime,
		EL.Active
	FROM
		EntityLicense EL WITH (NOLOCK)
		INNER JOIN
		States S WITH (NOLOCK)
			ON EL.StatesIdent = S.Ident
	WHERE 
		EntityIdent = @bntIdent
		AND EL.Active = 1
	ORDER BY
		S.Name1


		
--	PRINT '10. EntitySystem --------------------------------------------------------------------------------------------------------------------------'	
--10. EntitySystem
	SELECT DISTINCT
		ES.Ident,
		ES.EntityIdent,
		ES.SystemTypeIdent,
		ST.Name1 as [SystemType],
		ES.Name1,
		CONVERT(NVARCHAR, ES.InstalationDate, 101) as [InstalationDate],
		CONVERT(NVARCHAR, ES.GoLiveDate, 101) as [GoLiveDate],
		CONVERT(NVARCHAR, ES.DecomissionDate, 101) as [DecomissionDate],
		ES.AddASUserIdent,
		ES.AddDateTime,
		ES.EditASUserIdent,
		ES.EditDateTime,
		ES.Active
	FROM
		EntitySystem ES WITH (NOLOCK)
		INNER JOIN
		SystemType ST WITH (NOLOCK)
			ON ES.SystemTypeIdent = ST.Ident
	WHERE 
		EntityIdent = @bntIdent
		AND ES.Active = 1
		AND ST.Active = 1
	ORDER BY
		ES.Name1
		

--	PRINT '11. EntityOtherID --------------------------------------------------------------------------------------------------------------------------'	
--11. EntityOtherID
	SELECT DISTINCT
		Ident,
		EntityIdent,
		IDType,
		IDNumber,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	FROM
		EntityOtherID EOID WITH (NOLOCK)
	WHERE 
		EntityIdent = @bntIdent
		AND EOID.Active = 1
	ORDER BY
		EOID.IDType



		

	--Get Projects

	IF (@bitEntityIsCustomer = 1)
	BEGIN 

--	PRINT 'GET PROJECTS Section for Customers, will only return if we are looking up a customer--------------------------------------------------------------------------------------------------------------------------'	
		INSERT INTO #tmpProjects (
			Ident,
			EntityIdent,
			Name1 ,
			EntityName ,
			ProjectManager ,
			ProjectManagerIdent ,
			DueDate ,
			PrivateProject ,
			ShowOnProfile , 
			IncludeEntireNetwork ,
			Archived ,
			ArchivedASUserIdent ,
			ArchivedDateTime ,
			AddASUserIdent ,
			AddDateTime ,
			EditASUserIdent ,
			EditDateTime ,
			Active , 
			ProjectType 
		)
		--Section for Customers, will only return if we are looking up a customer
		SELECT DISTINCT
			EP.Ident,
			EP.EntityIdent,
			EP.Name1,
			'EntityName' = @vcrEntityFullName,
			'ProjectManager' = PM.FullName,
			'ProjectManagerIdent' = PM.Ident,
			'DueDate' = CONVERT(VARCHAR(10),EP.DueDate, 101),
			EP.PrivateProject,
			EP.ShowOnProfile, 
			EP.IncludeEntireNetwork,
			EP.Archived,
			EP.ArchivedASUserIdent,
			EP.ArchivedDateTime,
			EP.AddASUserIdent,
			EP.AddDateTime,
			EP.EditASUserIdent,
			EP.EditDateTime,
			EP.Active,
			'ProjectType' = CASE EP.Archived WHEN 1 THEN 'Archived' WHEN 0 THEN 'OPEN' END
		FROM
			EntityProject EP WITH (NOLOCK)
			INNER JOIN
			Entity PM WITH (NOLOCK)
				ON EP.ProjectManagerEntityIdent = PM.Ident
		WHERE 
			EP.EntityIdent = @bntIdent
			AND EP.Active = 1

	END 
	
	IF (@bitEntityIsCustomer = 0)
	BEGIN 
		
--		PRINT 'GET PROJECTS Bring back Projects linked to an Entity--------------------------------------------------------------------------------------------------------------------------'	
		INSERT INTO #tmpProjects (
			Ident,
			EntityIdent,
			Name1 ,
			EntityName ,
			ProjectManager ,
			ProjectManagerIdent ,
			DueDate ,
			PrivateProject ,
			ShowOnProfile , 
			IncludeEntireNetwork ,
			Archived ,
			ArchivedASUserIdent ,
			ArchivedDateTime ,
			AddASUserIdent ,
			AddDateTime ,
			EditASUserIdent ,
			EditDateTime ,
			Active , 
			ProjectType 
		)
		--Bring back Projects linked to an Entity
		SELECT DISTINCT
			EP.Ident,
			EP.EntityIdent,
			EP.Name1,
			'EntityName' = @vcrEntityFullName,
			'ProjectManager' = PM.FullName,
			'ProjectManagerIdent' = PM.Ident,
			'DueDate' = CONVERT(VARCHAR(10),EP.DueDate, 101),
			EP.PrivateProject,
			EP.ShowOnProfile, 
			EP.IncludeEntireNetwork,
			EP.Archived,
			EP.ArchivedASUserIdent,
			EP.ArchivedDateTime,
			EP.AddASUserIdent,
			EP.AddDateTime,
			EP.EditASUserIdent,
			EP.EditDateTime,
			EP.Active,
			'ProjectType' = CASE EP.Archived WHEN 1 THEN 'Archived' WHEN 0 THEN 'OPEN' END
		FROM
			EntityProjectEntity EPE WITH (NOLOCK)
			INNER JOIN
			EntityProject EP WITH (NOLOCK)
				ON EPE.EntityProjectIdent = EP.Ident
			INNER JOIN
			Entity PM WITH (NOLOCK)
				ON EP.ProjectManagerEntityIdent = PM.Ident
		WHERE 
			EPE.EntityIdent = @bntIdent
			AND EPE.Active = 1
			AND EP.EntityIdent = @bntASUserIdent
			AND EP.Active = 1


--		PRINT 'GET PROJECTS Bring back Projects linked to an Entity--------------------------------------------------------------------------------------------------------------------------'	
		INSERT INTO #tmpProjects (
			Ident,
			EntityIdent,
			Name1 ,
			EntityName ,
			ProjectManager ,
			ProjectManagerIdent ,
			DueDate ,
			PrivateProject ,
			ShowOnProfile , 
			IncludeEntireNetwork ,
			Archived ,
			ArchivedASUserIdent ,
			ArchivedDateTime ,
			AddASUserIdent ,
			AddDateTime ,
			EditASUserIdent ,
			EditDateTime ,
			Active , 
			ProjectType 
		)
		--Bring back Projects where the Entity is connected via the IncludeEntireNetwork flag
		SELECT DISTINCT
			EP.Ident,
			EP.EntityIdent,
			EP.Name1,
			'EntityName' = EN.ToEntityFullName,
			'ProjectManager' = PM.FullName,
			'ProjectManagerIdent' = PM.Ident,
			'DueDate' = CONVERT(VARCHAR(10),EP.DueDate, 101),
			EP.PrivateProject,
			EP.ShowOnProfile, 
			EP.IncludeEntireNetwork,
			EP.Archived,
			EP.ArchivedASUserIdent,
			EP.ArchivedDateTime,
			EP.AddASUserIdent,
			EP.AddDateTime,
			EP.EditASUserIdent,
			EP.EditDateTime,
			EP.Active,
			'ProjectType' = CASE EP.Archived WHEN 1 THEN 'Archived' WHEN 0 THEN 'Open' END
		FROM 
			EntityProject EP WITH (NOLOCK)
			INNER JOIN
			Entity PM WITH (NOLOCK)
				ON EP.ProjectManagerEntityIdent = PM.Ident
			INNER JOIN
			Entity E WITH (NOLOCK)
				ON EP.EntityIdent = E.Ident
			INNER JOIN
			EntityNetwork EN WITH (NOLOCK)
				ON EN.FromEntityIdent = EP.EntityIdent
		WHERE 
			EP.IncludeEntireNetwork = 1
			AND EN.ToEntityIdent = @bntIdent
			AND EP.EntityIdent = @bntASUserIdent
			AND EP.Active = 1
			
	END 
	

--	PRINT '12. EntityProject --------------------------------------------------------------------------------------------------------------------------'	
	SELECT DISTINCT 
		Ident,
		EntityIdent,
		Name1 ,
		EntityName ,
		ProjectManager ,
		ProjectManagerIdent ,
		DueDate ,
		PrivateProject ,
		ShowOnProfile , 
		IncludeEntireNetwork ,
		Archived ,
		ArchivedASUserIdent ,
		ArchivedDateTime ,
		AddASUserIdent ,
		AddDateTime ,
		EditASUserIdent ,
		EditDateTime ,
		Active , 
		ProjectType 
	FROM 
		#tmpProjects WITH (NOLOCK)
	WHERE 
		EntityIdent = @bntASUserIdent
    ORDER BY 
        Name1 ASC, --then by name
        IncludeEntireNetwork DESC, -- Put the Private ones at the top
        Archived ASC, -- then by archived
        DueDate DESC -- then sort by due date

		
--	PRINT '13. EntityDelegate --------------------------------------------------------------------------------------------------------------------------'	
	-- Entity Delegate
	SELECT DISTINCT
		ED.IsDelegateOf,
		ED.EntityConnectionIdent,
		ED.FromEntityIdent,
		ED.FromEntityFullName,
		ED.ConnectionTypeIdent,
		ED.Name,
		ED.ToEntityIdent,
		ED.ToEntityFullName,
		toE.ProfilePhoto,
		ED.Active
	FROM
		EntityDelegate ED WITH (NOLOCK)
		INNER JOIN
		Entity toE WITH (NOLOCK)
			ON ED.ToEntityIdent = toE.Ident
	WHERE
		ED.FromEntityIdent = @bntIdent
		-- Scenarios
		-- 1. Get the customers delegates
		-- 2. The user is getting their profile and should see their delegates
		-- 3. The customer is looking at a profile and we should see if they are a delegate of that customer
		AND (@bitEntityIsCustomer = 1 
			OR @bntIdent = @bntASUserIdent
			OR ED.ToEntityIdent = @bntASUserIdent) 
	ORDER BY 
		ED.ToEntityFullName

		
--	PRINT '14. EntityToDo --------------------------------------------------------------------------------------------------------------------------'	
--14. EntityToDo
	SELECT DISTINCT
		ETD.Ident,
		ETD.EntityIdent,
		ETD.ToDoInitiatorTypeIdent,
		TDIT.Name1 as [ToDoInitiatorType],
		TDIT.IconClass as [ToDoInitiatorTypeIconClass],
		ETD.ToDoTypeIdent,
		TDT.Name1 as [ToDoType],
		TDT.IconClass as [ToDoTypeIconClass],
		ETD.ToDoStatusIdent,
		TDS.Name1 as [ToDoStatus],
		TDS.IconClass as [ToDoStatusIconClass],
		ETD.RegardingEntityIdent, 
		RE.FullName as [Regarding],
		RE.ProfilePhoto as [RegardingEntityProfilePhoto],
		ETD.AssigneeEntityIdent,
		E.FullName as [Assignee],
		E.ProfilePhoto as [AssigneeProfilePhoto],
		ETD.Title,
		ETD.Desc1,
		CONVERT(VARCHAR(20),ETD.StartDate, 101) as [StartDate], 
		CONVERT(VARCHAR(20),ETD.DueDate, 101) as [DueDate], 
		ETD.AddASUserIdent,
		CONVERT(VARCHAR(20),ETD.AddDateTime, 101) as [AddDateTime], 
		ETD.EditASUserIdent,
		CONVERT(VARCHAR(20),ETD.EditDateTime, 101) as [EditDateTime], 
		ETD.Active
	FROM
		EntityToDo ETD WITH (NOLOCK)
		INNER JOIN
		ToDoType TDT WITH (NOLOCK)
			ON ETD.ToDoTypeIdent = TDT.Ident
		INNER JOIN
		ToDoInitiatorType TDIT WITH (NOLOCK)
			ON ETD.ToDoInitiatorTypeIdent = TDIT.Ident
		INNER JOIN
		ToDoStatus TDS WITH (NOLOCK)
			ON ETD.ToDoStatusIdent = TDS.Ident
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON ETD.AssigneeEntityIdent = E.Ident 
		INNER JOIN
		Entity RE WITH (NOLOCK)
			ON ETD.RegardingEntityIdent = RE.Ident 
	WHERE 
		@bitEntityIsCustomer = 1
		AND ETD.Active = 1
		AND TDS.Ident <> 3
		AND ETD.EntityIdent = @bntIdent
	ORDER BY 
		CONVERT(VARCHAR(20),ETD.DueDate, 101) ASC
		
--	PRINT '15. EntityToDoCategory --------------------------------------------------------------------------------------------------------------------------'	
--15. EntityToDoCategory

	SELECT 
		Ident,
		EntityIdent,
		Name1,
		Name1 as [text],
		IconClass,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	FROM 
		EntityToDoCategory ETDC (NOLOCK)
	WHERE 
		@bitEntityIsCustomer = 1
		AND ETDC.EntityIdent = @bntIdent
		--AND ETDC.Active = 1 This is removed so that the user can have tags show that are inactive, but won't be able to select them

SELECT @EndTime=GETDATE()

--This will return execution time of your query
PRINT 'Duration ' + convert(varchar,DATEDIFF(MS,@StartTime,@EndTime) ) + ' MS'
--330 ms


	DROP TABLE #tmpProjects

--SET STATISTICS IO OFF
--SET STATISTICS TIME OFF

GO




-- EXEC uspGetEntityByIdent 370951, 370951, 306486
--EXEC uspGetEntityByIdent 2, 2, 2