IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityToNetworkByNPI') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntityToNetworkByNPI
 GO
/* uspAddEntityToNetworkByNPI 506, '19591591', 1, 1
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspAddEntityToNetworkByNPI]

	@intFromEntityIdent BIGINT = 0, 
	@nvrNPI NVARCHAR(MAX),
	@intAddASUserIdent BIGINT = 0,  
	@bitActive BIT = False

AS

	SET NOCOUNT ON


	DECLARE @intToEntityIdent AS BIGINT
	DECLARE @intEntitiesWithThisNPI AS BIGINT
	DECLARE @intExistingRelationshipCount AS BIGINT
	DECLARE @intConnectionTypeInNetworkOfIdent AS BIGINT
	DECLARE @bitFromEntityIsACustomer AS BIT
	
	SET @intToEntityIdent = 0
	SET @intEntitiesWithThisNPI = 0
	SET @intExistingRelationshipCount = 0
	SET @intConnectionTypeInNetworkOfIdent = 0
	SET @bitFromEntityIsACustomer = 0

	SET @nvrNPI = LTRIM(RTRIM(@nvrNPI))
	
	SELECT 
		@bitFromEntityIsACustomer = 1
	FROM
		Entity E WITH (NOLOCK)
	WHERE 
		E.Ident = @intFromEntityIdent
		AND E.Customer = 1
		AND E.Active = 1

	SELECT 
		@intToEntityIdent = Ident
	FROM
		Entity E WITH (NOLOCK)
	WHERE 
		E.NPI = @nvrNPI
		AND E.Active = 1

	--Look for it by NPI
	SELECT 
		@intEntitiesWithThisNPI = COUNT(Ident)
	FROM
		Entity E WITH (NOLOCK)
	WHERE 
		E.NPI = @nvrNPI
		AND E.Active = 1

	----	If we don't find it, add it
	--IF @intEntitiesWithThisNPI = 0
	--BEGIN

	--	EXEC uspAddEntity  3, @nvrNPI

	--	--Since we added it, go look it up
	--	SELECT 
	--		@intToEntityIdent = Ident
	--	FROM
	--		Entity E WITH (NOLOCK)
	--	WHERE 
	--		E.NPI = @nvrNPI

	--	--Update it to be active
	--	UPDATE Entity 
	--	SET Active = 1
	--	WHERE 
	--		NPI = @nvrNPI

	--END 

	SELECT 
		@intExistingRelationshipCount = COUNT(Ident)
	FROM
		EntityConnection EC WITH (NOLOCK)
	WHERE 
		EC.FromEntityIdent = @intFromEntityIdent
		AND EC.ToEntityIdent = @intToEntityIdent
		AND EC.ConnectionTypeIdent = @intConnectionTypeInNetworkOfIdent
		AND EC.Active = 1

	SELECT 
		@intConnectionTypeInNetworkOfIdent = CT.Ident
	FROM 
		ConnectionType CT WITH (NOLOCK)
		INNER JOIN
		Entity fromE WITH (NOLOCK)
			ON CT.FromEntityTypeIdent = fromE.EntityTypeIdent
		INNER JOIN
		Entity toE WITH (NOLOCK)
			ON CT.ToEntityTypeIdent = toE.EntityTypeIdent
	WHERE 
		fromE.Ident = @intFromEntityIdent
		AND toE.Ident = @intToEntityIdent
		AND CT.IncludeInNetwork = 1
	
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
	SELECT 
		ConnectionTypeIdent = @intConnectionTypeInNetworkOfIdent, 
		FromEntityIdent = @intFromEntityIdent, 
		ToEntityIdent = @intToEntityIdent, 
		AddASUserIdent = @intAddASUserIdent, 
		AddDateTime = dbo.ufnGetMyDate(), 
		EditASUserIdent = 0, 
		EditDateTime = '1/1/1900', 
		Active = @bitActive
	WHERE 
		@intToEntityIdent <> 0 --We found the entity by NPI
		AND @intExistingRelationshipCount = 0 -- There isn't already a relationship
		AND @bitFromEntityIsACustomer = 1 -- From Entity is a customer


	SELECT 
		@intToEntityIdent as [Ident],
		CASE WHEN @intEntitiesWithThisNPI > 0 THEN 1 ELSE 0 END as [Found]


GO

 --uspAddEntityToNetworkByNPI 3, '1447253315', 1, 1

