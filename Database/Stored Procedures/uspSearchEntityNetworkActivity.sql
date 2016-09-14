IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspSearchEntityNetworkActivity') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspSearchEntityNetworkActivity
GO

/* uspSearchEntityNetworkActivity
 *
 * Advanced Search, in network, with optional filters and including the User Activity Information
 *
 *
*/
CREATE PROCEDURE uspSearchEntityNetworkActivity

	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT,
	@nvrKeyword NVARCHAR(MAX),
	@nvrLocation NVARCHAR(MAX),
	@decLatitude DECIMAL(20,8) = 0.0,
	@decLongitude DECIMAL(20,8) = 0.0,
	@intDistanceInMiles INT,
	@bntResultsShown BIGINT,
	@intPageNumber INT,
	@bitPageChanged BIT,

	@bntActivityTypeGroupIdent BIGINT,
	@dteStartDate SMALLDATETIME,
	@dteEndDate SMALLDATETIME,
	@intDateDiff INT,
	
	@tblFilters [EntitySearchFilterTable] READONLY

AS

	SET NOCOUNT ON

	DECLARE @nvrSQL NVARCHAR(MAX)
	DECLARE	@GETDATE SMALLDATETIME

	DECLARE @intOffset INT
	DECLARE @bntSearchResults BIGINT
	DECLARE @bntTotalActivity BIGINT
	DECLARE @intFilterCount INT

	SET @GETDATE = GETDATE()
	SET @intOffset = (@intPageNumber * @bntResultsShown)
	SET @bntTotalActivity = @bntResultsShown
	SET @intFilterCount = 0

	CREATE TABLE #tmpActivityRecords(
		Ident BIGINT,
		ActivityDateTime DATETIME,
		EntityIdent BIGINT,
		Entity NVARCHAR(MAX),
		EntityProfilePhoto NVARCHAR(MAX),
		ActivityType NVARCHAR(500),
		ActivityDescription NVARCHAR(MAX),
		UpdatedEntityIdent BIGINT,
		UpdatedEntity NVARCHAR(MAX),
		UpdatedEntityProfilePhoto NVARCHAR(MAX),
	)

	CREATE TABLE #tmpEntityResults(
		EntityIdent BIGINT,
		DisplayName NVARCHAR(MAX),
		Person BIT,
		Distance DECIMAL(5,1),
		SearchResults BIGINT,
		EntitySearchHistoryIdent BIGINT
	)
	
	INSERT INTO #tmpEntityResults(
		EntityIdent,
		DisplayName,
		Person,
		Distance,
		SearchResults,
		EntitySearchHistoryIdent
	)
	EXEC uspEntitySearchOutput @bntEntityIdent, @bntASUserIdent, @nvrKeyword, @nvrLocation, @decLatitude, @decLongitude, @intDistanceInMiles, 0, @tblFilters

	-- get the number of filters passed in, if its 0, then we need to include all customer records
	SELECT
		@intFilterCount = COUNT(*)
	FROM
		@tblFilters

	SELECT
		@intFilterCount = 1
	WHERE
		@intFilterCount = 0
		AND (@nvrKeyword <> '' OR @nvrLocation <> '')

	-- THE PAGE RESULTS ARE ALWAYS RETURNED, IF WE ARENT CHANGING PAGES, THEN ALSO RETURN THE COUNTS
	INSERT INTO #tmpActivityRecords(
		Ident,
		ActivityDateTime,
		EntityIdent,
		Entity,
		EntityProfilePhoto,
		ActivityType,
		ActivityDescription,
		UpdatedEntityIdent,
		UpdatedEntity,
		UpdatedEntityProfilePhoto
	)
	SELECT
		A.Ident,
		A.ActivityDateTime,
		E.Ident as [EntityIdent],
		E.FullName as [Entity],
		E.ProfilePhoto as [EntityProfilePhoto],
		AT.Name1 as [ActivityType],
		CASE A.ClientIPAddress
			WHEN '' THEN A.ActivityDescription
			ELSE A.ActivityDescription + ' (' + A.ClientIPAddress + ')'
		END as [ActivityDescription],
		A.UpdatedEntityIdent as [UpdatedEntityIdent],
		CASE A.UpdatedEntityIdent
			WHEN A.ASUserIdent THEN ''
			ELSE dbo.ufnGetEntityFullNameByEntityIdent(A.UpdatedEntityIdent)
		END as [UpdatedEntity],
		'' as [UpdatedEntityProfilePhoto]
	FROM
		ASUserActivity A WITH (NOLOCK)
		INNER JOIN
		#tmpEntityResults tE WITH (NOLOCK)
			ON tE.EntityIdent = A.ASUserIdent
		INNER JOIN
		ActivityType AT WITH (NOLOCK)
			ON AT.Ident = A.ActivityTypeIdent
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = A.ASUserIdent
	WHERE
		A.ActivityDateTime BETWEEN @dteStartDate AND @dteEndDate
		AND AT.ShowToCustomer = 1
		AND (AT.ActivityGroupIdent = @bntActivityTypeGroupIdent OR @bntActivityTypeGroupIdent = 0)
		AND (A.CustomerEntityIdent = @bntEntityIdent OR AT.CustomerSpecific = 0) -- if customer specific, only show this customers records
	UNION -- dont allow dupes
	SELECT
		A.Ident,
		A.ActivityDateTime,
		E.Ident as [EntityIdent],
		E.FullName as [Entity],
		E.ProfilePhoto as [EntityProfilePhoto],
		AT.Name1 as [ActivityType],
		CASE A.ClientIPAddress
			WHEN '' THEN A.ActivityDescription
			ELSE A.ActivityDescription + ' (' + A.ClientIPAddress + ')'
		END as [ActivityDescription],
		A.UpdatedEntityIdent as [UpdatedEntityIdent],
		CASE A.UpdatedEntityIdent
			WHEN A.ASUserIdent THEN ''
			ELSE dbo.ufnGetEntityFullNameByEntityIdent(A.UpdatedEntityIdent)
		END as [UpdatedEntity],
		'' as [UpdatedEntityProfilePhoto]
	FROM
		ASUserActivity A WITH (NOLOCK)
		INNER JOIN
		#tmpEntityResults tE WITH (NOLOCK)
			ON tE.EntityIdent = A.UpdatedEntityIdent
		INNER JOIN
		ActivityType AT WITH (NOLOCK)
			ON AT.Ident = A.ActivityTypeIdent
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = A.ASUserIdent
	WHERE
		A.ActivityDateTime BETWEEN @dteStartDate AND @dteEndDate
		AND AT.ShowToCustomer = 1
		AND (AT.ActivityGroupIdent = @bntActivityTypeGroupIdent OR @bntActivityTypeGroupIdent = 0)
		AND (A.CustomerEntityIdent = @bntEntityIdent OR AT.CustomerSpecific = 0) -- if customer specific, only show this customers records
	UNION -- dont allow dupes
	SELECT -- if we dont filter down, we need to include all customer specific actions, so that activity doesnt occur without being visible
		A.Ident,
		A.ActivityDateTime,
		E.Ident as [EntityIdent],
		E.FullName as [Entity],
		E.ProfilePhoto as [EntityProfilePhoto],
		AT.Name1 as [ActivityType],
		CASE A.ClientIPAddress
			WHEN '' THEN A.ActivityDescription
			ELSE A.ActivityDescription + ' (' + A.ClientIPAddress + ')'
		END as [ActivityDescription],
		A.UpdatedEntityIdent as [UpdatedEntityIdent],
		CASE A.UpdatedEntityIdent
			WHEN A.ASUserIdent THEN ''
			ELSE dbo.ufnGetEntityFullNameByEntityIdent(A.UpdatedEntityIdent)
		END as [UpdatedEntity],
		'' as [UpdatedEntityProfilePhoto]
	FROM
		ASUserActivity A WITH (NOLOCK)
		INNER JOIN
		ActivityType AT WITH (NOLOCK)
			ON AT.Ident = A.ActivityTypeIdent
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = A.ASUserIdent
	WHERE
		@intFilterCount = 0
		AND A.ActivityDateTime BETWEEN @dteStartDate AND @dteEndDate
		AND AT.ShowToCustomer = 1
		AND (AT.ActivityGroupIdent = @bntActivityTypeGroupIdent OR @bntActivityTypeGroupIdent = 0)
		AND AT.CustomerSpecific = 1
		AND A.CustomerEntityIdent = @bntEntityIdent -- if customer specific, only show this customers records
	ORDER BY
		'ActivityDateTime' DESC
	OFFSET (@bntResultsShown * (@intPageNumber - 1)) ROWS
	FETCH NEXT @bntResultsShown ROWS ONLY;

	UPDATE
		tAR
	SET
		UpdatedEntityProfilePhoto = E.ProfilePhoto
	FROM
		#tmpActivityRecords tAR WITH (NOLOCK)
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = tAR.UpdatedEntityIdent
	WHERE
		tAR.UpdatedEntity <> ''

	-- table[0]: Results
	SELECT
		Ident,
		ActivityDateTime,
		EntityIdent,
		Entity,
		EntityProfilePhoto,
		ActivityType,
		ActivityDescription,
		UpdatedEntityIdent,
		UpdatedEntity,
		UpdatedEntityProfilePhoto
	FROM
		#tmpActivityRecords WITH (NOLOCK)
	ORDER BY
		ActivityDateTime DESC

	-- table[1]: ResultDetails
	SELECT
		AD.Ident,
		AD.ASUserActivityIdent,
		AD.FieldName,
		AD.OldValue,
		AD.NewValue
	FROM
		ASUserActivityDetail AD WITH (NOLOCK)
		INNER JOIN
		#tmpActivityRecords tA WITH (NOLOCK)
			ON tA.Ident = AD.ASUserActivityIdent
	ORDER BY
		tA.ActivityDateTime DESC,
		AD.FieldName ASC

	-- IF WE ARENT CHANGING PAGES, THEN ALSO RETURN THE COUNTS
	IF (@bitPageChanged = 0)

	BEGIN

		CREATE TABLE #tmpActivity(
			Ident BIGINT,
			ASUserIdent BIGINT,
			ActivityDateTime DATETIME,
			ActivityTypeGroupIdent BIGINT
		)

		CREATE INDEX idx_tmpActivity_ASUserIdent ON #tmpActivity(ASUserIdent)
		CREATE INDEX idx_tmpActivity_ActivityDateTime ON #tmpActivity(ActivityDateTime)
		CREATE INDEX idx_tmpActivity_ActivityTypeGroupIdent ON #tmpActivity(ActivityTypeGroupIdent)

		SELECT TOP 1
			@bntSearchResults = SearchResults
		FROM
			#tmpEntityResults WITH (NOLOCK)

		INSERT INTO #tmpActivity(
			Ident,
			ASUserIdent,
			ActivityDateTime,
			ActivityTypeGroupIdent
		)
		SELECT -- first get the activity where the user performing the action matches the search Criteria
			A.Ident,
			A.ASUserIdent,
			A.ActivityDateTime,
			AT.ActivityGroupIdent
		FROM
			ASUserActivity A WITH (NOLOCK)
			INNER JOIN
			#tmpEntityResults tE WITH (NOLOCK)
				ON tE.EntityIdent = A.ASUserIdent
			INNER JOIN
			ActivityType AT WITH (NOLOCK)
				ON AT.Ident = A.ActivityTypeIdent
		WHERE
			A.ActivityDateTime BETWEEN @dteStartDate AND @dteEndDate
			AND AT.ShowToCustomer = 1
			AND (AT.ActivityGroupIdent = @bntActivityTypeGroupIdent OR @bntActivityTypeGroupIdent = 0)
			AND (A.CustomerEntityIdent = @bntEntityIdent OR AT.CustomerSpecific = 0) -- if customer specific, only show this customers records
		UNION
		SELECT -- then get the activity where the user updated by the action matches the search Criteria
			A.Ident,
			A.ASUserIdent,
			A.ActivityDateTime,
			AT.ActivityGroupIdent
		FROM
			ASUserActivity A WITH (NOLOCK)
			INNER JOIN
			#tmpEntityResults tE WITH (NOLOCK)
				ON tE.EntityIdent = A.UpdatedEntityIdent
			INNER JOIN
			ActivityType AT WITH (NOLOCK)
				ON AT.Ident = A.ActivityTypeIdent
		WHERE
			A.ActivityDateTime BETWEEN @dteStartDate AND @dteEndDate
			AND AT.ShowToCustomer = 1
			AND (AT.ActivityGroupIdent = @bntActivityTypeGroupIdent OR @bntActivityTypeGroupIdent = 0)
			AND (A.CustomerEntityIdent = @bntEntityIdent OR AT.CustomerSpecific = 0) -- if customer specific, only show this customers records
		UNION
		SELECT -- if we dont filter down, we need to include all customer specific actions, so that activity doesnt occur without being visible
			A.Ident,
			A.ASUserIdent,
			A.ActivityDateTime,
			AT.ActivityGroupIdent
		FROM
			ASUserActivity A WITH (NOLOCK)
			INNER JOIN
			ActivityType AT WITH (NOLOCK)
				ON AT.Ident = A.ActivityTypeIdent
			INNER JOIN
			Entity E WITH (NOLOCK)
				ON E.Ident = A.ASUserIdent
		WHERE
			@intFilterCount = 0
			AND A.ActivityDateTime BETWEEN @dteStartDate AND @dteEndDate
			AND AT.ShowToCustomer = 1
			AND (AT.ActivityGroupIdent = @bntActivityTypeGroupIdent OR @bntActivityTypeGroupIdent = 0)
			AND AT.CustomerSpecific = 1
			AND A.CustomerEntityIdent = @bntEntityIdent -- if customer specific, only show this customers records	

		SELECT
			@bntTotalActivity = COUNT(Ident)
		FROM
			#tmpActivity WITH (NOLOCK)

		-- table 2: ResultCounts
		SELECT
			@bntSearchResults AS [TotalResults],
			@bntResultsShown AS [ResultsShown],
			@bntTotalActivity AS [TotalActivity]

		-- if we are searching by a particular activity type, then return top 10 users
		IF (@bntActivityTypeGroupIdent > 0)
		
			BEGIN

				SELECT TOP 10
					E.Ident,
					E.FullName as [Name1],
					COUNT(tA.Ident) as [TotalCount]
				FROM
					#tmpActivity tA WITH (NOLOCK)
					INNER JOIN
					Entity E WITH (NOLOCK)
						ON E.Ident = tA.ASUserIdent
				GROUP BY
					E.Ident,
					E.Fullname
				ORDER BY
					COUNT(tA.Ident) DESC,
					E.FullName ASC

			END

		-- otherwise, return top activity types
		IF (@bntActivityTypeGroupIdent = 0)
		
			BEGIN

				SELECT
					ATG.Ident,
					ATG.Name1,
					COUNT(tA.Ident) as [TotalCount]
				FROM
					#tmpActivity tA WITH (NOLOCK)
					INNER JOIN
					ActivityTypeGroup ATG WITH (NOLOCK)
						ON ATG.Ident = tA.ActivityTypeGroupIdent
				GROUP BY
					ATG.Ident,
					ATG.Name1
				ORDER BY
					COUNT(tA.Ident) DESC,
					ATG.Name1 ASC

			END

		-- if we are searching today or yesterday, then group by hour
		IF (@intDateDiff <= 2)
		
			BEGIN
				

				CREATE TABLE #tmpIntervals(
					Interval INT,
					TotalCount BIGINT
				)

				-- create a blank entry for each hour of the day, well aggregate below
				INSERT INTO #tmpIntervals(Interval,TotalCount)
				VALUES (0,0),(1,0),(2,0),(3,0),(4,0),(5,0),(6,0),(7,0),(8,0),(9,0),(10,0),(11,0),(12,0),
						(13,0),(14,0),(15,0),(16,0),(17,0),(18,0),(19,0),(20,0),(21,0),(22,0),(23,0),(24,0)
					
				INSERT INTO #tmpIntervals(
					Interval,
					TotalCount
				)
				SELECT
					DATEPART(hh, tA.ActivityDateTime) as [Interval],
					COUNT(tA.Ident) as [TotalCount]
				FROM
					#tmpActivity tA WITH (NOLOCK)
				GROUP BY
					DATEPART(hh, tA.ActivityDateTime)
				
				SELECT
					Interval,
					SUM(TotalCount) AS [TotalCount]
				FROM
					#tmpIntervals
				GROUP BY
					Interval
				ORDER BY
					Interval

				DROP TABLE #tmpIntervals

			END

		-- otherwise, group by day
		IF (@intDateDiff > 2)
		
			BEGIN

				CREATE TABLE #tmpDayIntervals(
					MonthInterval INT,
					DayInterval INT,
					TotalCount BIGINT
				)

				DECLARE @intInterval INT
				DECLARE @dteIntervalDate DATE

				SET @intInterval = 0
				SET @dteIntervalDate = @dteEndDate

				-- insert all the dates within this range, well aggregate at the bottom
				WHILE (@dteIntervalDate >= @dteStartDate)

					BEGIN

						INSERT INTO #tmpDayIntervals(
							MonthInterval,
							DayInterval,
							TotalCount
						)
						SELECT
							DATEPART(MM,@dteIntervalDate),
							DATEPART(dd,@dteIntervalDate),
							0

						SET @intInterval = @intInterval - 1
						SET @dteIntervalDate = DATEADD(dd,@intInterval,@dteEndDate)

					END -- WHILE

					INSERT INTO #tmpDayIntervals(
						MonthInterval,
						DayInterval,
						TotalCount
					)
					SELECT
						DATEPART(MM, tA.ActivityDateTime),
						DATEPART(dd, tA.ActivityDateTime),
						COUNT(tA.Ident)
					FROM
						#tmpActivity tA WITH (NOLOCK)
					GROUP BY
						DATEPART(MM, tA.ActivityDateTime),
						DATEPART(dd, tA.ActivityDateTime)

					SELECT
						CAST(MonthInterval AS NVARCHAR(2)) + '/' + CAST(DayInterval AS NVARCHAR(2)) as [Interval],
						SUM(TotalCount) AS [TotalCount]
					FROM
						#tmpDayIntervals
					GROUP BY
						MonthInterval,
						DayInterval
					ORDER BY
						MonthInterval ASC,
						DayInterval ASC

					DROP TABLE #tmpDayIntervals

			END -- IF (@intDateDiff > 2)

		DROP TABLE #tmpActivity

	END -- IF (@bitPageChanged = 0)


	DROP TABLE #tmpEntityResults
	DROP TABLE #tmpActivityRecords

GO

/**************************


DECLARE @tblFilters [EntitySearchFilterTable]

INSERT INTO @tblFilters(Ident, EntitySearchFilterTypeIdent, EntitySearchOperatorIdent, EntityProjectRequirementIdent, ReferenceIdent, SearchValue)
			SELECT 1, 1, 1, 0, 10069, ''

exec uspSearchEntityNetworkActivity
			@bntEntityIdent = 306485,
			@bntASUserIdent = 306485,
			@nvrKeyword = '',
			@nvrLocation = '',
			@decLatitude = 0.0,
			@decLongitude = 0.0,
			@intDistanceInMiles = 25,
			@bntResultsShown = 100,
			@intPageNumber = 1,
			@bitPageChanged = 0,
			@bntActivityTypeGroupIdent = 0,
			@dteStartDate = '3/21/16',
			@dteEndDate = '3/21/16 23:59',
			@intDateDiff = 0

**************************/
