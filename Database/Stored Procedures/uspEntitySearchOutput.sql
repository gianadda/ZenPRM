IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspEntitySearchOutput') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspEntitySearchOutput
GO

/* uspEntitySearchOutput
 *
 * Advanced Search, in network, with optional filters
 * This procedure returns entity data so it can be returned from a parent proc (i.e. pivoted)
 *
*/
CREATE PROCEDURE uspEntitySearchOutput

	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT,
	@nvrKeyword NVARCHAR(MAX),
	@nvrLocation NVARCHAR(MAX),
	@decLatitude DECIMAL(20,8) = 0.0,
	@decLongitude DECIMAL(20,8) = 0.0,
	@intDistanceInMiles INT,
	@bntResultsShown BIGINT = 0, -- if 0, return ALL results
	@tblFilters [EntitySearchFilterTable] READONLY

AS

	SET NOCOUNT ON

	DECLARE @bitLocationSearch BIT

	-- only used in geospatial indexing
	--DECLARE @geoLocation AS GEOGRAPHY = GEOGRAPHY::Point(@decLatitude, @decLongitude, 4326)
	--DECLARE @decMetersToMiles DECIMAL(10,3)
	--DECLARE @decDistanceInMeters DECIMAL(10,3)
	DECLARE @decDistanceInMiles DECIMAL(20,8)
	
	DECLARE @bntSearchResults BIGINT
	DECLARE @bntSearchCriteriaCount BIGINT
	
	DECLARE @tblEntitySearch [EntitySearchTable]
	DECLARE @tblCurrentFilters [EntitySearchFilterTable]

	DECLARE @bntEntitySearchDataTypeOptionsListIdent BIGINT
	DECLARE @bntEntitySearchDataTypeHoursOfOperationIdent BIGINT
	DECLARE @bntEntitySearchDataTypeAddressIdent BIGINT

	DECLARE @bntEntitySearchFilterTypeEmailIdent BIGINT

	DECLARE @nvrColumnName NVARCHAR(MAX)
	DECLARE @nvrColumnNameForPivot NVARCHAR(MAX)
	DECLARE @nvrSQL NVARCHAR(MAX)

	DECLARE @nvrEntityFilterSQL NVARCHAR(MAX)
	DECLARE @nvrEntityChildFilterSQL NVARCHAR(MAX)

	DECLARE @bntEntitySearchFilterTypeIdent BIGINT
	DECLARE @nvrSearchValue NVARCHAR(MAX)

	DECLARE @nvrASUserIdentString NVARCHAR(15)

	DECLARE @bntEntitySearchHistoryIdent BIGINT

	SET @bntSearchResults = 0
	SET @bitLocationSearch = 0
	SET @bntEntitySearchDataTypeOptionsListIdent = dbo.ufnEntitySearchDataTypeOptionsListIdent()
	SET @bntEntitySearchDataTypeHoursOfOperationIdent = dbo.ufnEntitySearchDataTypeHoursOfOperationIdent()
	SET @bntEntitySearchDataTypeAddressIdent = dbo.ufnEntitySearchDataTypeAddressIdent()
	SET @bntEntitySearchFilterTypeEmailIdent = dbo.ufnEntitySearchFilterTypeEmailIdent()

	SET @nvrASUserIdentString = CAST(@bntASUserIdent AS NVARCHAR(15))
	
	SET @nvrEntityFilterSQL = ''
	SET @nvrEntityChildFilterSQL = ''

	CREATE TABLE #tmpInitialEntitySearch(
        EntityIdent BIGINT,
        Distance DECIMAL(20,8)
    )

	CREATE TABLE #tmpEntitiesMatchingFilters(
		EntityIdent BIGINT,
		tmpSearchFiltersIdent BIGINT,
		MatchCount INTEGER,
		ColumnName NVARCHAR(128),
		ColumnValue NVARCHAR(MAX)
	)

	CREATE TABLE #tmpEntitiesToReturn(
		EntityIdent BIGINT,
		DisplayName NVARCHAR(MAX),
		Person BIT,
		Distance DECIMAL(20,8)
	)

	CREATE TABLE #tmpMatchingEntities(
		EntityIdent BIGINT,
		MatchedFilterCount BIGINT
	)

	CREATE TABLE #tmpPrefilteredResults(
		EntityIdent BIGINT,
		ColumnName NVARCHAR(128),
		ColumnValue NVARCHAR(MAX)
	)

	-- FIRST, lets add in our filters for the Entity Table and Entity child tables
	DECLARE entity_cursor CURSOR FOR
	SELECT
		tF.EntitySearchFilterTypeIdent,
		tF.SearchValue
	FROM
		@tblFilters tF
		INNER JOIN
		EntitySearchFilterType ESFT WITH (NOLOCK)
			ON ESFT.Ident = tF.EntitySearchFilterTypeIdent
	WHERE
		(ESFT.EntityChildFilter = 1 OR ESFT.EntityFilter = 1)

	OPEN entity_cursor
	
	FETCH NEXT FROM entity_cursor
	INTO @bntEntitySearchFilterTypeIdent, @nvrSearchValue

	-- since these are status tables, we'll build our dynamic sql and use them in the initial filter
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		SELECT
			@nvrEntityFilterSQL += CASE FT.BitValue
									WHEN 1 THEN ' AND ' + FT.ReferenceColumn + ' IN (' + REPLACE(REPLACE(REPLACE(@nvrSearchValue,'|',','),'True','1'),'False','0') + ')'
									WHEN 0 THEN ' AND ' + FT.ReferenceColumn + ' IN (' + REPLACE(@nvrSearchValue,'|',',') + ')'
								  END
		FROM
			EntitySearchFilterType FT WITH (NOLOCK)
		WHERE
			FT.Ident = @bntEntitySearchFilterTypeIdent
			AND FT.EntityFilter = 1

		SELECT
			@nvrEntityChildFilterSQL += ' INNER JOIN Entity' + FT.ReferenceTable + 'Xref WITH (NOLOCK) ON Entity' + FT.ReferenceTable + 'Xref.EntityIdent = E.Ident ' + 
										'AND Entity' + FT.ReferenceTable + 'Xref.' + FT.ReferenceTable + 'Ident IN (' + REPLACE(@nvrSearchValue,'|',',') + ') AND ' + 
										'Entity' + FT.ReferenceTable + 'Xref.Active = 1'
		FROM
			EntitySearchFilterType FT WITH (NOLOCK)
		WHERE
			FT.Ident = @bntEntitySearchFilterTypeIdent
			AND FT.EntityChildFilter = 1
		
		FETCH NEXT FROM entity_cursor
		INTO @bntEntitySearchFilterTypeIdent, @nvrSearchValue
	
	END
	
	CLOSE entity_cursor
	DEALLOCATE entity_cursor

	-- count our filters that are not entity filters
	SELECT 
		@bntSearchCriteriaCount = COUNT(tF.Ident)
	FROM
		@tblFilters tF
		INNER JOIN
		EntitySearchFilterType ESFT WITH (NOLOCK)
			ON ESFT.Ident = tF.EntitySearchFilterTypeIdent
	WHERE
		ESFT.EntityChildFilter = 0
		AND ESFT.EntityFilter = 0

	-- determine if this is a location search
	IF (@decLatitude <> 0.0 AND @decLongitude <> 0.0)
		BEGIN
			SET @bitLocationSearch = 1
		END

	---- get the meters to miles conversion
	--SELECT
	--	@decMetersToMiles = Value1
	--FROM
	--	ASApplicationVariable WITH (NOLOCK)
	--WHERE
	--	Name1 = 'MetersToMilesConversion'

	--SET @decDistanceInMeters = (@decMetersToMiles * CAST(@intDistanceInMiles AS DECIMAL(10,3)))
	SET @nvrKeyword = '%' + @nvrKeyword + '%'

	-- convert int to dec ahead of time. tho minimal, there is some cost to SQL converting on the fly
	-- this might only save time at large record sets
	SET @decDistanceInMiles = CAST(@intDistanceInMiles AS DECIMAL(10,3))

	IF (@bitLocationSearch = 1)

		BEGIN

			-- get all entities within the location of the search. The spatial index is the fastest way to filter down from the entire table, if it is a location search
			SET @nvrSQL = 'INSERT INTO #tmpInitialEntitySearch(
				EntityIdent,
				Distance
			)
			SELECT
				E.Ident,
				--CAST((E.GeoLocation.STDistance(@geoLocation) / @decMetersToMiles) AS DECIMAL(20,8)) as [Distance]
				dbo.ufnCalculateGeoLocationDistance(@decLatitude, @decLongitude, E.Latitude, E.Longitude) as [Distance]
			FROM
				EntityNetwork EN WITH (NOLOCK)
				INNER JOIN
				Entity E WITH (NOLOCK)
					ON E.Ident = EN.ToEntityIdent
				INNER JOIN
				EntityType ET WITH (NOLOCK)
					ON ET.Ident = E.EntityTypeIdent' + @nvrEntityChildFilterSQL + 
			' WHERE 
				dbo.ufnCalculateGeoLocationDistance(@decLatitude, @decLongitude, E.Latitude, E.Longitude) <= @decDistanceInMiles
				--E.GeoLocation.STDistance(@geoLocation) <= @decDistanceInMeters
				AND EN.FromEntityIdent = @bntEntityIdent
				AND EN.Active = 1
				AND (E.FullName LIKE @nvrKeyword OR E.NPI LIKE @nvrKeyword)
				AND E.Active = 1' + @nvrEntityFilterSQL + 
			' GROUP BY
				E.Ident,
				E.Latitude,
				E.Longitude'

		END

	ELSE

		BEGIN

			-- otherwise, just filter by name and NPI
			SET @nvrSQL = 'INSERT INTO #tmpInitialEntitySearch(
				EntityIdent,
				Distance
			)
			SELECT
				E.Ident,
				0
			FROM
				EntityNetwork EN WITH (NOLOCK)
				INNER JOIN
				Entity E WITH (NOLOCK)
					ON E.Ident = EN.ToEntityIdent
				INNER JOIN
				EntityType ET WITH (NOLOCK)
					ON ET.Ident = E.EntityTypeIdent' + @nvrEntityChildFilterSQL + 
			' WHERE 
				EN.FromEntityIdent = @bntEntityIdent
				AND EN.Active = 1
				AND (E.FullName LIKE @nvrKeyword OR E.NPI LIKE @nvrKeyword)
				AND E.Active = 1' + @nvrEntityFilterSQL + 
			' GROUP BY
				E.Ident'

		END

	EXEC sp_executesql @nvrSQL,N'@decDistanceInMiles DECIMAL(20,8), @bntEntityIdent BIGINT, @nvrKeyword NVARCHAR(MAX), @decLongitude DECIMAL(20,8), @decLatitude DECIMAL(20,8)',
			@decDistanceInMiles=@decDistanceInMiles,@bntEntityIdent=@bntEntityIdent,@nvrKeyword=@nvrKeyword, @decLongitude=@decLongitude, @decLatitude=@decLatitude

	-- reset our variable just in case
	SET @nvrSQL = ''

	-- since we needed to use a temp table above (SQL cannot output to a table variable) and a table variable below, well transfer the data here
    INSERT INTO @tblEntitySearch(
        EntityIdent,
        Distance
    )
    SELECT
        EntityIdent,
        Distance
    FROM
        #tmpInitialEntitySearch WITH (NOLOCK)

	------------------------------
	-- NON STANDARD ENTITY FILTERS
	------------------------------
	
	-- these are non specific entity filters (i.e. not project filters, but dont follow the generic template above)

	-- reset our search filters
	DELETE @tblCurrentFilters

	-- Next, lets get any of the search filters where they are only looking for resources who answered the question
	INSERT INTO @tblCurrentFilters(
		Ident,
		EntitySearchFilterTypeIdent,
		EntitySearchOperatorIdent,
		EntityProjectRequirementIdent,
		ReferenceIdent,
		SearchValue
	)
	SELECT
		tF.Ident,
		tF.EntitySearchFilterTypeIdent,
		tF.EntitySearchOperatorIdent,
		tF.EntityProjectRequirementIdent,
		tF.ReferenceIdent,
		tF.SearchValue
	FROM
		@tblFilters tF
		INNER JOIN
		EntitySearchFilterType ESFT WITH (NOLOCK)
			ON ESFT.Ident = tF.EntitySearchFilterTypeIdent
	WHERE
		ESFT.Ident = @bntEntitySearchFilterTypeEmailIdent

	IF EXISTS(SELECT * FROM @tblCurrentFilters)
	BEGIN

		INSERT INTO #tmpEntitiesMatchingFilters(
			EntityIdent,
			tmpSearchFiltersIdent,
			MatchCount
		)
		SELECT
			EntityIdent,
			tmpSearchFiltersIdent,
			MatchCount
		FROM 
			dbo.ufnEntitySearchEmail(@tblEntitySearch, @tblCurrentFilters)
	
	END


	------------------------------
	-- PROJECT FILTERS
	------------------------------
	-- our initial filters have been applied based on name, npi and location. Now the tricky stuff begins

	-- First, lets get any of the search filters where they are looking for resources participating on a project
	INSERT INTO @tblCurrentFilters(
		Ident,
		EntitySearchFilterTypeIdent,
		EntitySearchOperatorIdent,
		EntityProjectRequirementIdent,
		ReferenceIdent,
		SearchValue
	)
	SELECT
		tF.Ident,
		tF.EntitySearchFilterTypeIdent,
		tF.EntitySearchOperatorIdent,
		tF.EntityProjectRequirementIdent,
		tF.ReferenceIdent,
		tF.SearchValue
	FROM
		@tblFilters tF
		INNER JOIN
		EntitySearchFilterType ESFT WITH (NOLOCK)
			ON ESFT.Ident = tF.EntitySearchFilterTypeIdent
		INNER JOIN
		EntitySearchOperator ESO WITH (NOLOCK)
			ON ESO.Ident = tF.EntitySearchOperatorIdent
	WHERE
		ESFT.ProjectSpecific = 1
		AND ESO.CheckIfEntityOnProject = 1

	IF EXISTS(SELECT * FROM @tblCurrentFilters)
	BEGIN

		INSERT INTO #tmpEntitiesMatchingFilters(
			EntityIdent,
			tmpSearchFiltersIdent,
			MatchCount
		)
		SELECT
			EntityIdent,
			tmpSearchFiltersIdent,
			MatchCount
		FROM
			dbo.ufnEntitySearchProjectSpecificIsOnProject(@tblEntitySearch, @tblCurrentFilters)
	
	END

	-- reset our search filters
	DELETE @tblCurrentFilters

	-- Next, lets get any of the search filters where they are only looking for resources who answered the question
	INSERT INTO @tblCurrentFilters(
		Ident,
		EntitySearchFilterTypeIdent,
		EntitySearchOperatorIdent,
		EntityProjectRequirementIdent,
		ReferenceIdent,
		SearchValue
	)
	SELECT
		tF.Ident,
		tF.EntitySearchFilterTypeIdent,
		tF.EntitySearchOperatorIdent,
		tF.EntityProjectRequirementIdent,
		tF.ReferenceIdent,
		tF.SearchValue
	FROM
		@tblFilters tF
		INNER JOIN
		EntitySearchFilterType ESFT WITH (NOLOCK)
			ON ESFT.Ident = tF.EntitySearchFilterTypeIdent
		INNER JOIN
		EntitySearchOperator ESO WITH (NOLOCK)
			ON ESO.Ident = tF.EntitySearchOperatorIdent
	WHERE
		ESFT.ProjectSpecific = 1
		AND ESO.CheckIfAnswerComplete = 1

	IF EXISTS(SELECT * FROM @tblCurrentFilters)
	BEGIN

		INSERT INTO #tmpEntitiesMatchingFilters(
			EntityIdent,
			tmpSearchFiltersIdent,
			MatchCount
		)
		SELECT
			EntityIdent,
			tmpSearchFiltersIdent,
			MatchCount
		FROM 
			dbo.ufnEntitySearchProjectSpecificAnsweredQuestion(@tblEntitySearch, @tblCurrentFilters)
	
	END

	-- reset our search filters
	DELETE @tblCurrentFilters

	-- Next, lets get any of the search filters where they are looking for "DID NOT ANSWER"
	INSERT INTO @tblCurrentFilters(
		Ident,
		EntitySearchFilterTypeIdent,
		EntitySearchOperatorIdent,
		EntityProjectRequirementIdent,
		ReferenceIdent,
		SearchValue
	)
	SELECT
		tF.Ident,
		tF.EntitySearchFilterTypeIdent,
		tF.EntitySearchOperatorIdent,
		tF.EntityProjectRequirementIdent,
		tF.ReferenceIdent,
		tF.SearchValue
	FROM
		@tblFilters tF
		INNER JOIN
		EntitySearchFilterType ESFT WITH (NOLOCK)
			ON ESFT.Ident = tF.EntitySearchFilterTypeIdent
		INNER JOIN
		EntitySearchOperator ESO WITH (NOLOCK)
			ON ESO.Ident = tF.EntitySearchOperatorIdent
	WHERE
		ESFT.ProjectSpecific = 1
		AND ESO.CheckIfAnswerNULL = 1
		AND ESO.CheckIfAnswerComplete = 0
		AND ESO.CheckIfEntityOnProject = 0

	IF EXISTS(SELECT * FROM @tblCurrentFilters)
	BEGIN

		INSERT INTO #tmpEntitiesMatchingFilters(
			EntityIdent,
			tmpSearchFiltersIdent,
			MatchCount
		)
		SELECT
			EntityIdent,
			tmpSearchFiltersIdent,
			MatchCount
		FROM 
			dbo.ufnEntitySearchProjectSpecificDidNotAnswer(@tblEntitySearch, @tblCurrentFilters)
	
	END

	-- reset our search filters
	DELETE @tblCurrentFilters

	-- Next, lets get our project specific matches based on dynamic sql. These operators are defined in SQL tables
	INSERT INTO @tblCurrentFilters(
		Ident,
		EntitySearchFilterTypeIdent,
		EntitySearchOperatorIdent,
		EntityProjectRequirementIdent,
		ReferenceIdent,
		SearchValue
	)
	SELECT
		tF.Ident,
		tF.EntitySearchFilterTypeIdent,
		tF.EntitySearchOperatorIdent,
		tF.EntityProjectRequirementIdent,
		tF.ReferenceIdent,
		tF.SearchValue
	FROM
		@tblFilters tF
		INNER JOIN
		EntitySearchFilterType ESFT WITH (NOLOCK)
			ON ESFT.Ident = tF.EntitySearchFilterTypeIdent
		INNER JOIN
		EntitySearchOperator ESO WITH (NOLOCK)
			ON ESO.Ident = tF.EntitySearchOperatorIdent
	WHERE
		ESFT.ProjectSpecific = 1
		AND ESO.CheckIfAnswerComplete = 0
		AND ESO.CheckIfAnswerNULL = 0
		AND ESO.CheckIfEntityOnProject = 0
		AND ESO.Operator <> ''

	IF EXISTS(SELECT * FROM @tblCurrentFilters)
	BEGIN

		-- prefixing with dynamic sql so from a naming convention it doesnt overlap other functionality in this proc
		DECLARE @intDynamicSQLIdent BIGINT
		DECLARE @bntDynamicSQLRequirementIdent BIGINT
		DECLARE @bntDynamicSQLOperatorIdent BIGINT
		DECLARE @nvrDynamicSQLSearchValue NVARCHAR(MAX)
		DECLARE @nvrDynamicSQLOperator NVARCHAR(MAX)
		DECLARE @intDynamicSQLSearchLength INT

		-- NOTE, SQL Doesnt Allow nested INSERT EXECS, so we have to use table valued functions for our sub procs
		-- However, functions cannot contain DYNAMIC sql , so were just going to do everything here
		-- Not the cleanest, but is functional
		DECLARE entity_cursor CURSOR FOR
		SELECT
			Ident,
			EntityProjectRequirementIdent,
			EntitySearchOperatorIdent,
			SearchValue
		FROM
			@tblCurrentFilters

		OPEN entity_cursor

		FETCH NEXT FROM entity_cursor
		INTO @intDynamicSQLIdent, @bntDynamicSQLRequirementIdent, @bntDynamicSQLOperatorIdent, @nvrDynamicSQLSearchValue

		WHILE @@FETCH_STATUS = 0
		BEGIN

			-- the prefiltered results table is used to avoid conversion errors in sql based on the data type
			-- the dynamic sql was throwing conversion errors based on the requirement type. we thought we could
			-- resolve this with a properly placed WHERE clause, but the errors still occurred
			TRUNCATE TABLE #tmpPrefilteredResults

			INSERT INTO #tmpPrefilteredResults(
				EntityIdent,
				ColumnName,
				ColumnValue
			)
			SELECT
				tE.EntityIdent,
				LEFT(EP.Name1 + '-' + EPR.Label,128),
				EPEAV.Value1
			FROM
				EntityProject EP WITH (NOLOCK)
				INNER JOIN
				EntityProjectRequirement EPR WITH (NOLOCK)
					ON EPR.EntityProjectIdent = EP.Ident
					AND EPR.Ident = @bntDynamicSQLRequirementIdent
				INNER JOIN
				EntityProjectEntity EPE WITH (NOLOCK)
					ON EPE.EntityProjectIdent = EP.Ident
				INNER JOIN
				@tblEntitySearch tE
					ON tE.EntityIdent = EPE.EntityIdent
				INNER JOIN
				EntityProjectEntityAnswer EPEA WITH (NOLOCK)
					ON EPEA.EntityProjectEntityIdent = EPE.Ident
					AND EPEA.EntityProjectRequirementIdent = EPR.Ident
				INNER JOIN
				EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
					ON EPEAV.EntityProjectEntityAnswerIdent = EPEA.Ident
			WHERE
				EPE.Active = 1
				AND EPEA.Active = 1
				AND EPEAV.Active = 1
		
			SET @intDynamicSQLSearchLength = LEN(@nvrDynamicSQLSearchValue)

			SELECT
				@nvrDynamicSQLOperator = Operator
			FROM
				EntitySearchOperator WITH (NOLOCK)
			WHERE
				Ident = @bntDynamicSQLOperatorIdent

			SET @nvrSQL = 'INSERT INTO #tmpEntitiesMatchingFilters(
									EntityIdent,
									tmpSearchFiltersIdent,
									MatchCount
								)
								SELECT
									EntityIdent,
									@bntIdent,
									1
								FROM
									#tmpPrefilteredResults tPR WITH (NOLOCK)
                                WHERE
									' + @nvrDynamicSQLOperator


			-- need to ensure that @nvrSearch (the input from the client) is parameterized to prevent SQL injection
			EXEC sp_executesql @nvrSQL,N'@bntIdent BIGINT,@intSearchLength BIGINT,@nvrSearch NVARCHAR(MAX)',@bntIdent=@intDynamicSQLIdent,@intSearchLength=@intDynamicSQLSearchLength,@nvrSearch=@nvrDynamicSQLSearchValue

			FETCH NEXT FROM entity_cursor
			INTO @intDynamicSQLIdent, @bntDynamicSQLRequirementIdent, @bntDynamicSQLOperatorIdent, @nvrDynamicSQLSearchValue

		END
		
		CLOSE entity_cursor
		DEALLOCATE entity_cursor

	END

	-- reset our search filters
	DELETE @tblCurrentFilters

	-- Next, lets get any of the search filters where they are looking for results based on the option list (we can ignore did/did not answer, that is handled below)
	INSERT INTO @tblCurrentFilters(
		Ident,
		EntitySearchFilterTypeIdent,
		EntitySearchOperatorIdent,
		EntityProjectRequirementIdent,
		ReferenceIdent,
		SearchValue
	)
	SELECT
		tF.Ident,
		tF.EntitySearchFilterTypeIdent,
		tF.EntitySearchOperatorIdent,
		tF.EntityProjectRequirementIdent,
		tF.ReferenceIdent,
		tF.SearchValue
	FROM
		@tblFilters tF
		INNER JOIN
		EntitySearchFilterType ESFT WITH (NOLOCK)
			ON ESFT.Ident = tF.EntitySearchFilterTypeIdent
		INNER JOIN
		EntitySearchOperator ESO WITH (NOLOCK)
			ON ESO.Ident = tF.EntitySearchOperatorIdent
	WHERE
		ESFT.ProjectSpecific = 1
		AND ESO.EntitySearchDataTypeIdent = @bntEntitySearchDataTypeOptionsListIdent
		AND ESO.CheckIfAnswerNULL = 0
		AND ESO.CheckIfAnswerComplete = 0
		AND ESO.CheckIfEntityOnProject = 0

	IF EXISTS(SELECT * FROM @tblCurrentFilters)
	BEGIN

		INSERT INTO #tmpEntitiesMatchingFilters(
			EntityIdent,
			tmpSearchFiltersIdent,
			MatchCount
		)
		SELECT
			EntityIdent,
			tmpSearchFiltersIdent,
			MatchCount
		FROM
			dbo.ufnEntitySearchProjectSpecificOptionList (@tblEntitySearch, @tblCurrentFilters)

	END

	-- reset our search filters
	DELETE @tblCurrentFilters

	-- Next, lets get any of the search filters where they are looking for filters on the address questions. This has custom logic
	INSERT INTO @tblCurrentFilters(
		Ident,
		EntitySearchFilterTypeIdent,
		EntitySearchOperatorIdent,
		EntityProjectRequirementIdent,
		ReferenceIdent,
		SearchValue
	)
	SELECT
		tF.Ident,
		tF.EntitySearchFilterTypeIdent,
		tF.EntitySearchOperatorIdent,
		tF.EntityProjectRequirementIdent,
		tF.ReferenceIdent,
		tF.SearchValue
	FROM
		@tblFilters tF
		INNER JOIN
		EntitySearchFilterType ESFT WITH (NOLOCK)
			ON ESFT.Ident = tF.EntitySearchFilterTypeIdent
		INNER JOIN
		EntitySearchOperator ESO WITH (NOLOCK)
			ON ESO.Ident = tF.EntitySearchOperatorIdent
	WHERE
		ESFT.ProjectSpecific = 1
		AND ESO.EntitySearchDataTypeIdent = @bntEntitySearchDataTypeAddressIdent
		AND ESO.CheckIfAnswerNULL = 0
		AND ESO.CheckIfAnswerComplete = 0
		AND ESO.CheckIfEntityOnProject = 0

	IF EXISTS(SELECT * FROM @tblCurrentFilters)
	BEGIN

		INSERT INTO #tmpEntitiesMatchingFilters(
			EntityIdent,
			tmpSearchFiltersIdent,
			MatchCount
		)
		SELECT
			EntityIdent,
			tmpSearchFiltersIdent,
			MatchCount
		FROM
			dbo.ufnEntitySearchProjectSpecificAddress(@tblEntitySearch, @tblCurrentFilters)
	
	END
	
	-- reset our search filters
	DELETE @tblCurrentFilters

	-- Last project filter, lets get any of the search filters where they are looking for filters on the Hours of Op questions. This has custom logic too
	INSERT INTO @tblCurrentFilters(
		Ident,
		EntitySearchFilterTypeIdent,
		EntitySearchOperatorIdent,
		EntityProjectRequirementIdent,
		ReferenceIdent,
		SearchValue
	)
	SELECT
		tF.Ident,
		tF.EntitySearchFilterTypeIdent,
		tF.EntitySearchOperatorIdent,
		tF.EntityProjectRequirementIdent,
		tF.ReferenceIdent,
		tF.SearchValue
	FROM
		@tblFilters tF
		INNER JOIN
		EntitySearchFilterType ESFT WITH (NOLOCK)
			ON ESFT.Ident = tF.EntitySearchFilterTypeIdent
		INNER JOIN
		EntitySearchOperator ESO WITH (NOLOCK)
			ON ESO.Ident = tF.EntitySearchOperatorIdent
	WHERE
		ESFT.ProjectSpecific = 1
		AND ESO.EntitySearchDataTypeIdent = @bntEntitySearchDataTypeHoursOfOperationIdent
		AND ESO.CheckIfAnswerNULL = 0
		AND ESO.CheckIfAnswerComplete = 0
		AND ESO.CheckIfEntityOnProject = 0

	IF EXISTS(SELECT * FROM @tblCurrentFilters)
	BEGIN

		INSERT INTO #tmpEntitiesMatchingFilters(
			EntityIdent,
			tmpSearchFiltersIdent,
			MatchCount
		)
		SELECT
			EntityIdent,
			tmpSearchFiltersIdent,
			MatchCount 
		FROM
			dbo.ufnEntitySearchProjectSpecificHoursOfOperation(@tblEntitySearch, @tblCurrentFilters)
	
	END

	-- reset our search filters
	DELETE @tblCurrentFilters

	-- New features!, lets get any of the search filters where they are looking for filters based on Entity Hierarchy
	INSERT INTO @tblCurrentFilters(
		Ident,
		EntitySearchFilterTypeIdent,
		EntitySearchOperatorIdent,
		EntityProjectRequirementIdent,
		ReferenceIdent,
		SearchValue
	)
	SELECT
		tF.Ident,
		tF.EntitySearchFilterTypeIdent,
		tF.EntitySearchOperatorIdent,
		tF.EntityProjectRequirementIdent,
		tF.ReferenceIdent,
		tF.SearchValue
	FROM
		@tblFilters tF
		INNER JOIN
		EntitySearchFilterType ESFT WITH (NOLOCK)
			ON ESFT.Ident = tF.EntitySearchFilterTypeIdent
	WHERE
		ESFT.HierarchySpecific = 1

	IF EXISTS(SELECT * FROM @tblCurrentFilters)
	BEGIN

		INSERT INTO #tmpEntitiesMatchingFilters(
			EntityIdent,
			tmpSearchFiltersIdent,
			MatchCount
		)
		SELECT
			EntityIdent,
			tmpSearchFiltersIdent,
			MatchCount 
		FROM
			dbo.ufnEntitySearchHierarchySpecific(@bntEntityIdent, @tblEntitySearch, @tblCurrentFilters)
	
	END

	-- NOW WE ARE DONE APPLYING FILTERS 
	-- FROM HERE, RETURN ANY ENTITIES THAT MATCH ALL FILTER CRITERIA
	INSERT INTO #tmpEntitiesToReturn(
		EntityIdent,
		DisplayName,
		Person,
		Distance
	)
	SELECT TOP (@bntResultsShown)
		tE.EntityIdent,
		DisplayName = E.DisplayName,
		ET.Person,
		tE.Distance
	FROM
		@tblEntitySearch tE
		INNER JOIN
		#tmpEntitiesMatchingFilters tEMF WITH (NOLOCK)
			ON tEMF.EntityIdent = tE.EntityIdent
		INNER JOIN
		Entity E WITH (NOLOCK)
			 ON E.Ident = tE.EntityIdent
		INNER JOIN
		EntityType ET WITH (NOLOCK)
			ON ET.Ident = E.EntityTypeIdent
	WHERE
		@bntResultsShown > 0 -- if we pass in a results show variable, limit to that # of results
		AND @bntSearchCriteriaCount > 0 -- MAKE SURE THERE WERE TABLE FILTERS APPLIED!!
	GROUP BY
		tE.EntityIdent,
		ET.Person,
		E.DisplayName,
		tE.Distance
	HAVING
		SUM(tEMF.MatchCount) = @bntSearchCriteriaCount
	ORDER BY
		tE.Distance ASC, -- it doesnt matter that this is first as an order by, if we dont do a distance search all values will be the same
		'DisplayName' ASC

	INSERT INTO #tmpEntitiesToReturn(
		EntityIdent,
		DisplayName,
		Person,
		Distance
	)
	SELECT
		tE.EntityIdent,
		DisplayName = E.DisplayName,
		ET.Person,
		tE.Distance
	FROM
		@tblEntitySearch tE
		INNER JOIN
		#tmpEntitiesMatchingFilters tEMF WITH (NOLOCK)
			ON tEMF.EntityIdent = tE.EntityIdent
		INNER JOIN
		Entity E WITH (NOLOCK)
			 ON E.Ident = tE.EntityIdent
		INNER JOIN
		EntityType ET WITH (NOLOCK)
			ON ET.Ident = E.EntityTypeIdent
	WHERE
		@bntResultsShown = 0 -- if we dont pass in a results shown, then return all
		AND @bntSearchCriteriaCount > 0 -- MAKE SURE THERE WERE TABLE FILTERS APPLIED!!
	GROUP BY
		tE.EntityIdent,
		ET.Person,
		E.DisplayName,
		tE.Distance
	HAVING
		SUM(tEMF.MatchCount) = @bntSearchCriteriaCount

	-- PART 2: IF IT WAS ONLY AN ENTITY LEVEL SEARCH
	INSERT INTO #tmpEntitiesToReturn(
		EntityIdent,
		DisplayName,
		Person,
		Distance
	)
	SELECT TOP (@bntResultsShown)
		tE.EntityIdent,
		DisplayName = E.DisplayName,
		ET.Person,
		tE.Distance
	FROM
		@tblEntitySearch tE
		INNER JOIN
		Entity E WITH (NOLOCK)
			 ON E.Ident = tE.EntityIdent
		INNER JOIN
		EntityType ET WITH (NOLOCK)
			ON ET.Ident = E.EntityTypeIdent
	WHERE
		@bntResultsShown > 0 -- if we pass in a results show variable, limit to that # of results
		AND @bntSearchCriteriaCount = 0 -- MAKE SURE THERE WERE NO TABLE FILTERS APPLIED!!
	GROUP BY
		tE.EntityIdent,
		ET.Person,
		E.DisplayName,
		tE.Distance
	ORDER BY
		tE.Distance ASC, -- it doesnt matter that this is first as an order by, if we dont do a distance search all values will be the same
		'DisplayName' ASC

	INSERT INTO #tmpEntitiesToReturn(
		EntityIdent,
		DisplayName,
		Person,
		Distance
	)
	SELECT
		tE.EntityIdent,
		DisplayName = E.DisplayName,
		ET.Person,
		tE.Distance
	FROM
		@tblEntitySearch tE
		INNER JOIN
		Entity E WITH (NOLOCK)
			 ON E.Ident = tE.EntityIdent
		INNER JOIN
		EntityType ET WITH (NOLOCK)
			ON ET.Ident = E.EntityTypeIdent
	WHERE
		@bntResultsShown = 0 -- if we dont pass in a results shown, then return all
		AND @bntSearchCriteriaCount = 0 -- MAKE SURE THERE WERE NO TABLE FILTERS APPLIED!!
	GROUP BY
		tE.EntityIdent,
		ET.Person,
		E.DisplayName,
		tE.Distance

	INSERT INTO #tmpMatchingEntities(
		EntityIdent,
		MatchedFilterCount
	)
	SELECT
		tEMF.EntityIdent,
		SUM(tEMF.MatchCount)
	FROM
		#tmpEntitiesMatchingFilters tEMF WITH (NOLOCK)
	GROUP BY
		tEMF.EntityIdent
	HAVING
		SUM(tEMF.MatchCount) = @bntSearchCriteriaCount

	-- if filters are applied, then get the count from the matching entity table
	IF (@bntSearchCriteriaCount > 0)

		BEGIN

			SELECT
				@bntSearchResults = COUNT(*)
			FROM
				#tmpMatchingEntities WITH (NOLOCK)

		END

	ELSE

		BEGIN

			SELECT
				@bntSearchResults = COUNT(*)
			FROM
				@tblEntitySearch

		END
	
	-- log our search history
	EXEC uspAddEntitySearchHistory @bntEntityIdent,0,@bntSearchResults,@nvrKeyword,@nvrLocation,@decLatitude,@decLongitude,@intDistanceInMiles,@tblFilters, @bntEntitySearchHistoryIdent OUTPUT

	SELECT	
		EntityIdent,
		DisplayName,
		Person,
		Distance,
		@bntSearchResults as [SearchResults],
		@bntEntitySearchHistoryIdent as [EntitySearchHistoryIdent]
	FROM
		#tmpEntitiesToReturn WITH (NOLOCK)
	ORDER BY
		Distance ASC,
		DisplayName ASC

	DROP TABLE #tmpEntitiesToReturn
	DROP TABLE #tmpEntitiesMatchingFilters
	DROP TABLE #tmpMatchingEntities
	DROP TABLE #tmpInitialEntitySearch
	DROP TABLE #tmpPrefilteredResults

GO

/**************************

DECLARE @tblFilters [EntitySearchFilterTable]

INSERT INTO @tblFilters(Ident, EntitySearchFilterTypeIdent, EntitySearchOperatorIdent, EntityProjectRequirementIdent, ReferenceIdent, SearchValue)
			SELECT 1, 1, 30, 329, 24, ''

exec uspEntitySearchOutput
			@bntEntityIdent = 306485,
			@bntASUserIdent = 306485,
			@nvrKeyword = '',
			@nvrLocation = '',
			@decLatitude = 0.0,
			@decLongitude = 0.0,
			@intDistanceInMiles = 25,
			@bntResultsShown = 10,
			@tblFilters = @tblFilters


exec uspEntitySearchOutput
			@bntEntityIdent = 306485,
			@bntASUserIdent = 306485,
			@nvrKeyword = '',
			@nvrLocation = '',
			@decLatitude = 0.01,
			@decLongitude = 0.01,
			@intDistanceInMiles = 5,
			@bntResultsShown = 10

**************************/

