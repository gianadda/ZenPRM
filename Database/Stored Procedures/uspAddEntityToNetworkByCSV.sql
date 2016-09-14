IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityToNetworkByCSV') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntityToNetworkByCSV
 GO
/* uspAddEntityToNetworkByCSV 506, '19591591', 1, 1
 *
 *
 *
 *
*/ 
CREATE PROCEDURE [dbo].[uspAddEntityToNetworkByCSV]

	@intFromEntityIdent BIGINT = 0, 
	@nvrNPICSV NVARCHAR(MAX),
	@intAddASUserIdent BIGINT = 0,  
	@bitActive BIT = False

AS

	SET NOCOUNT ON


	CREATE TABLE #tmpNPIs (
		FromEntityIdent BIGINT,
		ToEntityIdent BIGINT,
		NPI NVARCHAR (MAX),
		FullName NVARCHAR (MAX),
		EntitiesWithThisNPI BIGINT,
		ExistingRelationshipCount BIGINT,
		ConnectionTypeInNetworkOfIdent BIGINT,
		FromEntityIsACustomer BIT
	)

	INSERT INTO  #tmpNPIs (
		FromEntityIdent ,
		ToEntityIdent ,
		NPI ,
		FullName,
		EntitiesWithThisNPI ,
		ExistingRelationshipCount ,
		ConnectionTypeInNetworkOfIdent ,
		FromEntityIsACustomer 
	)
	SELECT DISTINCT
		FromEntityIdent = @intFromEntityIdent ,
		ToEntityIdent = 0 ,
		NPI = LTRIM(RTRIM(SS.Value)),
		FullName = 'Unknown',
		EntitiesWithThisNPI = 0 ,
		ExistingRelationshipCount = 0 ,
		ConnectionTypeInNetworkOfIdent = 0 ,
		FromEntityIsACustomer = 0  
		
	FROM
		dbo.ufnSplitString(@nvrNPICSV, ',') SS
		 
	--Make sure that this is a customer doing it.
	UPDATE #tmpNPIs
	SET FromEntityIsACustomer = 1
	FROM
		Entity E WITH (NOLOCK)
	WHERE 
		E.Ident = @intFromEntityIdent
		AND E.Customer = 1
		AND E.Active = 1

	--Go get the Ident of any Matching NPIs
	UPDATE tN
	SET ToEntityIdent = E.Ident
	FROM
		#tmpNPIs tN
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON tN.NPI = E.NPI 
	WHERE 
		E.Active = 1

	--Look for it by NPI
	UPDATE tN
	SET EntitiesWithThisNPI = CONVERT(BIT, E.Ident)
	FROM
		#tmpNPIs tN
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON tN.NPI = E.NPI 
	WHERE 
		E.Active = 1


	--See if there are any relationships (in Network)
	UPDATE tN
	SET ExistingRelationshipCount = CONVERT(BIT, EN.EntityConnectionIdent)
	FROM
		#tmpNPIs tN
		INNER JOIN
		EntityNetwork EN WITH (NOLOCK)
			ON EN.FromEntityIdent = tN.FromEntityIdent
			AND EN.ToEntityIdent = tN.ToEntityIdent
	WHERE 
		EN.Active = 1

	--Go get the Ident the appropriate ConnectionType
	UPDATE tN
	SET ConnectionTypeInNetworkOfIdent = CT.Ident
	FROM
		#tmpNPIs tN
		INNER JOIN
		Entity fromE WITH (NOLOCK)
			ON fromE.Ident = tN.FromEntityIdent			
		INNER JOIN
		Entity toE WITH (NOLOCK)
			ON  toE.Ident = tN.ToEntityIdent
		INNER JOIN
		ConnectionType CT WITH (NOLOCK)
			ON CT.FromEntityTypeIdent = fromE.EntityTypeIdent
				AND CT.ToEntityTypeIdent = toE.EntityTypeIdent
	WHERE
		CT.IncludeInNetwork = 1

	-- Look up the Full Name
	UPDATE tN
	SET FullName = E.FullName
	FROM
		#tmpNPIs tN
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = tN.ToEntityIdent

	
	INSERT INTO EntityConnection (
		ConnectionTypeIdent, 
		FromEntityIdent, 
		ToEntityIdent, 
		AddASUserIdent, 
		AddDateTime, 
		EditASUserIdent, 
		EditDateTime, 
		Active
	) 
	SELECT DISTINCT
		ConnectionTypeIdent = tN.ConnectionTypeInNetworkOfIdent, 
		FromEntityIdent =tN.FromEntityIdent, 
		ToEntityIdent = tN.ToEntityIdent, 
		AddASUserIdent = @intAddASUserIdent, 
		AddDateTime = dbo.ufnGetMyDate(), 
		EditASUserIdent = 0, 
		EditDateTime = '1/1/1900', 
		Active = @bitActive
	FROM
		#tmpNPIs tN
	WHERE 
		tN.ToEntityIdent <> 0 --We found the entity by NPI
		AND tN.ExistingRelationshipCount = 0 -- There isn't already a relationship
		AND tN.FromEntityIsACustomer = 1 -- From Entity is a customer
		AND tN.ConnectionTypeInNetworkOfIdent <> 0


	SELECT DISTINCT
		tN.ToEntityIdent as [Ident],
		tN.NPI as [NPI],
		CASE WHEN tN.EntitiesWithThisNPI > 0 THEN 1 ELSE 0 END as [Found],
		tN.FullName as [FullName]
	FROM
		#tmpNPIs tN
	WHERE 
		tN.FromEntityIsACustomer = 1 -- From Entity is a customer

GO