IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetCommunityNetworkMapByEntityIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetCommunityNetworkMapByEntityIdent
GO

/* uspGetCommunityNetworkMapByEntityIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetCommunityNetworkMapByEntityIdent]

	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT,
	@bitIncludeNetwork BIT = 0

AS

	SET NOCOUNT ON
		

	DECLARE @intMainEntityNodeValue INT
	DECLARE @intFirstTierNetworkNodeValue INT
	DECLARE @intFirstTierCommunityNodeValue INT
	DECLARE @intSecondGeneralTierNodeValue INT
	DECLARE @intThirdTierNodeValue INT

	SET @intMainEntityNodeValue = 6
	SET @intFirstTierNetworkNodeValue = 3
	SET @intFirstTierCommunityNodeValue = 3
	SET @intSecondGeneralTierNodeValue = 2
	SET @intThirdTierNodeValue = 1

	
	DECLARE @intCommunityEdgeValue INT
	DECLARE @intNetworkEdgeValue INT
	DECLARE @bntResultCount BIGINT
	
	SET @intCommunityEdgeValue = 1
	SET @intNetworkEdgeValue = 3
	SET @bntResultCount = 0

	CREATE TABLE #tmpNodes (
		Ident BIGINT Identity (1,1) NOT NULL,
		EntityIdent BIGINT,
		DisplayName NVARCHAR(MAX), -- tooltip
		GroupIdent BIGINT,
		GroupName NVARCHAR(MAX), -- this will make the bubble color
		NodeValue INT, --This will make the size of the bubble
		EntityTypeIncludeInCNP BIT,
		ShowOnCNP BIT
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
		NodeValue,
		EntityTypeIncludeInCNP,
		ShowOnCNP
	)
	SELECT
		EntityIdent = E.Ident, 
		DisplayName = E.FullName,
		GroupIdent = ET.Ident,
		GroupName = ET.Name1,
		NodeValue = @intMainEntityNodeValue,
		EntityTypeIncludeInCNP = ET.IncludeInCNP,
		ShowOnCNP = 1 -- default to true, its the entity we are looking at
	FROM
		Entity E WITH (NOLOCK)
		INNER JOIN
		EntityType ET WITH (NOLOCK)
			ON E.EntityTypeIdent = ET.Ident
	WHERE 
		E.Ident = @bntEntityIdent


	--Puit in the Network
	INSERT INTO #tmpNodes (
		EntityIdent ,
		DisplayName,
		GroupIdent ,
		GroupName ,
		NodeValue,
		EntityTypeIncludeInCNP,
		ShowOnCNP
	)
	SELECT 
		EntityIdent = E.Ident, 
		DisplayName = E.FullName,
		GroupIdent = ET.Ident,
		GroupName = ET.Name1,
		NodeValue = @intFirstTierNetworkNodeValue,
		EntityTypeIncludeInCNP = ET.IncludeInCNP,
		ShowOnCNP = ET.IncludeInCNP -- default to IncludeInCNP, if include in CNP is false, well only flip this if they are in the users network
	FROM
		EntityNetwork EN WITH (NOLOCK)
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON EN.ToEntityIdent = E.Ident
		INNER JOIN
		EntityType ET WITH (NOLOCK)
			ON E.EntityTypeIdent = ET.Ident
	WHERE 
		EN.FromEntityIdent = @bntEntityIdent		
		AND @bitIncludeNetwork = 1		
		AND E.Active = 1
		AND EN.Active = 1


	SELECT 
		@bntResultCount = COUNT(EntityIdent)
	FROM 
		#tmpNodes WITH (NOLOCK)
	
	--Bring in the entire first tier of connections from the community
	MERGE #tmpNodes AS TARGET
	USING (
		SELECT 
			EntityIdent = E.Ident, 
			DisplayName = E.FullName,
			GroupIdent = ET.Ident,
			GroupName = ET.Name1,
			NodeValue = @intFirstTierCommunityNodeValue,
			EntityTypeIncludeInCNP = ET.IncludeInCNP,
			ShowOnCNP = ET.IncludeInCNP -- default to IncludeInCNP, if include in CNP is false, well only flip this if they are in the users network
		FROM
			Entity E WITH (NOLOCK)
			INNER JOIN
			EntityType ET WITH (NOLOCK)
				ON E.EntityTypeIdent = ET.Ident
			INNER JOIN
			EntityCommunity EC WITH (NOLOCK)
				ON EC.ToEntityIdent = E.Ident
			INNER JOIN
			#tmpNodes N WITH (NOLOCK)
				ON EC.FromEntityIdent = N.EntityIdent 
		WHERE 	
			E.Active = 1 
			AND EC.Active = 1 
			AND @bntResultCount < 1000
	) AS SOURCE 

	ON (TARGET.EntityIdent = SOURCE.EntityIdent) 
	WHEN NOT MATCHED BY TARGET THEN 
	INSERT (
			EntityIdent ,
			DisplayName,
			GroupIdent ,
			GroupName ,
			NodeValue,
			EntityTypeIncludeInCNP,
			ShowOnCNP
		)
	VALUES (SOURCE.EntityIdent, SOURCE.DisplayName, SOURCE.GroupIdent, SOURCE.GroupName, SOURCE.NodeValue, SOURCE.EntityTypeIncludeInCNP, SOURCE.ShowOnCNP);
	

	SELECT 
		@bntResultCount = COUNT(EntityIdent)
	FROM 
		#tmpNodes WITH (NOLOCK)


	--Bring in the entire third tier of connections from the community and network
	MERGE #tmpNodes AS TARGET
	USING (
		SELECT 
			EntityIdent = E.Ident, 
			DisplayName = E.FullName,
			GroupIdent = ET.Ident,
			GroupName = ET.Name1,
			NodeValue = @intThirdTierNodeValue,
			EntityTypeIncludeInCNP = ET.IncludeInCNP,
			ShowOnCNP = ET.IncludeInCNP -- default to IncludeInCNP, if include in CNP is false, well only flip this if they are in the users network
		FROM
			#tmpNodes N WITH (NOLOCK)
			INNER JOIN
			EntityCommunity EC WITH (NOLOCK)
				ON EC.FromEntityIdent = N.EntityIdent
			INNER JOIN
			Entity E WITH (NOLOCK)
				ON EC.ToEntityIdent = E.Ident
			INNER JOIN
			EntityType ET WITH (NOLOCK)
				ON E.EntityTypeIdent = ET.Ident
		WHERE	
			@bitIncludeNetwork = 1	
			AND E.Active = 1
			AND EC.Active = 1
			AND @bntResultCount < 1000
	) AS SOURCE 

	ON (TARGET.EntityIdent = SOURCE.EntityIdent) 
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (
			EntityIdent ,
			DisplayName,
			GroupIdent ,
			GroupName ,
			NodeValue,
			EntityTypeIncludeInCNP,
			ShowOnCNP
		)
	VALUES (SOURCE.EntityIdent, SOURCE.DisplayName, SOURCE.GroupIdent, SOURCE.GroupName, SOURCE.NodeValue, SOURCE.EntityTypeIncludeInCNP, SOURCE.ShowOnCNP);

	-- if the entity is marked as private,
	-- only show on the map if they are in the network of the searching user
	UPDATE
		tN
	SET
		ShowOnCNP = 1
	FROM
		#tmpNodes tN WITH (NOLOCK)
		INNER JOIN
		EntityNetwork EN WITH (NOLOCK)
			ON EN.FromEntityIdent = @bntASUserIdent
			AND EN.ToEntityIdent = tN.EntityIdent
	WHERE
		tN.ShowOnCNP = 0


	--AHHH Don't bring back too much data
	--DELETE #tmpNodes WHERE Ident > 200


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
		AND N.ShowOnCNP = 1 -- were only going to show these nodes, so dont get the edges for entities we wont display
		AND N2.ShowOnCNP = 1 -- were only going to show these nodes, so dont get the edges for entities we wont display
		
	--Setup all of the Network Edges
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
		DisplayName = N.DisplayName + ' ' + EN.Name + ' ' + E.FullName,
		EdgeValue = ((N.NodeValue + N2.NodeValue) * @intNetworkEdgeValue),
		EdgeType = CT.Ident
	FROM	
		#tmpNodes N WITH (NOLOCK)
		INNER JOIN
		EntityNetwork EN WITH (NOLOCK)
			ON EN.FromEntityIdent = N.EntityIdent
		INNER JOIN
		#tmpNodes N2 WITH (NOLOCK) --Make sure he edge should come back by having both sides in the list
			ON EN.ToEntityIdent = N2.EntityIdent
		INNER JOIN
		ConnectionType CT WITH (NOLOCK)
			ON CT.Ident = EN.ConnectionTypeIdent
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON EN.ToEntityIdent = E.Ident
	WHERE 
		E.Active = 1
		AND @bitIncludeNetwork = 1	
		AND CT.Active = 1
		AND EN.Active = 1
		AND N.ShowOnCNP = 1 -- were only going to show these nodes, so dont get the edges for entities we wont display
		AND N2.ShowOnCNP = 1 -- were only going to show these nodes, so dont get the edges for entities we wont display
		
	--Remove any edges that "go off map"
	--DELETE tE
	--FROM
	--	#tmpEdges tE
	--	LEFT OUTER JOIN
	--	#tmpNodes N WITH (NOLOCK) --Make sure he edge should come back by having both sides in the list
	--		ON tE.TargetEntityIdent = N.EntityIdent
	--WHERE 
	--	tE.TargetEntityIdent is NULL


	--Nodes
	SELECT DISTINCT
		N.EntityIdent as [NodeIdent],
		CASE @bntEntityIdent WHEN N.EntityIdent THEN 1 ELSE 0 END as [CurrentCenterNode],
		N.DisplayName as [name],
		N.GroupIdent as [groupid],
		N.GroupName as [group],
		MAX(N.NodeValue) as [value],
		CASE MAX(N.NodeValue) 
							WHEN @intMainEntityNodeValue THEN 'Main Node'
							WHEN @intFirstTierNetworkNodeValue THEN 'First Tier Network Node'
							WHEN @intFirstTierCommunityNodeValue THEN 'First Tier Community Node'
							WHEN @intSecondGeneralTierNodeValue THEN 'Second Tier Node'
							WHEN @intThirdTierNodeValue THEN 'Third Tier Node'
							ELSE 'Unknown'
						END as [valueDesc1],
		E.ProfilePhoto
	FROM
		#tmpNodes N WITH (NOLOCK)
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = N.EntityIdent
	WHERE
		N.ShowOnCNP = 1
	GROUP BY
		N.EntityIdent,
		CASE @bntEntityIdent WHEN N.EntityIdent THEN 1 ELSE 0 END,
		N.DisplayName,
		N.GroupIdent,
		N.GroupName,
		E.ProfilePhoto


	--Edges
	SELECT DISTINCT
		tE.SourceEntityIdent as [source],
		tE.TargetEntityIdent as [target],
		tE.DisplayName as [name],
		tE.EdgeValue as [value],
		tE.EdgeType as [type]
	FROM
		#tmpEdges tE WITH (NOLOCK)
		
/*
Second set of data for sample I'm working on
*/
	--SELECT DISTINCT
	--	(N.Ident - 1) as [name],
	--	N.EntityIdent as [NodeIdent],
	--	CASE @bntEntityIdent WHEN N.EntityIdent THEN 1 ELSE 0 END as [CurrentCenterNode],
	--	N.DisplayName as [name],
	--	CASE UPPER(SUBSTRING(E.FullName,1,1))
	--					WHEN 'A' THEN 1
	--					WHEN 'B' THEN 1
	--					WHEN 'C' THEN 1
	--					WHEN 'D' THEN 1
	--					WHEN 'E' THEN 1
	--					WHEN 'F' THEN 1
	--					WHEN 'G' THEN 2
	--					WHEN 'H' THEN 2
	--					WHEN 'I' THEN 2
	--					WHEN 'J' THEN 2
	--					WHEN 'K' THEN 2
	--					WHEN 'L' THEN 2
	--					WHEN 'M' THEN 3
	--					WHEN 'N' THEN 3
	--					WHEN 'O' THEN 3
	--					WHEN 'P' THEN 3
	--					WHEN 'Q' THEN 3
	--					WHEN 'R' THEN 3
	--					WHEN 'S' THEN 4
	--					WHEN 'T' THEN 4
	--					WHEN 'U' THEN 4
	--					WHEN 'V' THEN 4
	--					WHEN 'W' THEN 5
	--					WHEN 'X' THEN 5
	--					WHEN 'Y' THEN 5
	--					WHEN 'Z' THEN 5
	--					END as [group],
	--	--N.GroupName as [group],
	--	MAX(N.NodeValue) as [value],
	--	CASE MAX(N.NodeValue) 
	--						WHEN @intMainEntityNodeValue THEN 'Main Node'
	--						WHEN @intFirstTierNetworkNodeValue THEN 'First Tier Network Node'
	--						WHEN @intFirstTierCommunityNodeValue THEN 'First Tier Community Node'
	--						WHEN @intSecondGeneralTierNodeValue THEN 'Second Tier Node'
	--						WHEN @intThirdTierNodeValue THEN 'Third Tier Node'
	--						ELSE 'Unknown'
	--					END as [valueDesc1],
	--	E.ProfilePhoto
	--FROM
	--	#tmpNodes N WITH (NOLOCK)
	--	INNER JOIN
	--	Entity E WITH (NOLOCK)
	--		ON E.Ident = N.EntityIdent
	--WHERE
	--	N.ShowOnCNP = 1
	--GROUP BY
	--	N.Ident,
	--	N.EntityIdent,
	--	CASE @bntEntityIdent WHEN N.EntityIdent THEN 1 ELSE 0 END,
	--	N.DisplayName,
	--	E.FullName,
	--	E.ProfilePhoto


	--Edges
	--SELECT DISTINCT
	--	(NSource.Ident - 1) as [source],
	--	(NTarget.Ident - 1) as [target],
	--	tE.DisplayName as [name],
	--	tE.EdgeValue as [value],
	--	tE.EdgeType as [type]
	--FROM
	--	#tmpEdges tE WITH (NOLOCK)
	--	INNER JOIN
	--	#tmpNodes NSource WITH (NOLOCK)
	--		on tE.SourceEntityIdent = NSource.EntityIdent
	--	INNER JOIN
	--	#tmpNodes NTarget WITH (NOLOCK)
	--		on tE.TargetEntityIdent = NTarget.EntityIdent
	--WHERE
	--	NSource.ShowOnCNP = 1
	--	AND NTarget.ShowOnCNP = 1

		
	--SELECT COUNT(*) FROM
	--	#tmpNodes tE WITH (NOLOCK)
	--SELECT COUNT(*) FROM
	--	#tmpEdges tE WITH (NOLOCK)

	DROP TABLE #tmpNodes
	DROP TABLE #tmpEdges






	


GO


-- EXEC uspGetCommunityNetworkMapByEntityIdent 306485, 2, 1
-- EXEC uspGetCommunityNetworkMapByEntityIdent 2, 2, 1