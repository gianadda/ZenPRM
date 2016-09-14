IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityHierarchyByEntityIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityHierarchyByEntityIdent
GO

/* uspGetEntityHierarchyByEntityIdent
 *
 * - Returns all the records from the EntityHierarchy table for a given customer
 *
 *
*/
CREATE PROCEDURE uspGetEntityHierarchyByEntityIdent

	@bntEntityIdent BIGINT,
	@bntFromEntityIdent BIGINT,
	@bntToEntityIdent BIGINT

AS

	SET NOCOUNT ON

	SELECT
		E.Ident,
		E.FullName
	FROM
		Entity E WITH (NOLOCK)
	WHERE
		E.Ident = @bntFromEntityIdent

	SELECT
		EH.Ident as [EntityHierarchyIdent],
		EH.EntityIdent,
		EH.HierarchyTypeIdent,
		EH.ToEntityIdent as [Ident],
		HT.Name1 as [HierarchyType],
		HT.ReverseName1  as [ReverseHierarchyType],
		E.FullName,
		E.DisplayName,
		E.ProfilePhoto,
		COALESCE(fromE.Ident,0) as [OrganizationIdent],
		COALESCE(fromE.OrganizationName, '') as [Organization]
	FROM
		EntityHierarchy EH WITH (NOLOCK)
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = EH.ToEntityIdent
		INNER JOIN
		HierarchyType HT WITH (NOLOCK)
			ON HT.Ident = EH.HierarchyTypeIdent
		LEFT OUTER JOIN
		Entity fromE WITH (NOLOCK)
			ON fromE.Ident = EH.FromEntityIdent
			AND @bntToEntityIdent > 0
		INNER JOIN
		EntityType ET WITH (NOLOCK)
			ON ET.Ident = E.EntityTypeIdent
	WHERE
		EH.EntityIdent = @bntEntityIdent
		AND (EH.FromEntityIdent = @bntFromEntityIdent OR @bntFromEntityIdent = 0)
		AND (EH.ToEntityIdent = @bntToEntityIdent OR @bntToEntityIdent = 0)
		AND EH.Active = 1
	ORDER BY
		E.DisplayName ASC,
		Organization ASC

GO

