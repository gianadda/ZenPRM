IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspSearchEntityNetworkNetwork') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspSearchEntityNetworkNetwork
GO

/* uspSearchEntityNetworkNetwork
 *
 * Advanced Search, in network, with optional filters and including the Network Connections information
 *
 *
*/
CREATE PROCEDURE uspSearchEntityNetworkNetwork

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


--Time tracking
DECLARE @StartTime datetime
DECLARE @EndTime datetime
SELECT @StartTime=GETDATE() 


	DECLARE @intMainEntityNodeValue INT
	DECLARE @intFirstTierSearchResultsNodeValue INT
	DECLARE @intFirstTierConnectionNodeValue INT
	DECLARE @intSecondGeneralTierNodeValue INT
	DECLARE @intThirdTierNodeValue INT

	SET @intMainEntityNodeValue = 6
	SET @intFirstTierSearchResultsNodeValue = 4
	SET @intFirstTierConnectionNodeValue = 3
	SET @intSecondGeneralTierNodeValue = 2
	SET @intThirdTierNodeValue = 1
	
	
	DECLARE @intCommunityEdgeValue INT
	DECLARE @intNetworkEdgeValue INT
	DECLARE @bntResultCount BIGINT
	
	SET @intCommunityEdgeValue = 5
	SET @intNetworkEdgeValue = 7
	
	SET @bntResultCount = 0

	
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
	ADD EntityTypeIdent BIGINT


	UPDATE tE
	SET EntityTypeIdent = E.EntityTypeIdent
	FROM	
		#tmpEntityResults tE
		INNER JOIN
		Entity E (NOLOCK)
			ON tE.EntityIdent = E.Ident



	
	CREATE TABLE #tmpNodes (
		Ident BIGINT Identity (1,1) NOT NULL,
		EntityIdent BIGINT,
		DisplayName NVARCHAR(MAX), -- tooltip
		GroupIdent BIGINT,
		GroupName NVARCHAR(MAX), -- this will make the bubble color
		NodeValue INT, --This will make the size of the bubble
		IsInNetwork BIT,
		IncludeInCNP BIT
	)
	
		
	CREATE TABLE #tmpEdges (
		Ident BIGINT Identity (1,1) NOT NULL,
		SourceEntityIdent BIGINT,
		TargetEntityIdent BIGINT,
		DisplayName NVARCHAR(MAX), --tooltip
		EdgeValue NVARCHAR(MAX), --Length
		EdgeType NVARCHAR(MAX) --color/stroke
	)

	
	--Start by Entering the Entity itself
	INSERT INTO #tmpNodes (
		EntityIdent ,
		DisplayName,
		GroupIdent ,
		GroupName ,
		NodeValue ,
		IsInNetwork ,
		IncludeInCNP
	)
	SELECT
		EntityIdent = E.Ident, 
		DisplayName = E.FullName,
		GroupIdent = ET.Ident,
		GroupName = ET.Name1,
		NodeValue = @intMainEntityNodeValue,
		IsInNetwork = 1,
		IncludeInCNP = 1
	FROM
		Entity E WITH (NOLOCK)
		INNER JOIN
		EntityType ET WITH (NOLOCK)
			ON E.EntityTypeIdent = ET.Ident
	WHERE 
		E.Ident = @bntEntityIdent


	--Now Put in all of the search results, ignore IncludeInCNP, because the search will take care of that.
	INSERT INTO #tmpNodes (
		EntityIdent ,
		DisplayName,
		GroupIdent ,
		GroupName ,
		NodeValue,
		IsInNetwork ,
		IncludeInCNP
	)
	SELECT
		EntityIdent = E.EntityIdent, 
		DisplayName = E.DisplayName,
		GroupIdent = ET.Ident,
		GroupName = ET.Name1,
		NodeValue = @intFirstTierSearchResultsNodeValue,
		IsInNetwork = 1 ,
		IncludeInCNP = ET.IncludeInCNP
	FROM
		#tmpEntityResults E WITH (NOLOCK)
		INNER JOIN
		Entity Ent WITH (NOLOCK)
			ON Ent.Ident = E.EntityIdent
		INNER JOIN
		EntityType ET WITH (NOLOCK)
			ON Ent.EntityTypeIdent = ET.Ident


	SELECT 
		@bntResultCount = COUNT(EntityIdent)
	FROM 
		#tmpNodes WITH (NOLOCK)


	--First Round of connections
	MERGE #tmpNodes AS TARGET
	USING (
		SELECT DISTINCT
			EntityIdent = E.Ident, 
			DisplayName = E.FullName,
			GroupIdent = ET.Ident,
			GroupName = ET.Name1,
			NodeValue = @intFirstTierConnectionNodeValue,
			IncludeInCNP = ET.IncludeInCNP
		FROM
			#tmpNodes tN WITH (NOLOCK)
			INNER JOIN
			EntityCommunity EC WITH (NOLOCK)
				ON EC.FromEntityIdent = tN.EntityIdent
			INNER JOIN
			Entity E WITH (NOLOCK)
				ON EC.ToEntityIdent = E.Ident
			INNER JOIN
			EntityType ET WITH (NOLOCK)
				ON E.EntityTypeIdent = ET.Ident
		WHERE 
			tN.EntityIdent <> @bntEntityIdent
			AND E.Ident <> @bntEntityIdent
			AND E.Active = 1
			AND EC.Active = 1
			--AND @bntResultCount < 1000
	) AS SOURCE 

	ON (TARGET.EntityIdent = SOURCE.EntityIdent) 
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (
			EntityIdent ,
			DisplayName,
			GroupIdent ,
			GroupName ,
			NodeValue,
			IncludeInCNP
		)
	VALUES (SOURCE.EntityIdent, SOURCE.DisplayName, SOURCE.GroupIdent, SOURCE.GroupName, SOURCE.NodeValue, SOURCE.IncludeInCNP);

	
	SELECT 
		@bntResultCount = COUNT(EntityIdent)
	FROM 
		#tmpNodes WITH (NOLOCK)

	--Second Round of connections
	MERGE #tmpNodes AS TARGET
	USING (
		SELECT DISTINCT
			EntityIdent = E.Ident, 
			DisplayName = E.FullName,
			GroupIdent = ET.Ident,
			GroupName = ET.Name1,
			NodeValue = @intSecondGeneralTierNodeValue,
			IncludeInCNP = ET.IncludeInCNP
		FROM
			#tmpNodes tN WITH (NOLOCK)
			INNER JOIN
			EntityCommunity EC WITH (NOLOCK)
				ON EC.FromEntityIdent = tN.EntityIdent
			INNER JOIN
			Entity E WITH (NOLOCK)
				ON EC.ToEntityIdent = E.Ident
			INNER JOIN
			EntityType ET WITH (NOLOCK)
				ON E.EntityTypeIdent = ET.Ident
		WHERE 
			tN.EntityIdent <> @bntEntityIdent
			AND E.Ident <> @bntEntityIdent
			AND E.Active = 1
			AND EC.Active = 1
			--AND @bntResultCount < 1000
	) AS SOURCE 

	ON (TARGET.EntityIdent = SOURCE.EntityIdent) 
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (
			EntityIdent ,
			DisplayName,
			GroupIdent ,
			GroupName ,
			NodeValue,
			IncludeInCNP
		)
	VALUES (SOURCE.EntityIdent, SOURCE.DisplayName, SOURCE.GroupIdent, SOURCE.GroupName, SOURCE.NodeValue, SOURCE.IncludeInCNP);

	
	SELECT 
		@bntResultCount = COUNT(EntityIdent)
	FROM 
		#tmpNodes WITH (NOLOCK)

	--Third Round of connections
	MERGE #tmpNodes AS TARGET
	USING (
		SELECT DISTINCT
			EntityIdent = E.Ident, 
			DisplayName = E.FullName,
			GroupIdent = ET.Ident,
			GroupName = ET.Name1,
			NodeValue = @intThirdTierNodeValue,
			IncludeInCNP = ET.IncludeInCNP
		FROM
			#tmpNodes tN WITH (NOLOCK)
			INNER JOIN
			EntityCommunity EC WITH (NOLOCK)
				ON EC.FromEntityIdent = tN.EntityIdent
			INNER JOIN
			Entity E WITH (NOLOCK)
				ON EC.ToEntityIdent = E.Ident
			INNER JOIN
			EntityType ET WITH (NOLOCK)
				ON E.EntityTypeIdent = ET.Ident
		WHERE 
			tN.EntityIdent <> @bntEntityIdent
			AND E.Ident <> @bntEntityIdent
			AND E.Active = 1
			AND EC.Active = 1
			--AND @bntResultCount < 1000
	) AS SOURCE 

	ON (TARGET.EntityIdent = SOURCE.EntityIdent) 
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (
			EntityIdent ,
			DisplayName,
			GroupIdent ,
			GroupName ,
			NodeValue,
			IncludeInCNP
		)
	VALUES (SOURCE.EntityIdent, SOURCE.DisplayName, SOURCE.GroupIdent, SOURCE.GroupName, SOURCE.NodeValue, SOURCE.IncludeInCNP);

	
	

	UPDATE #tmpNodes
	SET IsInNetwork = 0
	
	UPDATE N
	SET 
		IsInNetwork = 1,
		IncludeInCNP = 1 --Override the IncludeInCNP is the person is in our network
	FROM
		EntityNetwork EN WITH (NOLOCK)
		INNER JOIN
		#tmpNodes N WITH (NOLOCK)
			ON EN.ToEntityIdent = N.EntityIdent
	WHERE 
		EN.FromEntityIdent = @bntEntityIdent
		AND EN.Active = 1

	


	INSERT INTO #tmpEdges (
		SourceEntityIdent ,
		TargetEntityIdent ,
		DisplayName ,
		EdgeValue , 
		EdgeType  
	)	
	SELECT 
		SourceEntityIdent = N.EntityIdent,
		TargetEntityIdent = E.Ident,
		DisplayName = N.DisplayName + ' ' + EC.Name + ' ' + E.FullName,
		EdgeValue = ((N.NodeValue + N2.NodeValue) * @intCommunityEdgeValue),
		EdgeType = CT.Ident
	FROM	
		#tmpNodes N WITH (NOLOCK)
		INNER JOIN
		EntityCommunity EC WITH (NOLOCK)
			ON EC.FromEntityIdent = N.EntityIdent
		INNER JOIN
		#tmpNodes N2 WITH (NOLOCK) --Make sure he edge should come back by having both sides in the list
			ON EC.ToEntityIdent = N2.EntityIdent
		INNER JOIN
		ConnectionType CT WITH (NOLOCK)
			ON CT.Ident = EC.ConnectionTypeIdent
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON EC.ToEntityIdent = E.Ident
	WHERE 
		E.Active = 1
		AND CT.Active = 1
		AND EC.Active = 1
		AND N.IncludeInCNP = 1
		AND N2.IncludeInCNP = 1
		
	----Setup all of the Network Edges
	--INSERT INTO #tmpEdges (
	--	SourceEntityIdent ,
	--	TargetEntityIdent ,
	--	DisplayName ,
	--	EdgeValue , 
	--	EdgeType  
	--)	
	--SELECT 
	--	SourceEntityIdent = N.EntityIdent,
	--	TargetEntityIdent = E.Ident,
	--	DisplayName = N.DisplayName + ' ' + EN.Name + ' ' + E.FullName,
	--	EdgeValue = ((N.NodeValue + N2.NodeValue) * @intNetworkEdgeValue),
	--	EdgeType = CT.Ident
	--FROM	
	--	#tmpNodes N WITH (NOLOCK)
	--	INNER JOIN
	--	EntityNetwork EN WITH (NOLOCK)
	--		ON EN.FromEntityIdent = N.EntityIdent
	--	INNER JOIN
	--	#tmpNodes N2 WITH (NOLOCK) --Make sure he edge should come back by having both sides in the list
	--		ON EN.ToEntityIdent = N2.EntityIdent
	--	INNER JOIN
	--	ConnectionType CT WITH (NOLOCK)
	--		ON CT.Ident = EN.ConnectionTypeIdent
	--	INNER JOIN
	--	Entity E WITH (NOLOCK)
	--		ON EN.ToEntityIdent = E.Ident
	--WHERE 
	--	E.Active = 1
	--	AND EN.FromEntityIdent = @bntEntityIdent -- Only My network, not other customers networks
	--	AND CT.Active = 1
	--	AND EN.Active = 1
	--	AND N.IncludeInCNP = 1
	--	AND N2.IncludeInCNP = 1



	SELECT DISTINCT
		(N.Ident - 1) as [index],
		N.EntityIdent as [NodeIdent],
		CASE @bntEntityIdent WHEN N.EntityIdent THEN 1 ELSE 0 END as [CurrentCenterNode],
		N.DisplayName as [name],
		MAX(N.NodeValue) as [groupid],
		CASE MAX(N.NodeValue) 
							WHEN @intMainEntityNodeValue THEN N.DisplayName
							WHEN @intFirstTierSearchResultsNodeValue THEN 'Matching Search Result'
							WHEN @intFirstTierConnectionNodeValue THEN 'Direct link to a Search Result'
							WHEN @intSecondGeneralTierNodeValue THEN '2 hops away from a Search Result'
							WHEN @intThirdTierNodeValue THEN '3 hops away from a Search Result'
							ELSE 'Unknown'
						END as [group],
		MAX(N.NodeValue) as [value],
		CASE MAX(N.NodeValue) 
							WHEN @intMainEntityNodeValue THEN N.DisplayName
							WHEN @intFirstTierSearchResultsNodeValue THEN 'Matching Search Result'
							WHEN @intFirstTierConnectionNodeValue THEN 'Direct link to a Search Result'
							WHEN @intSecondGeneralTierNodeValue THEN '2 hops away from a Search Result'
							WHEN @intThirdTierNodeValue THEN '3 hops away from a Search Result'
							ELSE 'Unknown'
						END as [valueDesc1],
		E.ProfilePhoto,
		IsInNetwork
	FROM
		#tmpNodes N WITH (NOLOCK)
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = N.EntityIdent
	WHERE 
		IncludeInCNP = 1
	GROUP BY
		N.Ident,
		N.EntityIdent,
		CASE @bntEntityIdent WHEN N.EntityIdent THEN 1 ELSE 0 END,
		N.DisplayName,
		E.FullName,
		E.ProfilePhoto,
		N.GroupIdent,
		N.GroupName,
		IsInNetwork










	 --this will return it with an index!
	--Edges
	SELECT DISTINCT
		tE.SourceEntityIdent as [source],
		tE.TargetEntityIdent as [target],
		(NSource.Ident - 1) as [sourceIndex],
		(NTarget.Ident - 1) as [targetIndex],
		tE.DisplayName as [name],
		CONVERT(BIGINT,tE.EdgeValue) as [value],
		tE.EdgeType as [type],
		CONVERT(BIGINT,tE.EdgeValue) as[weight]
	FROM
		#tmpEdges tE WITH (NOLOCK)
		INNER JOIN
		#tmpNodes NSource WITH (NOLOCK)
			on tE.SourceEntityIdent = NSource.EntityIdent
		INNER JOIN
		#tmpNodes NTarget WITH (NOLOCK)
			on tE.TargetEntityIdent = NTarget.EntityIdent


		
	DROP TABLE #tmpNodes
	DROP TABLE #tmpEdges
	DROP TABLE #tmpEntityResults

	
SELECT @EndTime=GETDATE()

--This will return execution time of your query
PRINT 'Duration ' + convert(varchar,DATEDIFF(MS,@StartTime,@EndTime) ) + ' MS'

GO

/**************************

exec uspSearchEntityNetworkNetwork
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

	--475956

--Before we started: 35 seconds, 27677 rows

**************************/
