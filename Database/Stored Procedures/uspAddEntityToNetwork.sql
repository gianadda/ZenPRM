IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityToNetwork') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntityToNetwork
 GO
/* uspAddEntityToNetwork 506, 777, 1, 1
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspAddEntityToNetwork]

	@intFromEntityIdent BIGINT = 0, 
	@intToEntityIdent BIGINT = 0, 
	@intAddASUserIdent BIGINT = 0,  
	@bitActive BIT = 0,
	@bitSuppressOutput BIT = 0

AS

	SET NOCOUNT ON


	DECLARE @nvrNPI AS VARCHAR(MAX)
	DECLARE @intEntitiesWithThisNPI AS BIGINT
	DECLARE @intExistingRelationshipCount AS BIGINT
	DECLARE @intConnectionTypeInNetworkOfIdent AS BIGINT
	DECLARE @bitFromEntityIsACustomer AS BIT
	
	SET @nvrNPI = ''
	SET @intEntitiesWithThisNPI = 0
	SET @intExistingRelationshipCount = 0
	SET @intConnectionTypeInNetworkOfIdent = 0
	SET @bitFromEntityIsACustomer = 0

	
	SELECT 
		@bitFromEntityIsACustomer = 1
	FROM
		Entity E WITH (NOLOCK)
	WHERE 
		E.Ident = @intFromEntityIdent
		AND E.Customer = 1
		AND E.Active = 1
		
	SELECT 
		@nvrNPI = E.NPI
	FROM
		Entity E WITH (NOLOCK)
	WHERE 
		E.Ident = @intToEntityIdent
		AND E.Active = 1
		
	--Look for it by NPI
	SELECT 
		@intEntitiesWithThisNPI = COUNT(Ident)
	FROM
		Entity E WITH (NOLOCK)
	WHERE 
		E.NPI = @nvrNPI
		AND E.Active = 1
		
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

	IF @bitSuppressOutput = 0
	BEGIN 
		SELECT 
			@intToEntityIdent As [Ident],
			CASE WHEN @intEntitiesWithThisNPI > 0 THEN 1 ELSE 0 END  As [Found]
	END

GO


