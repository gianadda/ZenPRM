IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityNetwork') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityNetwork
GO

/* uspGetEntityNetwork 306485, 306487, 0, 1
 *
 * This proc brings back all resources in a particular customers network
 *
 *
*/
CREATE PROCEDURE uspGetEntityNetwork

	@bntASUserIdent BIGINT, --Current User (i.e. Delegated)
	@bntAddEditASUserIdent BIGINT = 0, -- Logged in User (ie. Office Manager)
	@bitIncludePersons BIT,
	@bitIncludeOrganizations BIT

AS

	SET NOCOUNT ON
	
	SELECT DISTINCT
		E.Ident as [EntityIdent],
		E.DisplayName,
		E.FullName,
		E.NPI,
		ET.Person
	FROM
		EntityNetwork EN WITH (NOLOCK)
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = EN.ToEntityIdent
		INNER JOIN
		EntityType ET WITH (NOLOCK)
			ON ET.Ident = E.EntityTypeIdent
	WHERE 
		EN.FromEntityIdent = @bntASUserIdent
		AND EN.Active = 1
		AND E.Active = 1
		AND ((ET.Person = 1 AND @bitIncludePersons = 1)
		OR (ET.Person = 0 AND @bitIncludeOrganizations = 1))
	UNION
	SELECT
		E.Ident as [EntityIdent],
		E.DisplayName,
		E.FullName,
		E.NPI,
		ET.Person
	FROM
		Entity E WITH (NOLOCK)
		INNER JOIN
		EntityType ET WITH (NOLOCK)
			ON ET.Ident = E.EntityTypeIdent
	WHERE
		E.Ident = @bntASUserIdent
		AND E.Customer = 1
		AND (ET.Person = 0 AND @bitIncludeOrganizations = 1)
	ORDER BY
		DisplayName ASC

GO