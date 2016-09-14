IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEditEntitySearch') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspAddEditEntitySearch
GO
/* uspAddEditEntitySearch
 *
 *	Adds or Updates the saved entity search
 *
 */
CREATE PROCEDURE uspAddEditEntitySearch

	@bntIdent BIGINT,
	@bntASUserIdent BIGINT,
	@bntEntityIdent BIGINT,
	@nvrName1 NVARCHAR(MAX),
	@nvrDesc1 NVARCHAR(MAX),
	@nvrCategory NVARCHAR(MAX),
	@bitBookmarkSearch BIT,
	@nvrKeyword NVARCHAR(MAX),
	@nvrLocation NVARCHAR(MAX),
	@decLatitude DECIMAL(20,8),
	@decLongitude DECIMAL(20,8),
	@intDistanceInMiles INT,
	@tblFilters [EntitySearchFilterTable] READONLY

AS

	SET NOCOUNT ON

	DECLARE @bitAccessToSearch BIT
	SET @bitAccessToSearch = 0

	IF (@bntIdent = 0)  -- only add the record if it doesnt exist

		BEGIN

			INSERT INTO EntitySearch(
				EntityIdent,
				Name1,
				Desc1,
				Category,
				BookmarkSearch,
				Keyword,
				Location,
				Latitude,
				Longitude,
				DistanceInMiles,
				Active,
				AddASUserIdent,
				AddDateTime,
				EditASUserIdent,
				EditDateTime
			)
			SELECT
				EntityIdent = @bntEntityIdent,
				Name1 = @nvrName1,
				Desc1 = @nvrDesc1,
				Category = @nvrCategory,
				BookmarkSearch = @bitBookmarkSearch,
				Keyword = @nvrKeyword,
				Location = @nvrLocation,
				Latitude = @decLatitude,
				Longitude = @decLongitude,
				DistanceInMiles = @intDistanceInMiles,
				Active = 1,
				AddASUserIdent = @bntASUserIdent,
				AddDateTime = dbo.ufnGetMyDate(),
				EditASUserIdent = 0,
				EditDateTime = '1/1/1900'

			SET @bntIdent = SCOPE_IDENTITY()

			INSERT INTO EntitySearchFilter(
				EntitySearchIdent,
				EntitySearchFilterTypeIdent,
				EntitySearchOperatorIdent,
				EntityProjectRequirementIdent,
				ReferenceIdent,
				SearchValue,
				Active,
				AddASUserIdent,
				AddDateTime,
				EditASUserIdent,
				EditDateTime
			)
			SELECT
				EntitySearchIdent = @bntIdent,
				EntitySearchFilterTypeIdent = tF.EntitySearchFilterTypeIdent,
				EntitySearchOperatorIdent = tF.EntitySearchOperatorIdent,
				EntityProjectRequirementIdent = tF.EntityProjectRequirementIdent,
				ReferenceIdent = tF.ReferenceIdent,
				SearchValue = tF.SearchValue,
				Active = 1,
				AddASUserIdent = @bntASUserIdent,
				AddDateTime = dbo.ufnGetMyDate(),
				EditASUserIdent = 0,
				EditDateTime = '1/1/1900'
			FROM
				@tblFilters tF
				
		END

	ELSE

		BEGIN

			-- ensure the user has access to this search
			SELECT
				@bitAccessToSearch = 1
			FROM
				EntitySearch WITH (NOLOCK)
			WHERE
				Ident = @bntIdent
				AND EntityIdent = @bntEntityIdent

			UPDATE
				EntitySearch
			SET
				Name1 = @nvrName1,
				Desc1 = @nvrDesc1,
				Category = @nvrCategory,
				BookmarkSearch = @bitBookmarkSearch,
				Keyword = @nvrKeyword,
				Location = @nvrLocation,
				Latitude = @decLatitude,
				Longitude = @decLongitude,
				DistanceInMiles = @intDistanceInMiles,
				EditASUserIdent = @bntASUserIdent,
				EditDateTime = dbo.ufnGetMyDate()
			WHERE
				Ident = @bntIdent
				AND @bitAccessToSearch = 1

			UPDATE
				EntitySearchFilter
			SET
				Active = 0,
				EditASUserIdent = @bntASUserIdent,
				EditDateTime = dbo.ufnGetMyDate()
			WHERE
				EntitySearchIdent = @bntIdent
				AND Active = 1
				AND @bitAccessToSearch = 1

			-- just purge and resave
			INSERT INTO EntitySearchFilter(
				EntitySearchIdent,
				EntitySearchFilterTypeIdent,
				EntitySearchOperatorIdent,
				EntityProjectRequirementIdent,
				ReferenceIdent,
				SearchValue,
				Active,
				AddASUserIdent,
				AddDateTime,
				EditASUserIdent,
				EditDateTime
			)
			SELECT
				EntitySearchIdent = @bntIdent,
				EntitySearchFilterTypeIdent = tF.EntitySearchFilterTypeIdent,
				EntitySearchOperatorIdent = tF.EntitySearchOperatorIdent,
				EntityProjectRequirementIdent = tF.EntityProjectRequirementIdent,
				ReferenceIdent = tF.ReferenceIdent,
				SearchValue = tF.SearchValue,
				Active = 1,
				AddASUserIdent = @bntASUserIdent,
				AddDateTime = dbo.ufnGetMyDate(),
				EditASUserIdent = 0,
				EditDateTime = '1/1/1900'
			FROM
				@tblFilters tF
			WHERE
				@bitAccessToSearch = 1

		END


	SELECT @bntIdent as [Ident] -- returns edited record or new row ident

GO