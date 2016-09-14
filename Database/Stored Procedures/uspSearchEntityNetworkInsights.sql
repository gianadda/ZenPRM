IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspSearchEntityNetworkInsights') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspSearchEntityNetworkInsights
GO

/* uspSearchEntityNetworkInsights
 *
 * Advanced Search, in network, with optional filters and including the Insight information
 *
 *
*/
CREATE PROCEDURE uspSearchEntityNetworkInsights

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
	@bntXAxisEntityProjectRequirementIdent BIGINT,
	@bntYAxisEntityProjectRequirementIdent BIGINT,
	@bntZAxisEntityProjectRequirementIdent BIGINT,
	@bntAlphaAxisEntityProjectRequirementIdent  BIGINT,
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

	--X Axis
	DECLARE @intXAxisEntitySearchDataTypeIdent BIGINT = 0

	SELECT @intXAxisEntitySearchDataTypeIdent = RT.EntitySearchDataTypeIdent
	FROM	
		EntityProjectRequirement EPR (NOLOCK)
		INNER JOIN
		RequirementType RT (NOLOCK)
			ON RT.Ident = EPR.RequirementTypeIdent
	WHERE 
		EPR.Ident = @bntXAxisEntityProjectRequirementIdent

	DECLARE @intYAxisEntitySearchDataTypeIdent BIGINT = 0

	SELECT @intYAxisEntitySearchDataTypeIdent = RT.EntitySearchDataTypeIdent
	FROM	
		EntityProjectRequirement EPR (NOLOCK)
		INNER JOIN
		RequirementType RT (NOLOCK)
			ON RT.Ident = EPR.RequirementTypeIdent
	WHERE 
		EPR.Ident = @bntYAxisEntityProjectRequirementIdent


	DECLARE @intZAxisEntitySearchDataTypeIdent BIGINT = 0

	SELECT @intZAxisEntitySearchDataTypeIdent = RT.EntitySearchDataTypeIdent
	FROM	
		EntityProjectRequirement EPR (NOLOCK)
		INNER JOIN
		RequirementType RT (NOLOCK)
			ON RT.Ident = EPR.RequirementTypeIdent
	WHERE 
		EPR.Ident = @bntZAxisEntityProjectRequirementIdent

	DECLARE @intAlphaAxisEntitySearchDataTypeIdent BIGINT = 0

	SELECT @intAlphaAxisEntitySearchDataTypeIdent = RT.EntitySearchDataTypeIdent
	FROM	
		EntityProjectRequirement EPR (NOLOCK)
		INNER JOIN
		RequirementType RT (NOLOCK)
			ON RT.Ident = EPR.RequirementTypeIdent
	WHERE 
		EPR.Ident = @bntAlphaAxisEntityProjectRequirementIdent







	ALTER TABLE #tmpEntityResults
	ADD XName VARCHAR (MAX),
		XValue VARCHAR (MAX),
		YName VARCHAR (MAX),
		YValue VARCHAR (MAX),
		ZName VARCHAR (MAX),
		ZValue VARCHAR (MAX),
		AlphaName VARCHAR (MAX),
		AlphaValue VARCHAR (MAX)

	UPDATE E
	SET XValue = EPEAV.Value1,
		XName = ISDATE(EPEAV.Value1)
	FROM
		#tmpEntityResults E
		INNER JOIN
		EntityProjectEntity EPE (NOLOCK) 
			ON EPE.EntityIdent = E.EntityIdent 
		INNER JOIN
		EntityProjectEntityAnswer EPEA (NOLOCK)
			ON EPE.Ident = EPEA.EntityProjectEntityIdent
		INNER JOIN
		EntityProjectRequirement EPR (NOLOCK)
			ON EPEA.EntityProjectRequirementIdent = EPR.Ident
		INNER JOIN
		RequirementType RT (NOLOCK)
			ON RT.Ident = EPR.RequirementTypeIdent
		INNER JOIN
		EntityProjectEntityAnswerValue EPEAV (NOLOCK)
			ON EPEA.Ident = EPEAV.EntityProjectEntityAnswerIdent
	WHERE 
		EPE.Active = 1
		AND EPEA.EntityProjectRequirementIdent = @bntXAxisEntityProjectRequirementIdent
		AND EPR.Active = 1
		AND EPEA.Active = 1

		

	UPDATE E
	SET YValue = EPEAV.Value1,
		YName = EPEAV.Name1
	FROM
		#tmpEntityResults E
		INNER JOIN
		EntityProjectEntity EPE (NOLOCK) 
			ON EPE.EntityIdent = E.EntityIdent 
		INNER JOIN
		EntityProjectEntityAnswer EPEA (NOLOCK)
			ON EPE.Ident = EPEA.EntityProjectEntityIdent
		INNER JOIN
		EntityProjectRequirement EPR (NOLOCK)
			ON EPEA.EntityProjectRequirementIdent = EPR.Ident
		INNER JOIN
		RequirementType RT (NOLOCK)
			ON RT.Ident = EPR.RequirementTypeIdent
		INNER JOIN
		EntityProjectEntityAnswerValue EPEAV (NOLOCK)
			ON EPEA.Ident = EPEAV.EntityProjectEntityAnswerIdent
	WHERE 
		EPE.Active = 1
		AND EPEA.EntityProjectRequirementIdent = @bntYAxisEntityProjectRequirementIdent
		AND EPR.Active = 1
		AND EPEA.Active = 1



	UPDATE E
	SET ZValue = EPEAV.Value1,
		ZName = EPEAV.Name1
	FROM
		#tmpEntityResults E
		INNER JOIN
		EntityProjectEntity EPE (NOLOCK) 
			ON EPE.EntityIdent = E.EntityIdent 
		INNER JOIN
		EntityProjectEntityAnswer EPEA (NOLOCK)
			ON EPE.Ident = EPEA.EntityProjectEntityIdent
		INNER JOIN
		EntityProjectRequirement EPR (NOLOCK)
			ON EPEA.EntityProjectRequirementIdent = EPR.Ident
		INNER JOIN
		RequirementType RT (NOLOCK)
			ON RT.Ident = EPR.RequirementTypeIdent
		INNER JOIN
		EntityProjectEntityAnswerValue EPEAV (NOLOCK)
			ON EPEA.Ident = EPEAV.EntityProjectEntityAnswerIdent
	WHERE 
		EPE.Active = 1
		AND EPEA.EntityProjectRequirementIdent = @bntZAxisEntityProjectRequirementIdent
		AND EPR.Active = 1
		AND EPEA.Active = 1




	UPDATE E
	SET AlphaValue = EPEAV.Value1,
		AlphaName = EPEAV.Name1
	FROM
		#tmpEntityResults E
		INNER JOIN
		EntityProjectEntity EPE (NOLOCK) 
			ON EPE.EntityIdent = E.EntityIdent 
		INNER JOIN
		EntityProjectEntityAnswer EPEA (NOLOCK)
			ON EPE.Ident = EPEA.EntityProjectEntityIdent
		INNER JOIN
		EntityProjectRequirement EPR (NOLOCK)
			ON EPEA.EntityProjectRequirementIdent = EPR.Ident
		INNER JOIN
		RequirementType RT (NOLOCK)
			ON RT.Ident = EPR.RequirementTypeIdent
		INNER JOIN
		EntityProjectEntityAnswerValue EPEAV (NOLOCK)
			ON EPEA.Ident = EPEAV.EntityProjectEntityAnswerIdent
	WHERE 
		EPE.Active = 1
		AND EPEA.EntityProjectRequirementIdent = @bntAlphaAxisEntityProjectRequirementIdent
		AND EPR.Active = 1
		AND EPEA.Active = 1



	SELECT 
		E.*,
		'x' = CASE @intXAxisEntitySearchDataTypeIdent
				WHEN 5 THEN COALESCE(CONVERT(VARCHAR(10),CONVERT(BIT, XValue)), '0')
				WHEN 4 THEN COALESCE(XValue, 'n/a')
				WHEN 3 THEN COALESCE(XValue, '0')
				WHEN 1 THEN COALESCE(XValue, '0')
				ELSE '0'
				END ,
		'y' = CASE @intYAxisEntitySearchDataTypeIdent
				WHEN 5 THEN COALESCE(CONVERT(VARCHAR(10),CONVERT(BIT, YValue)), '0')
				WHEN 4 THEN COALESCE(YValue, 'n/a')
				WHEN 3 THEN COALESCE(YValue, '0')
				WHEN 1 THEN COALESCE(YValue, '0')
				ELSE '0'
				END ,
		'size' = CASE @intZAxisEntitySearchDataTypeIdent
				WHEN 5 THEN COALESCE(CONVERT(VARCHAR(10),CONVERT(BIT, ZValue)), '0')
				WHEN 1 THEN COALESCE(ZValue, '0')
				ELSE '0'
				END ,
		'Alpha' = CASE @intAlphaAxisEntitySearchDataTypeIdent
				WHEN 5 THEN COALESCE(CONVERT(VARCHAR(10),CONVERT(BIT, AlphaValue)), '0')
				WHEN 4 THEN COALESCE(AlphaValue, 'n/a')
				WHEN 3 THEN COALESCE(AlphaValue, '0')
     			WHEN 1 THEN COALESCE(AlphaValue, '0')
				ELSE '0'
				END 
	FROM #tmpEntityResults E (NOLOCK)
	--WHERE 
	--	(NOT XValue is NULL OR @bntXAxisEntityProjectRequirementIdent = 0)
	--	AND (NOT YValue is NULL OR @bntYAxisEntityProjectRequirementIdent = 0)
	--	AND (NOT ZValue is NULL OR @bntZAxisEntityProjectRequirementIdent = 0)
	--	AND (NOT AlphaValue is NULL OR @bntAlphaAxisEntityProjectRequirementIdent = 0)
	

	DROP TABLE #tmpEntityResults

	-- DROP TABLE ##tmpEntityResults306485


GO

/**************************10066
exec uspSearchEntityNetworkInsights
			@bntEntityIdent = 2,
			@bntASUserIdent = 2,
			@nvrKeyword = '',
			@decLatitude = 0.0,
			@decLongitude = 0.0,
			@intDistanceInMiles = 25,
			@bntResultsShown = 10,
			@bitFullProjectExport = 0,
			@bntAddEntityProjectIdent = 0,
			@bntXAxisEntityProjectRequirementIdent = 515 ,
			@bntYAxisEntityProjectRequirementIdent = 516,
			@bntZAxisEntityProjectRequirementIdent = 0,
			@bntAlphaAxisEntityProjectRequirementIdent  = 513




	
DECLARE @bntEntityIdent BIGINT = 306485 --aHealthTech
DECLARE @bntXAxisEntityProjectRequirementIdent BIGINT = 619 --Programming Survey - How Many Doctors?
DECLARE @bntYAxisEntityProjectRequirementIdent BIGINT = 620 --Programming Survey - How Many Nurses?
DECLARE @bntZAxisEntityProjectRequirementIdent BIGINT = 621	--Programming Survey - Average Number of Days Until Next Visit?
DECLARE @bntAlphaAxisEntityProjectRequirementIdent BIGINT = 622	--Programming Survey - What is your PCMH Status Level?

**************************/
