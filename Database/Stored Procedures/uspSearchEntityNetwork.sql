IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspSearchEntityNetwork') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspSearchEntityNetwork
GO

/* uspSearchEntityNetwork
 *
 * Advanced Search, in network, with optional filters
 *
 *
*/
CREATE PROCEDURE uspSearchEntityNetwork

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

	DECLARE @bntSearchResults BIGINT,
			@bntEntitySearchHistoryIdent BIGINT

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
	EXEC uspEntitySearchOutput @bntEntityIdent, @bntASUserIdent, @nvrKeyword, @nvrLocation, @decLatitude, @decLongitude, @intDistanceInMiles, @bntResultsShown, @tblFilters

	SELECT TOP 1
		@bntSearchResults = SearchResults,
		@bntEntitySearchHistoryIdent = EntitySearchHistoryIdent
	FROM
		#tmpEntityResults WITH (NOLOCK)

	SELECT
		COALESCE(@bntSearchResults,0) AS [TotalResults],
		@bntResultsShown AS [ResultsShown],
		COALESCE(@bntEntitySearchHistoryIdent ,0) as [EntitySearchHistoryIdent]

	SELECT DISTINCT
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
		CAST(1 AS BIT) as [IsInNetwork], -- return as column so that all dataset structures match
		E.Registered
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
		tE.DisplayName ASC

	DROP TABLE #tmpEntityResults 
		
GO

/**************************

exec uspSearchEntityNetwork
			@bntEntityIdent = 306485,
			@bntASUserIdent = 306485,
			@nvrKeyword = '',
			@decLatitude = 0.0,
			@decLongitude = 0.0,
			@intDistanceInMiles = 25,
			@bntResultsShown = 10

**************************/

