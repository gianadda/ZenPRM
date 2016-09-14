IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspSearchEntityNetworkWithProjectFilters') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspSearchEntityNetworkWithProjectFilters
GO

/* uspSearchEntityNetworkWithProjectFilters
 *
 * Advanced Search, in network, with project filters
 *
 *
*/
CREATE PROCEDURE uspSearchEntityNetworkWithProjectFilters

	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT,
	@nvrKeyword NVARCHAR(MAX),
	@nvrLocation NVARCHAR(MAX),
	@decLatitude DECIMAL(20,8) = 0.0,
	@decLongitude DECIMAL(20,8) = 0.0,
	@intDistanceInMiles INT,
	@bntResultsShown BIGINT,
	@tblFilters [EntitySearchFilterTable] READONLY

AS

	SET NOCOUNT ON

	DECLARE @bntSearchResults BIGINT
	DECLARE @nvrColumnName NVARCHAR(MAX)
	DECLARE @nvrColumnNameForPivot NVARCHAR(MAX)
	DECLARE @nvrSQL NVARCHAR(MAX)
	DECLARE @bntEntitySearchHistoryIdent BIGINT
	DECLARE @bntEntitySearchFilterTypeOrganizationIdent BIGINT

	SET @bntEntitySearchFilterTypeOrganizationIdent = dbo.ufnEntitySearchFilterTypeOrganizationIdent()

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

	INSERT INTO #tmpEntityResults(
		EntityIdent,
		DisplayName,
		Person,
		Distance,
		SearchResults,
		EntitySearchHistoryIdent
	)
	EXEC uspEntitySearchOutput @bntEntityIdent, @bntASUserIdent, @nvrKeyword, @nvrLocation, @decLatitude, @decLongitude, @intDistanceInMiles, @bntResultsShown, @tblFilters

	SELECT TOP 1
		@bntSearchResults = SearchResults,
		@bntEntitySearchHistoryIdent = EntitySearchHistoryIdent
	FROM
		#tmpEntityResults WITH (NOLOCK)

	INSERT INTO #tmpEntityProjectPivot(
		EntityIdent,
		EntityProjectRequirementIdent,
		ColumnName,
		ColumnValue
	)
	SELECT
		tE.EntityIdent,
		tF.EntityProjectRequirementIdent,
		'',
		''
	FROM
		#tmpEntityResults tE WITH (NOLOCK),
		@tblFilters tF
	WHERE
		tF.EntityProjectRequirementIdent > 0

	-- handle all the basic data types first. we'll get the remaining ones later
	UPDATE
		tEPP
	SET
		ColumnName = LEFT(EP.Name1 + '-' + EPR.Label,128),
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
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = EPR.EntityProjectIdent
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
		ColumnName = LEFT(EP.Name1 + '-' + EPR.Label,128),
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
		ColumnName = LEFT(EP.Name1 + '-' + EPR.Label,128),
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
		ColumnName = LEFT(EP.Name1 + '-' + EPR.Label,128),
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
		ColumnName = LEFT(EP.Name1 + '-' + EPR.Label,128),
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

	-- now handle any organizations so they appear in the search results
	INSERT INTO #tmpEntityProjectPivot(
		EntityIdent,
		EntityProjectRequirementIdent,
		ColumnName,
		ColumnValue
	)
	SELECT
		EntityIdent,
		EntityProjectRequirementIdent,
		ColumnName = 'Organizations',
		ColumnValue	= dbo.ufnGetEntityHierarchyListByEntityIdent(@bntEntityIdent,tE.EntityIdent)
	FROM
		#tmpEntityResults tE WITH (NOLOCK),
		@tblFilters tF
	WHERE
		tF.EntitySearchFilterTypeIdent = @bntEntitySearchFilterTypeOrganizationIdent

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

	-- if there are columns to pivot, do so now
	SELECT
		@nvrSQL =  'SELECT DISTINCT
			E.Ident,
			tE.DisplayName,
			E.NPI,
			ET.Name1 as [EntityType],
			dbo.ufnGetEntityEmailListUnformattedByEntityIdent(E.Ident) AS [Email],
			E.PrimaryAddress1,
			E.PrimaryAddress2,
			E.PrimaryAddress3,
			E.PrimaryCity,
			S.Name1 AS [PrimaryState],
			E.PrimaryZip,
			E.PrimaryPhone,
			E.PrimaryPhoneExtension,
			E.ProfilePhoto,
			E.Latitude AS [lat],
			E.Longitude AS [lng],
			dbo.ufnGetEntitySpecialtyListByEntityIdent(E.Ident) AS [Specialty],
			G.Name1 AS [Gender],
			dbo.ufnGetEntityLanguageListByEntityIdent(E.Ident) AS [Languages],
			dbo.ufnGetEntityDegreeListByEntityIdent(E.Ident) AS [Degree],
			dbo.ufnGetEntityPayorListByEntityIdent(E.Ident) AS [Payors],
			E.AcceptingNewPatients,
			E.SoleProvider,
			tE.Person,
			tE.Distance,
			CASE ET.IncludeInCNP
				WHEN 1 THEN CAST(0 AS BIT)
				ELSE CAST(1 AS BIT)
			END as [PrivateResource],
			CAST(1 AS BIT) as [IsInNetwork],' + -- return as column so that all dataset structures match
			@nvrColumnNameForPivot + '
		FROM
			#tmpEntityResults tE WITH (NOLOCK)
			INNER JOIN
			Entity E WITH (NOLOCK)
				ON E.Ident = tE.EntityIdent
			INNER JOIN
			EntityType ET WITH (NOLOCK)
				ON ET.Ident = E.EntityTypeIdent
			INNER JOIN
			States S WITH (NOLOCK)
				ON S.Ident = E.PrimaryStateIdent
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
			tE.Distance ASC,
			tE.DisplayName ASC'
	WHERE
		@nvrColumnName IS NOT NULL

	-- otherwise, just return the base set of columns
	SELECT
		@nvrSQL =  'SELECT DISTINCT
			E.Ident,
			tE.DisplayName,
			E.NPI,
			ET.Name1 as [EntityType],
			dbo.ufnGetEntityEmailListUnformattedByEntityIdent(E.Ident) AS [Email],
			E.PrimaryAddress1,
			E.PrimaryAddress2,
			E.PrimaryAddress3,
			E.PrimaryCity,
			S.Name1 AS [PrimaryState],
			E.PrimaryZip,
			E.PrimaryPhone,
			E.PrimaryPhoneExtension,
			E.ProfilePhoto,
			E.Latitude AS [lat],
			E.Longitude AS [lng],
			dbo.ufnGetEntitySpecialtyListByEntityIdent(E.Ident) AS [Specialty],
			G.Name1 AS [Gender],
			dbo.ufnGetEntityLanguageListByEntityIdent(E.Ident) AS [Languages],
			dbo.ufnGetEntityDegreeListByEntityIdent(E.Ident) AS [Degree],
			dbo.ufnGetEntityPayorListByEntityIdent(E.Ident) AS [Payors],
			E.AcceptingNewPatients,
			E.SoleProvider,
			tE.Person,
			tE.Distance,
			CASE ET.IncludeInCNP
				WHEN 1 THEN CAST(0 AS BIT)
				ELSE CAST(1 AS BIT)
			END as [PrivateResource],
			CAST(1 AS BIT) as [IsInNetwork] -- return as column so that all dataset structures match
		FROM
			#tmpEntityResults tE WITH (NOLOCK)
			INNER JOIN
			Entity E WITH (NOLOCK)
				ON E.Ident = tE.EntityIdent
			INNER JOIN
			EntityType ET WITH (NOLOCK)
				ON ET.Ident = E.EntityTypeIdent
			INNER JOIN
			States S WITH (NOLOCK)
				ON S.Ident = E.PrimaryStateIdent
			INNER JOIN
			Gender G WITH (NOLOCK)
				ON G.Ident = E.GenderIdent
		ORDER BY
			tE.Distance ASC,
			tE.DisplayName ASC'
	WHERE
		@nvrColumnName IS NULL

	-- Table 0: ResultCounts		
	SELECT
		@bntSearchResults AS [TotalResults],
		@bntResultsShown AS [ResultsShown],
		@bntEntitySearchHistoryIdent as [EntitySearchHistoryIdent]

	-- Table 1: Entities
	EXEC sp_executesql @nvrSQL

	DROP TABLE #tmpEntityResults
	DROP TABLE #tmpEntityProjectPivot
		
GO

/**************************

DECLARE @tblFilters [EntitySearchFilterTable]

INSERT INTO @tblFilters(Ident, EntitySearchFilterTypeIdent, EntitySearchOperatorIdent, EntityProjectRequirementIdent, ReferenceIdent, SearchValue)
			SELECT 1, 1, 30, 329, 24, ''

exec uspSearchEntityNetworkWithProjectFilters
			@bntEntityIdent = 306485,
			@bntASUserIdent = 306485,
			@nvrKeyword = '',
			@decLatitude = 0.0,
			@decLongitude = 0.0,
			@intDistanceInMiles = 25,
			@bntResultsShown = 10,
			@tblFilters = @tblFilters

**************************/

