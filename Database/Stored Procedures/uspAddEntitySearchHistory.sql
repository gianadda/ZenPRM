IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntitySearchHistory') 
	and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspAddEntitySearchHistory
GO

/* uspAddEntitySearchHistory
 *
 *	Adds a record into EntitySearchHistory table 
 *
 */
CREATE PROCEDURE uspAddEntitySearchHistory

	@bntEntityIdent BIGINT,
	@bitGlobalSearch BIT,
	@bntSearchResultsReturned BIGINT,
	@nvrKeyword NVARCHAR(MAX),
	@nvrLocation NVARCHAR(MAX),
	@decLatitude DECIMAL(20,8),
	@decLongitude DECIMAL(20,8),
	@intDistanceInMiles INT,
	@tblFilters [EntitySearchFilterTable] READONLY,
	@bntEntitySearchHistoryIdent BIGINT OUTPUT

AS

	INSERT INTO EntitySearchHistory(
		EntityIdent,
		SearchDateTime,
		GlobalSearch,
		SearchResultsReturned,
		Keyword,
		Location,
		Latitude,
		Longitude,
		DistanceInMiles
	)
	SELECT
		EntityIdent = @bntEntityIdent,
		SearchDateTime = dbo.ufnGetMyDate(),
		GlobalSearch = @bitGlobalSearch,
		SearchResultsReturned = @bntSearchResultsReturned,
		Keyword = @nvrKeyword,
		Location = @nvrLocation,
		Latitude = @decLatitude,
		Longitude = @decLongitude,
		DistanceInMiles = @intDistanceInMiles

	SET @bntEntitySearchHistoryIdent = SCOPE_IDENTITY()

	INSERT INTO EntitySearchHistoryFilter(
		EntitySearchHistoryIdent,
		EntitySearchFilterTypeIdent,
		EntitySearchOperatorIdent,
		EntityProjectRequirementIdent,
		ReferenceIdent,
		SearchValue
	)
	SELECT
		EntitySearchHistoryIdent = @bntEntitySearchHistoryIdent,
		EntitySearchFilterTypeIdent = tF.EntitySearchFilterTypeIdent,
		EntitySearchOperatorIdent = tF.EntitySearchOperatorIdent,
		EntityProjectRequirementIdent = tF.EntityProjectRequirementIdent,
		ReferenceIdent = tF.ReferenceIdent,
		SearchValue = tF.SearchValue
	FROM
		@tblFilters tF

GO