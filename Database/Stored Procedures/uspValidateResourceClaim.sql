IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspValidateResourceClaim') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspValidateResourceClaim
 GO
/* uspValidateResourceClaim
 *
 * Ensures the user claiming an account has access to do so
 *
 *
*/
CREATE PROCEDURE uspValidateResourceClaim

	@intEntityIdent BIGINT,
	@intASUserIdent BIGINT

AS

	SET NOCOUNT ON

	/************************

		Business Rules to be considered a valid claim
			1. User must be a customer
			2. Resource must be in users network
			3. Resource must be a non-person entity type
			4. Resource must have no existing delegates

	************************/

	DECLARE @bitIsCustomer BIT,
			@bitIsInNetwork BIT,
			@bitHasDelegate BIT

	SELECT
		@bitIsCustomer = Customer,
		@bitIsInNetwork = 1
	FROM
		Entity E WITH (NOLOCK)
		INNER JOIN
		EntityNetwork EN WITH (NOLOCK)
			ON EN.FromEntityIdent = E.Ident
	WHERE
		E.Ident = @intASUserIdent
		AND EN.ToEntityIdent = @intEntityIdent

	SELECT
		@bitHasDelegate = 1
	FROM
		EntityDelegate ED WITH (NOLOCK)
		INNER JOIN
		Entity toE WITH (NOLOCK)
			ON ED.ToEntityIdent = toE.Ident
	WHERE
		ED.FromEntityIdent = @intEntityIdent

	SELECT
		E.Ident
	FROM
		Entity E WITH (NOLOCK)
		INNER JOIN
		EntityType ET WITH (NOLOCK)
			ON ET.Ident = E.EntityTypeIdent
	WHERE
		COALESCE(@bitIsCustomer,0) = 1
		AND COALESCE(@bitIsInNetwork,0) = 1
		AND COALESCE(@bitHasDelegate,0) = 0
		AND E.Ident = @intEntityIdent
		AND E.Active = 1
		AND ET.Person = 0

GO