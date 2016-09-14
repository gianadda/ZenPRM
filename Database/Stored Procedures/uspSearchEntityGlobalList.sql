IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspSearchEntityGlobalList') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspSearchEntityGlobalList
GO

/* uspSearchEntityGlobalList
 *
 * Advanced search
 *
 *
*/
CREATE PROCEDURE uspSearchEntityGlobalList

	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT,
	@nvrKeyword NVARCHAR(MAX),
	@nvrLocation NVARCHAR(MAX),
	@decLatitude DECIMAL(20,8) = 0.0,
	@decLongitude DECIMAL(20,8) = 0.0,
	@intDistanceInMiles INT,
	@bntResultsShown BIGINT,
	@bntSkipToIdent BIGINT = 0,
	@bitSortByIdent BIT = 0,
	@tblFilters [EntitySearchFilterTable] READONLY

AS

	SET NOCOUNT ON


	--Time tracking
	DECLARE @StartTime datetime
	DECLARE @EndTime datetime
	SELECT @StartTime=GETDATE() 

	CREATE TABLE #tmpEntity(
		Ident BIGINT,
		DisplayName NVARCHAR(MAX),
		EntityType NVARCHAR(MAX),
		Email NVARCHAR(MAX),
		NPI VARCHAR(500),
		PrimaryAddress1 NVARCHAR(MAX),
		PrimaryAddress2 NVARCHAR(MAX),
		PrimaryAddress3 NVARCHAR(MAX),
		PrimaryCity NVARCHAR(MAX),
		PrimaryState NVARCHAR(MAX),
		PrimaryZip NVARCHAR(MAX),
		ProfilePhoto NVARCHAR (MAX),
		Specialty NVARCHAR (MAX),
		Gender NVARCHAR (MAX),
		Languages NVARCHAR (MAX),
		Degree NVARCHAR (MAX),
		Payors NVARCHAR (MAX),
		AcceptingNewPatients BIT,
		SoleProvider BIT,
		Person BIT,
		Distance DECIMAL(5,1),
		Latitude DECIMAL(20,8),
		Longitude DECIMAL(20,8),
		IsInNetwork BIT,
		Registered BIT
	)




	
	DECLARE @nvrKeywordForContains NVARCHAR(MAX)
	DECLARE @nvrSQL NVARCHAR(MAX)= ''
	DECLARE @nvrEntityFilterSQL NVARCHAR(MAX) = ''
	DECLARE @nvrEntityChildFilterSQL NVARCHAR(MAX) = ''
	DECLARE @geoLocation AS GEOGRAPHY = GEOGRAPHY::Point(@decLatitude, @decLongitude, 4326)
	DECLARE @decMetersToMiles DECIMAL(20,8)
	DECLARE @decDistanceInMeters DECIMAL(20,8)
	DECLARE @bntSearchResults BIGINT

	DECLARE @bntEntitySearchFilterTypeIdent BIGINT
	DECLARE @nvrSearchValue NVARCHAR(MAX)
	DECLARE @bntEntitySearchHistoryIdent BIGINT

	--For Expanding search, let's start at 1 mile away
	DECLARE @intStartDistanceInMiles INT = 1
	DECLARE @decStartDistanceInMeters DECIMAL(20,8) = (@intStartDistanceInMiles * 1609.344)
	
	--Counter to see how far into the search we are to make sure we have covered the page of results.
	DECLARE @intCurrentRecordCount BIGINT = 0

	--Since we are in global, don't ever return more than 50K records.
	DECLARE @bntMaxResults BIGINT = 50000

	--Track to see if we are over 500 results, if so, we won't return the UFNs in the final select
	DECLARE @bitOver500Results BIT

	
	SET @decDistanceInMeters = (@intDistanceInMiles * 1609.344)
	

	
	--if the Lat/Long are empty, then get the Lat/Long from the entity
	SELECT 
		@decLatitude = E.Latitude,
		@decLongitude = E.Longitude
	FROM
		Entity E (NOLOCK)
	WHERE 
		E.Ident = @bntEntityIdent
		AND (@decLatitude = 0.0
		OR @decLongitude = 0.0)

	
	
	-- SQUARING THE CIRCLE 
	DECLARE @OffsetLat DECIMAL(20,8),           
			@OffsetLong DECIMAL(20,8),           
			@latN DECIMAL(20,8),           
			@latS DECIMAL(20,8),
			@longE DECIMAL(20,8),           
			@longW DECIMAL(20,8)
		
		-- Get offset of corners from center  in degrees
	SELECT @OffsetLat = @decDistanceInMeters/111200;
	SELECT @OffsetLong =  @decDistanceInMeters/(111200 * COS(radians(@decLatitude)));
	
	-- calculate lat and long of corners
	SELECT @longW = (@OffsetLong - @decLongitude) * -1;
	SELECT @longE = @OffsetLong + @decLongitude;
	SELECT @latN = (@OffsetLat + @decLatitude);
	SELECT @latS = (@decLatitude - @OffsetLat);


	--if a keyword was passed in, then setup the contains search
	DECLARE @nvrCONTAINS NVARCHAR(MAX) = ''
	IF (@nvrKeyword <> '')
	BEGIN
	
		SET @nvrKeywordForContains = REPLACE(LTRIM(RTRIM(@nvrKeyword)), '''', '''''')
		SET @nvrKeywordForContains = REPLACE(@nvrKeywordForContains, ' ', '*" AND "')
		SET @nvrKeywordForContains = '"' + @nvrKeywordForContains + '*"'
		SET @nvrCONTAINS = 'AND  (CONTAINS(FULLNAME, ''' + @nvrKeywordForContains + ''') OR CONTAINS(NPI, ''"' + REPLACE(REPLACE(LTRIM(RTRIM(@nvrKeyword)),'''',''),' ','') + '*"''))
									'
		SET @nvrCONTAINS = REPLACE(@nvrCONTAINS,  'AND "*"', '')
		PRINT @nvrCONTAINS

	END 
	
	--if a Skip to Ident was passed in, then setup the WHERE Clause
	DECLARE @nvrSkipTo NVARCHAR(MAX) = ''
	IF (@bitSortByIdent = 1 AND @bntSkipToIdent > 0)
		BEGIN
		SET @nvrSkipTo = 'AND E.Ident > ' + CONVERT(VARCHAR,@bntSkipToIdent) 
	END 

	--Build up the filters dynamic sql
	DECLARE entity_cursor CURSOR FOR
	SELECT
		EntitySearchFilterTypeIdent,
		SearchValue
	FROM
		@tblFilters

	OPEN entity_cursor

	FETCH NEXT FROM entity_cursor
	INTO @bntEntitySearchFilterTypeIdent, @nvrSearchValue

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



	--Start by Getting the Total Count
	SET @nvrSQL = 'SELECT 
						@bntSearchResults = COUNT(DISTINCT E.Ident)
					FROM
						ActiveEntity E WITH (NOEXPAND, INDEX(idx_ActiveEntity_LatLongSearchCountIndex)) 
						' + @nvrEntityChildFilterSQL + 
					' WHERE 
						E.Longitude < @longE 
						AND E.Latitude < @latN 
						AND E.Longitude > @longW 
						AND E.Latitude > @latS
						' + @nvrCONTAINS + @nvrEntityFilterSQL 
	--print @nvrSQL

	EXEC sp_executesql @nvrSQL,N'@geoLocation GEOGRAPHY, @decMetersToMiles DECIMAL(10,3), @decDistanceInMeters INT, @nvrKeyword NVARCHAR(MAX), @decLatitude DECIMAL(20,8), @decLongitude DECIMAL(20,8), @longW DECIMAL(20,8), @longE DECIMAL(20,8), @latN DECIMAL(20,8), @latS DECIMAL(20,8), @bntSearchResults BIGINT OUTPUT',
			@geoLocation=@geoLocation,@decMetersToMiles=@decMetersToMiles,@decDistanceInMeters=@decDistanceInMeters,@nvrKeyword=@nvrKeyword, @decLatitude=@decLatitude, @decLongitude=@decLongitude, @longW=@longW,  @longE=@longE, @latN=@latN, @latS=@latS, @bntSearchResults=@bntSearchResults OUTPUT

	-- Table 0: ResultCounts
	SELECT
		@bntSearchResults AS [TotalResults],
		@bntResultsShown AS [ResultsShown]



	IF (@bntSearchResults > @bntMaxResults AND @bntResultsShown >  @bntMaxResults) 
	BEGIN
		SET @bntResultsShown = @bntMaxResults
	END 


	IF (@bitSortByIdent <> 1)
	BEGIN

		SET @intStartDistanceInMiles = @intDistanceInMiles

	END


	--Loop through expanding the search as we go
	WHILE (@intStartDistanceInMiles <= @intDistanceInMiles)
	BEGIN

		--PRINT @intStartDistanceInMiles
	
		SET @decStartDistanceInMeters  = (@intStartDistanceInMiles * 1609.344)

			-- Get offset of corners from center  in degrees
		SELECT @OffsetLat = @decStartDistanceInMeters/111200;
		SELECT @OffsetLong =  @decStartDistanceInMeters/(111200 * COS(radians(@decLatitude)));
	
		-- calculate lat and long of corners
		SELECT @longW = (@OffsetLong - @decLongitude) * -1;
		SELECT @longE = @OffsetLong + @decLongitude;
		SELECT @latN = (@OffsetLat + @decLatitude);
		SELECT @latS = (@decLatitude - @OffsetLat);


		PRINT 'Records So Far: ' + CONVERT(VARCHAR, @intCurrentRecordCount)
		PRINT 'Current Expanded Search Miles: ' + CONVERT(VARCHAR, @intStartDistanceInMiles)
		
		SET @nvrSQL = 'SELECT DISTINCT TOP (@bntResultsShown) @intCurrentRecordCount = COUNT(E.Ident)
					FROM
							ActiveEntity E WITH(NOEXPAND, INDEX(idx_ActiveEntity_LatLongSearchCountIndex)) 
							' + @nvrEntityChildFilterSQL + 
					' WHERE 
							E.Longitude < @longE 
							AND E.Latitude < @latN 
							AND E.Longitude > @longW 
							AND E.Latitude > @latS
							' + @nvrCONTAINS +  @nvrSkipTo + @nvrEntityFilterSQL 

		EXEC sp_executesql @nvrSQL,N' @bntResultsShown BIGINT, @geoLocation GEOGRAPHY, @decMetersToMiles DECIMAL(10,3), @decDistanceInMeters INT, @nvrKeyword NVARCHAR(MAX), @decLatitude DECIMAL(20,8), @decLongitude DECIMAL(20,8), @longW DECIMAL(20,8), @longE DECIMAL(20,8), @latN DECIMAL(20,8), @latS DECIMAL(20,8), @bntSkipToIdent BIGINT, @intCurrentRecordCount BIGINT OUTPUT',
				@bntResultsShown=@bntResultsShown,@geoLocation=@geoLocation,@decMetersToMiles=@decMetersToMiles,@decDistanceInMeters=@decDistanceInMeters,@nvrKeyword=@nvrKeyword, @decLatitude=@decLatitude, @decLongitude=@decLongitude, @longW=@longW,  @longE=@longE, @latN=@latN, @latS=@latS, @bntSkipToIdent=@bntSkipToIdent, @intCurrentRecordCount=@intCurrentRecordCount OUTPUT 
				

				
		PRINT 'Records So Far: ' + CONVERT(VARCHAR, @intCurrentRecordCount)
		PRINT '-------------------------------'
		--SELECT 
		--	@intCurrentRecordCount = COUNT(Ident)
		--FROM
		--	 #tmpEntity (NOLOCK)

		IF (@intCurrentRecordCount >= @bntResultsShown OR @bntSearchResults <= @intCurrentRecordCount)
		BEGIN
	
			BREAK;

		END 

		SELECT 
			@intStartDistanceInMiles = CASE @intStartDistanceInMiles 
											WHEN 1 THEN 5
											WHEN 5 THEN 10
											WHEN 10 THEN 25
											WHEN 25 THEN 50
											WHEN 50 THEN 100
											WHEN 100 THEN 250
											WHEN 250 THEN 500
											WHEN 500 THEN 1000
											WHEN 1000 THEN 5000
											ELSE  @intStartDistanceInMiles * 2
										END 		

	END

		
		SET @nvrSQL = '
				SELECT DISTINCT TOP (@bntResultsShown) '

		-- get all entities within the location of the search. The spatial index is the fastest way to filter down from the entire table
		SET @nvrSQL = @nvrSQL + '
							E.Ident,
							E.DisplayName,
							EntityType,
							Email = CASE 
												WHEN (@bntResultsShown < 500 AND @bntResultsShown <> 0) THEN dbo.ufnGetEntityEmailListUnformattedByEntityIdent(E.Ident)
												ELSE '''' 
											END ,
							NPI = E.NPI,
							E.PrimaryAddress1,
							E.PrimaryAddress2,
							E.PrimaryAddress3,
							E.PrimaryCity, 
							PrimaryState = CASE 
												WHEN (@bntResultsShown < 500 AND @bntResultsShown <> 0) THEN dbo.ufnGetStateName1ByIdent(E.PrimaryStateIdent) 
												ELSE '''' 
											END ,
							E.PrimaryZip,
							E.ProfilePhoto,
							Specialty = CASE 
												WHEN (@bntResultsShown < 500 AND @bntResultsShown <> 0) THEN dbo.ufnGetEntitySpecialtyListByEntityIdent(E.Ident) 
												ELSE '''' 
											END ,
							Gender = CASE 
												WHEN (@bntResultsShown < 500 AND @bntResultsShown <> 0) THEN dbo.ufnGetGenderName1ByIdent(E.GenderIdent) 
												ELSE '''' 
											END ,
							Languages = CASE 
												WHEN (@bntResultsShown < 500 AND @bntResultsShown <> 0) THEN dbo.ufnGetEntityLanguageListByEntityIdent(E.Ident) 
												ELSE '''' 
											END ,
							Degree = CASE 
												WHEN (@bntResultsShown < 500 AND @bntResultsShown <> 0) THEN dbo.ufnGetEntityDegreeListByEntityIdent(E.Ident) 
												ELSE '''' 
											END ,
							Payors = CASE 
												WHEN (@bntResultsShown < 500 AND @bntResultsShown <> 0) THEN dbo.ufnGetEntityPayorListByEntityIdent(E.Ident) 
												ELSE '''' 
											END ,
							E.AcceptingNewPatients,
							E.SoleProvider,
							E.Person,
							ROUND(dbo.ufnCalculateGeoLocationDistance(@decLatitude, @decLongitude, E.Latitude, E.Longitude), 1) as [Distance],
							E.Latitude as [lat], 
							E.Longitude as [lng],
							0 AS [IsInNetwork],
							E.Registered
						FROM 
							ActiveEntity E WITH(NOEXPAND, INDEX('
							
					IF (@bitSortByIdent <> 1)
					BEGIN
						SET @nvrSQL = @nvrSQL + 'idx_ActiveEntity_LatLongSearchCountIndex)) 
						'
		
					END 
					IF (@bitSortByIdent = 1)
					BEGIN
						SET @nvrSQL = @nvrSQL  + 'idx_ActiveEntity_LatLongSearchCoveringIndex))  
						'
		
					END 

					SET @nvrSQL = @nvrSQL  + @nvrEntityChildFilterSQL + 
					' WHERE 
							E.Longitude < @longE 
							AND E.Latitude < @latN 
							AND E.Longitude > @longW 
							AND E.Latitude > @latS
							' + @nvrCONTAINS +  @nvrSkipTo + @nvrEntityFilterSQL 
							
			IF (@bitSortByIdent <> 1)
			BEGIN
				SET @nvrSQL = @nvrSQL + '
							ORDER BY 
								21
								'
			END 

			--IF (@bitSortByIdent = 1)
			--BEGIN
			--	SET @nvrSQL = @nvrSQL + '
			--				ORDER BY 
			--					Ident
			--					'
			--END 

		PRINT @nvrSQL
		EXEC sp_executesql @nvrSQL,N'@bntResultsShown BIGINT, @geoLocation GEOGRAPHY, @decMetersToMiles DECIMAL(10,3), @decDistanceInMeters INT, @nvrKeyword NVARCHAR(MAX), @decLatitude DECIMAL(20,8), @decLongitude DECIMAL(20,8), @longW DECIMAL(20,8), @longE DECIMAL(20,8), @latN DECIMAL(20,8), @latS DECIMAL(20,8), @bntSkipToIdent BIGINT',
				@bntResultsShown=@bntResultsShown,@geoLocation=@geoLocation,@decMetersToMiles=@decMetersToMiles,@decDistanceInMeters=@decDistanceInMeters,@nvrKeyword=@nvrKeyword, @decLatitude=@decLatitude, @decLongitude=@decLongitude, @longW=@longW,  @longE=@longE, @latN=@latN, @latS=@latS, @bntSkipToIdent=@bntSkipToIdent
				
	exec uspAddEntitySearchHistory @bntEntityIdent,1,@bntSearchResults,@nvrKeyword,@nvrLocation,@decLatitude,@decLongitude,@intDistanceInMiles,@tblFilters,@bntEntitySearchHistoryIdent OUTPUT


	DROP TABLE #tmpEntity



	SELECT @EndTime=GETDATE()

	--This will return execution time of your query
	PRINT 'Duration ' + convert(varchar,DATEDIFF(MS,@StartTime,@EndTime) ) + ' MS'
	--330 ms

GO

/**************************

--UPDATE Entity SET Customer = 1, SystemRoleIdent = 1 WHERE Ident = 4623494


exec uspSearchEntityGlobalList
			@bntEntityIdent = 306485,
			@bntASUserIdent = 306486,
			@nvrKeyword = 'southcoast physician',
			@nvrLocation = '',
			@decLatitude = 42.8667771,
			@decLongitude = -78.8750644,
			@intDistanceInMiles = 5000,
			@bntResultsShown = 10,
			@bntSkipToIdent = 0,
			@bitSortByIdent = 1

exec uspSearchEntityGlobalList
			@bntEntityIdent = 306485,
			@bntASUserIdent = 306486,
			@nvrKeyword = '',
			@nvrLocation = '',
			@decLatitude = 42.8667771,
			@decLongitude = -78.8750644,
			@intDistanceInMiles = 250,
			@bntResultsShown = 1000000,
			@bntSkipToIdent = 508457,
			@bitSortByIdent = 1

exec uspSearchEntityGlobalList
			@bntEntityIdent = 306485,
			@bntASUserIdent = 306486,
			@nvrKeyword = '',
			@nvrLocation = '',
			@decLatitude = 42.8667771,
			@decLongitude = -78.8750644,
			@intDistanceInMiles = 250,
			@bntResultsShown = 1000000,
			@bntSkipToIdent = 600267,
			@bitSortByIdent = 1

**************************/


/*

exec uspSearchEntityGlobalList
			@bntEntityIdent = 306485,
			@bntASUserIdent = 306486,
			@nvrKeyword = '',
			@nvrLocation = '',
			@decLatitude = 42.8667771,
			@decLongitude = -78.8750644,
			@intDistanceInMiles = 500,
			@bntResultsShown = 10000000,
			@bntSkipToIdent = 0,
			@bitSortByIdent = 1

exec uspSearchEntityGlobalList
			@bntEntityIdent = 306485,
			@bntASUserIdent = 306486,
			@nvrKeyword = '',
			@nvrLocation = '',
			@decLatitude = 42.8667771,
			@decLongitude = -78.8750644,
			@intDistanceInMiles = 500,
			@bntResultsShown = 10000000,
			@bntSkipToIdent = 480624,
			@bitSortByIdent = 1


exec uspSearchEntityGlobalList
			@bntEntityIdent = 306485,
			@bntASUserIdent = 306486,
			@nvrKeyword = '',
			@nvrLocation = '',
			@decLatitude = 42.8667771,
			@decLongitude = -78.8750644,
			@intDistanceInMiles = 500,
			@bntResultsShown = 10000000,
			@bntSkipToIdent = 574247,
			@bitSortByIdent = 1


			
*/



/*
exec uspSearchEntityGlobalList
			@bntEntityIdent = 306485,
			@bntASUserIdent = 306486,
			@nvrKeyword = 'Jones M',
			@nvrLocation = '',
			@decLatitude = 42.8667771,
			@decLongitude = -78.8750644,
			@intDistanceInMiles = 5,
			@bntResultsShown = 10,
			@bntSkipToIdent = 0,
			@bitSortByIdent = 0

*/

--AND  (CONTAINS(FULLNAME, '"Mi*"') OR CONTAINS(NPI, '"Mi*"'))
--AND  (CONTAINS(FULLNAME, '"Mi*" AND "*"') OR CONTAINS(NPI, '"Mi*"'))

--declare @p [EntitySearchFilterTable]

--insert into @p(Ident,EntitySearchFilterTypeIdent ,EntitySearchOperatorIdent,EntityProjectRequirementIdent,ReferenceIdent,SearchValue)
--            Values(1,3,0,0,0,261)

--exec uspSearchEntityGlobalList
--            @bntEntityIdent = 306485,
--            @bntASUserIdent = 306486,
--            @nvrKeyword = '',
--            @nvrLocation = '14203',
--            @decLatitude = 42.8667771,
--            @decLongitude = -78.8750644,
--            @intDistanceInMiles = 10,
--            @bntResultsShown = 1000000,
--            @bntSkipToIdent = 0,
--            @bitSortByIdent = 1,
--            @tblFilters=@p