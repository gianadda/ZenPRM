IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntitySearchHistoryByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetEntitySearchHistoryByIdent
 GO
/* uspGetEntitySearchHistoryByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE uspGetEntitySearchHistoryByIdent

	@intIdent BIGINT,
	@intEntityIdent BIGINT

AS

	SET NOCOUNT ON

	SELECT 
		Ident,
		EntityIdent,
		SearchDateTime,
		GlobalSearch,
		SearchResultsReturned,
		Keyword,
		Location,
		Latitude,
		Longitude,
		DistanceInMiles
	FROM
		EntitySearchHistory WITH (NOLOCK)
	WHERE
		Ident = @intIdent
		AND EntityIdent = @intEntityIdent

	SELECT
		Ident,
		EntitySearchHistoryIdent,
		EntitySearchFilterTypeIdent,
		EntitySearchOperatorIdent,
		EntityProjectRequirementIdent,
		ReferenceIdent,
		SearchValue
	FROM
		EntitySearchHistoryFilter WITH (NOLOCK)
	WHERE
		EntitySearchHistoryIdent = @intIdent

GO