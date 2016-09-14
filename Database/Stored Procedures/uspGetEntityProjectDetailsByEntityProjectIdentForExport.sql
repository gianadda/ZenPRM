IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityProjectDetailsByEntityProjectIdentForExport') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityProjectDetailsByEntityProjectIdentForExport
GO

/* uspGetEntityProjectDetailsByEntityProjectIdentForExport
 *
 *
 *
 *
*/
CREATE PROCEDURE uspGetEntityProjectDetailsByEntityProjectIdentForExport

	@bntEntityProjectIdent BIGINT,
	@bntASUserIdent BIGINT

AS

	SET NOCOUNT ON

	DECLARE @bntSearchResults BIGINT
	DECLARE @nvrColumnName NVARCHAR(MAX)
	DECLARE @nvrColumnNameForPivot NVARCHAR(MAX)
	DECLARE @nvrSQL NVARCHAR(MAX)
	DECLARE @tblFilters [EntitySearchFilterTable]
	DECLARE @bntEntityIdent BIGINT

	CREATE TABLE #tmpEntityResults(
		EntityIdent BIGINT,
		DisplayName NVARCHAR(MAX),
		Person BIT,
		Distance DECIMAL(5,1),
		SearchResults BIGINT,
		EntitySearchHistoryIdent BIGINT
	)

	CREATE TABLE #tmpEntityProjectPivot(
		EntityIdent BIGINT,
		EntityProjectRequirementIdent BIGINT,
		ColumnName NVARCHAR(MAX),
		ColumnValue NVARCHAR(MAX)
	)

	CREATE NONCLUSTERED INDEX idx_tmpEntityProjectPivot_SearchCoveringIndex ON #tmpEntityProjectPivot(EntityIdent)
	INCLUDE (ColumnName,ColumnValue)
	
	-- create the search object for filters by members on a project
	INSERT INTO @tblFilters(Ident,EntitySearchFilterTypeIdent,EntitySearchOperatorIdent,EntityProjectRequirementIdent,ReferenceIdent,SearchValue)
	VALUES (1, 1, 1, 0, @bntEntityProjectIdent, '')

	SELECT
		@bntEntityIdent = EP.EntityIdent
	FROM
		EntityProject EP WITH (NOLOCK)
	WHERE
		EP.Ident = @bntEntityProjectIdent

	INSERT INTO #tmpEntityResults(
		EntityIdent,
		DisplayName,
		Person,
		Distance,
		SearchResults,
		EntitySearchHistoryIdent
	)
	EXEC uspEntitySearchOutput @bntEntityIdent, @bntASUserIdent, '', '', 0.0, 0.0, 0, 0, @tblFilters

	INSERT INTO #tmpEntityProjectPivot(
		EntityIdent,
		EntityProjectRequirementIdent,
		ColumnName,
		ColumnValue
	)
	SELECT DISTINCT
		tE.EntityIdent,
		EPR.Ident,
		ColumnName = LEFT(EPR.Label,128),
		''
	FROM
		#tmpEntityResults tE WITH (NOLOCK),
		@tblFilters tF
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = tF.ReferenceIdent
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.EntityProjectIdent = EP.Ident
		INNER JOIN
		RequirementType RT WITH (NOLOCK)
			ON RT.Ident = EPR.RequirementTypeIdent
	WHERE
		tF.ReferenceIdent > 0
		AND EPR.Active = 1
		AND RT.RequiresAnswer = 1
		
	-- handle all the basic data types first. we'll get the remaining ones later
	UPDATE
		tEPP
	SET
		ColumnValue = CASE WHEN ISDATE(EPEAV.Value1) = 1 THEN CONVERT(VARCHAR(MAX),EPEAV.Value1, 101) ELSE CONVERT(VARCHAR(MAX),EPEAV.Value1) END
	FROM
		#tmpEntityProjectPivot tEPP WITH (NOLOCK)
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.Ident = tEPP.EntityProjectRequirementIdent
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityProjectIdent = EPR.EntityProjectIdent
			AND EPE.EntityIdent = tEPP.EntityIdent
		INNER JOIN
		EntityProjectEntityAnswer EPEA WITH (NOLOCK)
			ON EPEA.EntityProjectEntityIdent = EPE.Ident
			AND EPEA.EntityProjectRequirementIdent = EPR.Ident
		INNER JOIN
		EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
			ON EPEAV.EntityProjectEntityAnswerIdent = EPEA.Ident
		INNER JOIN
		RequirementType RT WITH (NOLOCK)
			ON RT.Ident = EPR.RequirementTypeIdent
	WHERE
		EPE.Active = 1
		AND EPEA.Active = 1
		AND EPEAV.Active = 1
		AND RT.AllowMultipleOptions = 0
		AND RT.IsFileUpload = 0

	-- only show the file name on for File Upload questions
	UPDATE
		tEPP
	SET
		ColumnValue = EPEAV.Value1
	FROM
		#tmpEntityProjectPivot tEPP WITH (NOLOCK)
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.Ident = tEPP.EntityProjectRequirementIdent
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityProjectIdent = EPR.EntityProjectIdent
			AND EPE.EntityIdent = tEPP.EntityIdent
		INNER JOIN
		EntityProjectEntityAnswer EPEA WITH (NOLOCK)
			ON EPEA.EntityProjectEntityIdent = EPE.Ident
			AND EPEA.EntityProjectRequirementIdent = EPR.Ident
		INNER JOIN
		EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
			ON EPEAV.EntityProjectEntityAnswerIdent = EPEA.Ident
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = EPR.EntityProjectIdent
		INNER JOIN
		RequirementType RT WITH (NOLOCK)
			ON RT.Ident = EPR.RequirementTypeIdent
	WHERE
		EPE.Active = 1
		AND EPEA.Active = 1
		AND EPEAV.Active = 1
		AND RT.IsFileUpload = 1
		AND EPEAV.Name1 = 'FileName'

	--For option Lists & tags
	UPDATE
		tEPP
	SET
		ColumnValue = STUFF((
								SELECT 
									'; ' + CASE EPEAV.Name1 WHEN '' THEN EPEAV.Value1 ELSE EPEAV.Name1 END + ''
								FROM
									#tmpEntityProjectPivot tEPPi WITH (NOLOCK)
									INNER JOIN
									EntityProjectRequirement EPR WITH (NOLOCK)
										ON EPR.Ident = tEPPi.EntityProjectRequirementIdent
									INNER JOIN
									EntityProjectEntity EPE WITH (NOLOCK)
										ON EPE.EntityIdent = tEPPi.EntityIdent
										AND EPE.EntityProjectIdent = EPR.EntityProjectIdent
									INNER JOIN
									EntityProjectEntityAnswer EPEA WITH (NOLOCK)
										ON EPEA.EntityProjectRequirementIdent = EPR.Ident
										AND EPEA.EntityProjectEntityIdent = EPE.Ident
									INNER JOIN
									EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
										ON EPEAV.EntityProjectEntityAnswerIdent = EPEA.Ident
									INNER JOIN
									RequirementType RT WITH (NOLOCK)
										ON RT.Ident = EPR.RequirementTypeIdent
								WHERE 
									tEPPI.EntityIdent = tEPP.EntityIdent
									AND tEPPI.EntityProjectRequirementIdent = tEPP.EntityProjectRequirementIdent
									AND RT.AllowMultipleOptions = 1
									AND EPE.Active = 1
									AND EPEA.Active = 1
									AND EPEAV.Active = 1
									AND (UPPER(EPEAV.Value1) = 'TRUE' OR EPEAV.Name1 = '')
								GROUP BY
									EPEAV.Name1,
									EPEAV.Value1
								ORDER BY
									EPEAV.Name1 ASC
							for xml path(''), type
						).value('.', 'varchar(max)'), 1, 1, '')  
	FROM
		#tmpEntityProjectPivot tEPP WITH (NOLOCK)
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.Ident = tEPP.EntityProjectRequirementIdent
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = EPR.EntityProjectIdent
		INNER JOIN
		RequirementType RT WITH (NOLOCK)
			ON RT.Ident = EPR.RequirementTypeIdent
	WHERE
		RT.AllowMultipleOptions = 1

	--Address stuff for Ident 12
	UPDATE
		tEPP
	SET
		ColumnValue = STUFF((
								SELECT 
									'; ' + EPEAV.Name1 + ': ' + EPEAV.Value1 +''
								FROM
									#tmpEntityProjectPivot tEPPi WITH (NOLOCK)
									INNER JOIN
									EntityProjectRequirement EPR WITH (NOLOCK)
										ON EPR.Ident = tEPPi.EntityProjectRequirementIdent
									INNER JOIN
									EntityProjectEntity EPE WITH (NOLOCK)
										ON EPE.EntityIdent = tEPPi.EntityIdent
										AND EPE.EntityProjectIdent = EPR.EntityProjectIdent
									INNER JOIN
									EntityProjectEntityAnswer EPEA WITH (NOLOCK)
										ON EPEA.EntityProjectRequirementIdent = EPR.Ident
										AND EPEA.EntityProjectEntityIdent = EPE.Ident
									INNER JOIN
									EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
										ON EPEAV.EntityProjectEntityAnswerIdent = EPEA.Ident
								WHERE 
									tEPPI.EntityIdent = tEPP.EntityIdent
									AND tEPPI.EntityProjectRequirementIdent = tEPP.EntityProjectRequirementIdent
									AND EPR.RequirementTypeIdent IN (12)
									AND EPE.Active = 1
									AND EPEA.Active = 1
									AND EPEAV.Active = 1
								GROUP BY
									EPEAV.Name1,
									EPEAV.Value1
								ORDER BY
									EPEAV.Name1 ASC
							for xml path(''), type
						).value('.', 'varchar(max)'), 1, 1, '')  
	FROM
		#tmpEntityProjectPivot tEPP WITH (NOLOCK)
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.Ident = tEPP.EntityProjectRequirementIdent
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = EPR.EntityProjectIdent
	WHERE
		EPR.RequirementTypeIdent IN (12)

	
	--Hours of operation Ident 18
	UPDATE
		tEPP
	SET
		ColumnValue = dbo.ufnFormatHoursOfOperation(A.Ident)
	FROM
		#tmpEntityProjectPivot tEPP WITH (NOLOCK)
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.Ident = tEPP.EntityProjectRequirementIdent
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = EPR.EntityProjectIdent
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityIdent = tEPP.EntityIdent
			AND EPE.EntityProjectIdent = EP.Ident
		INNER JOIN
		EntityProjectEntityAnswer A WITH (NOLOCK)
			ON A.EntityProjectEntityIdent = EPE.Ident
			AND A.EntityProjectRequirementIdent = EPR.Ident
	WHERE
		EPR.RequirementTypeIdent IN (18)
		AND EPE.Active = 1
		AND A.Active = 1

	--file upload format
	UPDATE tEPP
	SET 
		ColumnValue = CASE LEN(E.OrganizationName)
					WHEN 0 THEN 'Attached File: ' + REPLACE(REPLACE(tEPP.ColumnName,' ',''),'.','') + '_' + REPLACE(E.LastName,' ','') + REPLACE(E.FirstName,' ','') + '.' + RIGHT(EPEAV.Value1, Len(EPEAV.Value1) - Charindex('.', EPEAV.Value1)) 
					ELSE 'Attached File: ' + REPLACE(REPLACE(tEPP.ColumnName,' ',''),'.','') + '_' + REPLACE(E.OrganizationName,' ','') + '.' + RIGHT(EPEAV.Value1, Len(EPEAV.Value1) - Charindex('.', EPEAV.Value1)) 
				   END
	FROM
		#tmpEntityProjectPivot tEPP WITH (NOLOCK)
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.Ident = tEPP.EntityProjectRequirementIdent
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityIdent = tEPP.EntityIdent
			AND EPE.EntityProjectIdent = EPR.EntityProjectIdent
		INNER JOIN
		EntityProjectEntityAnswer EPEA WITH (NOLOCK)
			ON EPEA.EntityProjectRequirementIdent = EPR.Ident
			AND EPEA.EntityProjectEntityIdent = EPE.Ident
		INNER JOIN
		EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
			ON EPEAV.EntityProjectEntityAnswerIdent = EPEA.Ident
		INNER JOIN
		RequirementType RT WITH (NOLOCK)
			ON RT.Ident = EPR.RequirementTypeIdent
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = EPE.EntityIdent
	WHERE 
		EPEA.Active = 1
		AND EPEAV.Active = 1
		AND RT.IsFileUpload = 1
		AND EPEAV.Name1 = 'FileName'
		AND EPE.Active = 1

	-- we need to remove the requirementIdent column to successfully pivot
	ALTER TABLE #tmpEntityProjectPivot
	DROP COLUMN EntityProjectRequirementIdent

	--Get distinct values of the PIVOT Column (Requirement Names)
	SELECT 
		@nvrColumnName= ISNULL(@nvrColumnName + ',','')  + QUOTENAME(ColumnName)
	FROM 
		(SELECT DISTINCT ColumnName as [ColumnName] FROM #tmpEntityProjectPivot WITH (NOLOCK) WHERE ColumnName <> '') as [Questions]
	
	--We'll use this in the dynamic sql below to ensure our dynamic columns are aliased properly
	SET @nvrColumnNameForPivot = REPLACE(@nvrColumnName, '],[', '],PVT.[')
	SET @nvrColumnNameForPivot = 'PVT.' + @nvrColumnNameForPivot

	SET @nvrSQL =  'SELECT DISTINCT
			E.DisplayName,
			E.OrganizationName,
			E.Prefix,
			E.LastName,
			E.FirstName,
			E.MiddleName,
			E.Suffix,			
			E.NPI,
			E.Title,
			E.MedicalSchool,
			dbo.ufnConvertBitToYesNo(E.SoleProvider) AS [SoleProvider],
			dbo.ufnConvertBitToYesNo(E.AcceptingNewPatients) AS [AcceptingNewPatients],
			E.Role1,
			E.Version1,
			P.Name1 as [PCMHStatus],
			dbo.ufnGetEntityEmailListUnformattedByEntityIdent(E.Ident) AS [Email],
			E.PrimaryAddress1,
			E.PrimaryAddress2,
			E.PrimaryAddress3,
			E.PrimaryCity,
			PS.Name1 as [PrimaryState],
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
			MS.Name1 as [MailingState],
			E.MailingZip,
			E.MailingCounty,
			E.PracticeAddress1,
			E.PracticeAddress2,
			E.PracticeAddress3,
			E.PracticeCity,
			PrS.Name1 as [PracticeState],
			E.PracticeZip,
			E.PracticeCounty,
			dbo.ufnGetEntitySpecialtyListByEntityIdent(E.Ident) AS [Specialty],
			G.Name1 AS [Gender],
			dbo.ufnGetEntityLanguageListByEntityIdent(E.Ident) AS [Languages],
			dbo.ufnGetEntityDegreeListByEntityIdent(E.Ident) AS [Degree],
			dbo.ufnGetEntityPayorListByEntityIdent(E.Ident) AS [Payors],
			E.Website,
			E.PrescriptionLicenseNumber,
			CASE E.PrescriptionLicenseNumberExpirationDate
				WHEN ''1/1/1900'' THEN ''''
				ELSE CONVERT(NVARCHAR(10),E.PrescriptionLicenseNumberExpirationDate,101)
			END as [PrescriptionLicenseNumberExpirationDate],
			E.DEANumber,
			CASE E.DEANumberExpirationDate
				WHEN ''1/1/1900'' THEN ''''
				ELSE CONVERT(NVARCHAR(10),E.DEANumberExpirationDate,101)
			END as [DEANumberExpirationDate],
			E.TaxIDNumber,
			CASE E.TaxIDNumberExpirationDate
				WHEN ''1/1/1900'' THEN ''''
				ELSE CONVERT(NVARCHAR(10),E.TaxIDNumberExpirationDate,101)
			END as [TaxIDNumberExpirationDate],
			E.MedicareUPIN,
			E.CAQHID,
			MU.Name1 as [MeaningfulUse],
			E.EIN,' + 
			@nvrColumnNameForPivot + '
		FROM
			#tmpEntityResults tE WITH (NOLOCK)
			INNER JOIN
			Entity E WITH (NOLOCK)
				ON E.Ident = tE.EntityIdent
			INNER JOIN
			PCMHStatus P WITH (NOLOCK)
				ON P.Ident = E.PCMHStatusIdent
			INNER JOIN
			States PS WITH (NOLOCK)
				ON PS.Ident = E.PrimaryStateIdent
			INNER JOIN
			States MS WITH (NOLOCK)
				ON MS.Ident = E.MailingStateIdent
			INNER JOIN
			States PrS WITH (NOLOCK)
				ON PrS.Ident = E.PracticeStateIdent
			INNER JOIN
			MeaningfulUse MU WITH (NOLOCK)
				ON MU.Ident = E.MeaningfulUseIdent
			INNER JOIN
			Gender G WITH (NOLOCK)
				ON G.Ident = E.GenderIdent
			INNER JOIN
				(
					SELECT EntityIdent, ' + @nvrColumnName + '
					FROM #tmpEntityProjectPivot
						PIVOT(MAX([ColumnValue])
						FOR [ColumnName] IN (' + @nvrColumnName + ')) AS PVTTable
				) AS PVT ON PVT.EntityIdent = tE.EntityIdent
		ORDER BY
			E.OrganizationName ASC,
			E.LastName ASC,
			E.FirstName ASC'

	-- Table 0 : Project Details
	SELECT
		EP.Ident,
		EP.EntityIdent,
		E.Fullname as [Entity],
		dbo.ufnSanitizeFileName(EP.Name1) as [ProjectName],
		EP.DueDate,
		EP.PrivateProject,
		EP.ProjectManagerEntityIdent,
		PM.FullName as [ProjectManager],
		EP.Archived,
		EP.ArchivedASUserIdent,
		EP.ArchivedDateTime,
		EP.AddASUserIdent,
		EP.AddDateTime,
		EP.EditASUserIdent,
		EP.EditDateTime,
		EP.Active
	FROM
		EntityProject EP WITH (NOLOCK)
		INNER JOIN
		Entity E WITH (NOLOCK)
			 ON E.Ident = EP.EntityIdent
		INNER JOIN
		Entity PM WITH (NOLOCK)
			ON PM.Ident = EP.ProjectManagerEntityIdent
	WHERE
		EP.Ident = @bntEntityProjectIdent

	-- Table 1: Entities
	EXEC sp_executesql @nvrSQL

	-- Table 2: All Answers that are files
	SELECT
		E.Ident as [EntityIdent],
		EFR.AnswerIdent,
		dbo.ufnSanitizeFileName(EPR.Label) as [Label],
		dbo.ufnSanitizeFileName(E.NPI) as [NPI],
		dbo.ufnSanitizeFileName(E.OrganizationName) as [OrganizationName],
		dbo.ufnSanitizeFileName(E.LastName) as [LastName],
		dbo.ufnSanitizeFileName(E.FirstName) as [FirstName],
		EFR.ProjectName,
		EFR.[FileName],
		EFR.FileSize,
		EFR.MimeType,
		EFR.FileKey
	FROM
		EntityFileRepository EFR WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntityAnswer EPEA WITH (NOLOCK)
			ON EPEA.Ident = EFR.AnswerIdent
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.Ident = EPEA.EntityProjectRequirementIdent
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.Ident = EPEA.EntityProjectEntityIdent
		INNER JOIN
		Entity E WITH (NOLOCK)
			 ON E.Ident = EPE.EntityIdent
	WHERE
		EFR.ProjectIdent = @bntEntityProjectIdent
		AND EFR.Active = 1
	ORDER BY
		EPR.Label,
		E.LastName,
		E.FirstName

	DROP TABLE #tmpEntityResults
	DROP TABLE #tmpEntityProjectPivot
		

GO