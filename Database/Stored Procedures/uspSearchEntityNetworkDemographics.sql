
IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspSearchEntityNetworkDemographics') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspSearchEntityNetworkDemographics
GO

/* uspSearchEntityNetworkDemographics
 *
 * Advanced Search, in network, with optional filters and including the Demographics information
 *
 *
*/
CREATE PROCEDURE uspSearchEntityNetworkDemographics

	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT,
	@nvrKeyword NVARCHAR(MAX),
	@nvrLocation NVARCHAR(MAX),
	@decLatitude DECIMAL(20,8) = 0.0,
	@decLongitude DECIMAL(20,8) = 0.0,
	@intDistanceInMiles INT,
	@bntResultsShown BIGINT,
	@bitFullProjectExport BIT,
	@bntAddEntityProjectIdent BIGINT,
	@tblFilters [EntitySearchFilterTable] READONLY

AS



	DECLARE @nvrSQL NVARCHAR(MAX)
	DECLARE	@GETDATE SMALLDATETIME

	SET @GETDATE = GETDATE()


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

	ALTER TABLE #tmpEntityResults
	ADD AcceptingNewPatients BIT,
		SoleProvider BIT,
		Gender VARCHAR(MAX),
		GenderIdent BIGINT,
		PrimaryZip VARCHAR(MAX)


	UPDATE tE
	SET AcceptingNewPatients = E.AcceptingNewPatients,
		SoleProvider = E.SoleProvider,
		GenderIdent = E.GenderIdent,
		Gender = G.Name1,
		PrimaryZip = E.PrimaryZip
	FROM	
		#tmpEntityResults tE
		INNER JOIN
		Entity E (NOLOCK)
			ON tE.EntityIdent = E.Ident
		INNER JOIN
		Gender G (NOLOCK)
			ON G.Ident = E.GenderIdent


	CREATE TABLE #tmpTopSpecialties (
		Ident BIGINT,
		Name1 VARCHAR(MAX),
		ResultCount BIGINT
	)

	--Prep for TOP SPECIALTIES 
	INSERT INTO #tmpTopSpecialties (
		Ident ,
		Name1 ,
		ResultCount
	)
	SELECT TOP 10
		S.Ident,
		LTRIM(RTRIM(S.Name1)),
		COUNT(DISTINCT E.EntityIdent) AS [ResultCount]
	FROM
		#tmpEntityResults E WITH (NOLOCK)
		INNER JOIN
		EntitySpecialityXRef ESX WITH (NOLOCK)
			ON E.EntityIdent = ESX.EntityIdent
		INNER JOIN
		Speciality S WITH (NOLOCK)
			ON ESX.SpecialityIdent = S.Ident
		--INNER JOIN
		--Taxonomy T (NOLOCK) --Speciality is a view of Taxonomy, so join by Ident
		--	ON T.Ident = S.Ident
	WHERE 
		ESX.Active = 1
		AND S.Active = 1
	GROUP BY
		S.Ident,
		S.Name1
	ORDER BY 
		COUNT(ESX.Ident) DESC

	--Final TOP SPECIALTIES 
	SELECT 
		Ident,
		Name1,
		SUM(ResultCount) AS [ResultCount]
	FROM
		#tmpTopSpecialties WITH (NOLOCK)
	GROUP BY
		Ident,
		Name1
	ORDER BY 
		SUM(ResultCount) DESC


	--TOP SPECIALTIES VS SOLE Provider
	SELECT
		S.Name1,
		COALESCE(E.SoleProvider, 1) AS [AcceptingNewPatients],
		COALESCE(COUNT(DISTINCT E.EntityIdent), 0) AS [ResultCount],
		MAX(tTS.ResultCount) AS [TotalSpecialtyResultCount]
	FROM
		#tmpTopSpecialties tTS WITH (NOLOCK) --linking to this to limit to only SPECIALTIES in the top 10
		INNER JOIN
		EntitySpecialityXRef ESX WITH (NOLOCK)
			ON tTS.Ident = ESX.SpecialityIdent
		INNER JOIN
		Speciality S WITH (NOLOCK)
			ON ESX.SpecialityIdent = S.Ident
		LEFT OUTER JOIN
		#tmpEntityResults E WITH (NOLOCK)
			ON E.EntityIdent = ESX.EntityIdent
				AND E.SoleProvider = 1
	WHERE 
		ESX.Active = 1
	GROUP BY
		S.Name1,
		COALESCE(E.SoleProvider, 1)
	UNION ALL 
	SELECT
		S.Name1,
		COALESCE(E.SoleProvider, 0) AS [AcceptingNewPatients],
		COALESCE(COUNT(DISTINCT E.EntityIdent), 0) AS [ResultCount],
		MAX(tTS.ResultCount) AS [TotalSpecialtyResultCount]
	FROM
		#tmpTopSpecialties tTS WITH (NOLOCK) --linking to this to limit to only SPECIALTIES in the top 10
		INNER JOIN
		EntitySpecialityXRef ESX WITH (NOLOCK)
			ON tTS.Ident = ESX.SpecialityIdent
		INNER JOIN
		Speciality S WITH (NOLOCK)
			ON ESX.SpecialityIdent = S.Ident
		LEFT OUTER JOIN
		#tmpEntityResults E WITH (NOLOCK)
			ON E.EntityIdent = ESX.EntityIdent
				AND E.SoleProvider = 0
	WHERE 
		ESX.Active = 1
	GROUP BY
		S.Name1,
		COALESCE(E.SoleProvider, 0)
	ORDER BY 
		S.Name1


	--TOP SPECIALTIES - GENDER BREAKDOWN
	SELECT 
		G.Ident ,
		G.Name1,
		'SpecialtyIdent' = S.Ident,
		S.Name1 AS [Column1],
		(SELECT COUNT(DISTINCT E.EntityIdent) 
		FROM 
			#tmpEntityResults E WITH (NOLOCK) 
			INNER JOIN
			EntitySpecialityXRef ESX WITH (NOLOCK)
				ON E.EntityIdent = ESX.EntityIdent 
			INNER JOIN
			#tmpTopSpecialties tTS WITH (NOLOCK) --linking to this to limit to only SPECIALTIES in the top 10
				ON tTS.Ident = ESX.SpecialityIdent
			INNER JOIN
			Speciality innerS WITH (NOLOCK)
				ON ESX.SpecialityIdent = innerS.Ident		
		WHERE 
			E.GenderIdent = G.Ident
			AND S.Name1 = innerS.Name1
			AND ESX.Active = 1
			AND innerS.Active = 1
		) AS [ResultCount]
	FROM
	
		Gender G WITH (NOLOCK),
		#tmpTopSpecialties tTS WITH (NOLOCK) --linking to this to limit to only SPECIALTIES in the top 10
		LEFT OUTER JOIN
		EntitySpecialityXRef ESX WITH (NOLOCK)
			ON tTS.Ident = ESX.SpecialityIdent
		INNER JOIN
		Speciality S WITH (NOLOCK)
			ON ESX.SpecialityIdent = S.Ident		
	WHERE 
		ESX.Active = 1

	GROUP BY
		G.Ident ,
		G.Name1 ,
		S.Ident ,
		S.Name1
	ORDER BY 
		S.Name1
	--	COALESCE(COUNT(E.EntityIdent), 0)  DESC


	--MEANINGFUL USE TOTALS
	SELECT 
		MU.Ident,
		MU.Name1,
		COUNT(DISTINCT tE.EntityIdent) AS [ResultCount]
	FROM
		#tmpEntityResults tE WITH (NOLOCK)
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON tE.EntityIdent = E.Ident
		INNER JOIN
		MeaningfulUse MU WITH (NOLOCK)
			ON E.MeaningfulUseIdent = MU.Ident
	WHERE 
		MU.Active = 1
	GROUP BY
		MU.Ident,
		MU.Name1
	ORDER BY 
		COUNT(tE.EntityIdent) DESC
		

	--TOP PAYORS
	SELECT TOP 10
		P.Ident,
		P.Name1,
		COUNT(DISTINCT E.EntityIdent) AS [ResultCount]
	FROM
		#tmpEntityResults E WITH (NOLOCK)
		INNER JOIN
		EntityPayorXRef EPX WITH (NOLOCK)
			ON E.EntityIdent = EPX.EntityIdent
		INNER JOIN
		Payor P WITH (NOLOCK)
			ON EPX.PayorIdent = P.Ident
	WHERE 
		EPX.Active = 1
		AND P.Active = 1
	GROUP BY
		P.Ident,
		P.Name1

	--Prep GEOGRAPHY
	CREATE TABLE #tmpGeography(
		ZipCode VARCHAR (MAX),
		ResultCount BIGINT
	)

	INSERT INTO #tmpGeography(
		ZipCode,
		ResultCount 
	)
	SELECT TOP 10
		LEFT(E.PrimaryZip,5) AS [ZipCode],
		COUNT(DISTINCT E.EntityIdent) AS [ResultCount]
	FROM
		#tmpEntityResults E WITH (NOLOCK)
	WHERE 
		LEN(LEFT(LTRIM(RTRIM(E.PrimaryZip)),5)) = 5
	GROUP BY
		LEFT(E.PrimaryZip,5)
	ORDER BY 
		COUNT(E.EntityIdent) DESC
		
	--final GEOGRAPHY
	SELECT
		G.ZipCode,
		G.ResultCount,
		COALESCE((SELECT TOP 1 
			S.Name1 
		FROM 
			#tmpEntityResults E WITH (NOLOCK)
			INNER JOIN
			#tmpGeography innerG WITH (NOLOCK)
				ON LEFT(E.PrimaryZip, 5) = Left(innerG.ZipCode,5)
			INNER JOIN
			EntitySpecialityXRef ESX WITH (NOLOCK)
				ON E.EntityIdent = ESX.EntityIdent
			INNER JOIN
			Speciality S WITH (NOLOCK)
				ON ESX.SpecialityIdent = S.Ident
		WHERE 
			ESX.Active = 1
			AND LEFT(innerG.ZipCode,5) = G.ZipCode
		GROUP BY 
			S.Name1
		ORDER BY 
			COUNT(ESX.Ident) DESC
		), '') AS [Specialty]
		
	FROM
		#tmpGeography G WITH (NOLOCK)
	ORDER BY 
		G.ResultCount DESC
		



	--Prep GENDER
	CREATE TABLE #tmpGender(
		Gender VARCHAR (MAX),
		ResultCount BIGINT
	)

	INSERT INTO #tmpGender(
		Gender,
		ResultCount 
	)
	SELECT
		E.Gender AS [Gender],
		COUNT(DISTINCT E.EntityIdent) AS [ResultCount]
	FROM
		#tmpEntityResults E WITH (NOLOCK)
	GROUP BY
		E.Gender
	ORDER BY 
		COUNT(E.EntityIdent) DESC

	
	--final GENDER
	SELECT
		G.Gender,
		G.ResultCount,
		COALESCE((SELECT TOP 1 
			S.Ident 
		FROM 
			#tmpEntityResults E WITH (NOLOCK)
			INNER JOIN
			#tmpGender innerG WITH (NOLOCK)
				ON E.Gender = innerG.Gender
			INNER JOIN
			EntitySpecialityXRef ESX WITH (NOLOCK)
				ON E.EntityIdent = ESX.EntityIdent
			INNER JOIN
			Speciality S WITH (NOLOCK)
				ON ESX.SpecialityIdent = S.Ident
		WHERE 
			ESX.Active = 1
			AND innerG.Gender = G.Gender
		GROUP BY 
			S.Ident
		ORDER BY 
			COUNT(ESX.Ident) DESC
		), '') AS [SpecialtyIdent],
		COALESCE((SELECT TOP 1 
			S.Name1 
		FROM 
			#tmpEntityResults E WITH (NOLOCK)
			INNER JOIN
			#tmpGender innerG WITH (NOLOCK)
				ON E.Gender = innerG.Gender
			INNER JOIN
			EntitySpecialityXRef ESX WITH (NOLOCK)
				ON E.EntityIdent = ESX.EntityIdent
			INNER JOIN
			Speciality S WITH (NOLOCK)
				ON ESX.SpecialityIdent = S.Ident
		WHERE 
			ESX.Active = 1
			AND innerG.Gender = G.Gender
		GROUP BY 
			S.Name1
		ORDER BY 
			COUNT(ESX.Ident) DESC
		), '') AS [Specialty]
		
	FROM
		#tmpGender G WITH (NOLOCK)
	ORDER BY 
		G.ResultCount DESC
		
	--TOP SECONDARY LANGUAGE
	SELECT
		L.Ident,
		L.Name1,
		COUNT(DISTINCT E.EntityIdent) AS [ResultCount]
	FROM
		#tmpEntityResults E WITH (NOLOCK)
		INNER JOIN
		EntityLanguage1XRef ELX WITH (NOLOCK)
			ON E.EntityIdent = ELX.EntityIdent
		INNER JOIN
		Language1 L WITH (NOLOCK)
			ON ELX.Language1Ident = L.Ident
	WHERE 
		ELX.Active = 1
		AND L.Active = 1
	GROUP BY
		L.Ident,
		L.Name1
	ORDER BY 
		COUNT(ELX.Ident) DESC


	--SECONDARY LANGUAGE BY ZIP CODE
	SELECT
		G.ZipCode,
		COALESCE((SELECT TOP 1 
			L.Name1 
		FROM 
			#tmpEntityResults E WITH (NOLOCK)
			INNER JOIN
			#tmpGeography innerG WITH (NOLOCK)
				ON LEFT(E.PrimaryZip, 5) = Left(innerG.ZipCode,5)
			INNER JOIN
			EntityLanguage1XRef ELX WITH (NOLOCK)
				ON E.EntityIdent = ELX.EntityIdent
			INNER JOIN
			Language1 L WITH (NOLOCK)
				ON ELX.Language1Ident = L.Ident
		WHERE 
			ELX.Active = 1
			AND L.Active = 1
			AND LEFT(innerG.ZipCode,5) = G.ZipCode
		GROUP BY 
			L.Name1
		ORDER BY 
			COUNT(ELX.Ident) DESC
		), '') AS [Language],
		COALESCE((SELECT TOP 1 
			COUNT(DISTINCT E.EntityIdent)
		FROM 
			#tmpEntityResults E WITH (NOLOCK)
			INNER JOIN
			#tmpGeography innerG WITH (NOLOCK)
				ON LEFT(E.PrimaryZip, 5) = Left(innerG.ZipCode,5)
			INNER JOIN
			EntityLanguage1XRef ELX WITH (NOLOCK)
				ON E.EntityIdent = ELX.EntityIdent
			INNER JOIN
			Language1 L WITH (NOLOCK)
				ON ELX.Language1Ident = L.Ident
		WHERE 
			ELX.Active = 1
			AND L.Active = 1
			AND LEFT(innerG.ZipCode,5) = G.ZipCode
		GROUP BY 
			L.Name1
		ORDER BY 
			COUNT(ELX.Ident) DESC
		), '') AS [ResultCount]
		
	FROM
		#tmpGeography G WITH (NOLOCK)
	ORDER BY 
		G.ResultCount DESC
		

	--SELECT * 
	--FROM
	--	#tmpEntityResults (NOLOCK)
	
	
	DROP TABLE #tmpEntityResults
	--DROP TABLE ##tmpEntityResults2



GO

/******************************************
exec uspSearchEntityNetworkDemographics
			@bntEntityIdent = 306485,
			@bntASUserIdent = 306485,
			@nvrKeyword = '',
			@nvrLocation = '',
			@decLatitude = 0.0,
			@decLongitude = 0.0,
			@intDistanceInMiles = 25,
			@bntResultsShown = 10,
			@bitFullProjectExport = 0,
			@bntAddEntityProjectIdent = 0

*******************************************/
