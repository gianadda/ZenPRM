IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspSearchEntityNetworkWithBulkProjectAdd') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspSearchEntityNetworkWithBulkProjectAdd
GO

/* uspSearchEntityNetworkWithBulkProjectAdd
 *
 * Advanced Search, in network, with optional filters, to add resources to a project in bulk
 *
 *
*/
CREATE PROCEDURE uspSearchEntityNetworkWithBulkProjectAdd

	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT,
	@nvrKeyword NVARCHAR(MAX),
	@nvrLocation NVARCHAR(MAX),
	@decLatitude DECIMAL(20,8) = 0.0,
	@decLongitude DECIMAL(20,8) = 0.0,
	@intDistanceInMiles INT,
	@bntResultsShown BIGINT,
	@bntAddEntityProjectIdent BIGINT,
	@tblFilters [EntitySearchFilterTable] READONLY

AS

	SET NOCOUNT ON

	DECLARE @bntSearchResults BIGINT

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

	SELECT TOP 1
		@bntSearchResults = SearchResults
	FROM
		#tmpEntityResults WITH (NOLOCK)

	SELECT
		@bntSearchResults AS [TotalResults],
		@bntResultsShown AS [ResultsShown]
		
	MERGE 
		EntityProjectEntity AS [target]
	USING 
		#tmpEntityResults AS [source] 
			ON 
			([target].EntityProjectIdent = @bntAddEntityProjectIdent
				AND [target].EntityIdent = [source].EntityIdent)
    	WHEN MATCHED THEN 
		UPDATE SET 
				Active = 1,
				EditDateTime = dbo.ufnGetMyDate(),
				EditASUserIdent = @bntASUserIdent
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (
				EntityProjectIdent,
				EntityIdent,
				AddASUserIdent,
				AddDateTime,
				EditASUserIdent,
				EditDateTime,
				Active
				)
		VALUES (
				@bntAddEntityProjectIdent,
				source.EntityIdent,
				@bntASUserIdent,
				dbo.ufnGetMyDate(),
				0,
				'1/1/1900',
				1
				); -- You really do need to end this function with a semi-colon

		-- Table 0: ResultCounts
		SELECT
			@bntSearchResults AS [TotalResults],
			@bntResultsShown AS [ResultsShown],
			COUNT(*) as [ProjectEntityCount]
		FROM
			EntityProjectEntity WITH (NOLOCK)
		WHERE
			EntityProjectIdent = @bntAddEntityProjectIdent
			AND Active = 1

	DROP TABLE #tmpEntityResults 
		
GO

/**************************

exec uspSearchEntityNetworkWithBulkProjectAdd
			@bntEntityIdent = 306485,
			@bntASUserIdent = 306485,
			@nvrKeyword = '',
			@decLatitude = 0.0,
			@decLongitude = 0.0,
			@intDistanceInMiles = 25,
			@bntResultsShown = 10

**************************/

