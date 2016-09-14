IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityDelegateByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetEntityDelegateByIdent
 GO
/* uspGetEntityDelegateByIdent 306486
 *
 *
 *
 *
*/
CREATE PROCEDURE uspGetEntityDelegateByIdent
	
	@intIdent BIGINT

AS

	SET NOCOUNT ON

	SELECT 
		[SortOrder] = CASE fromE.Ident WHEN 306485 THEN 1 ELSE 0 END, --306485 is aHealthTech
		toE.Ident as [FromEntityIdent],
		toE.FullName as [FromEntityFullName],
		CT.Ident as [ConnectionTypeIdent],
		CT.ReverseName1 as [Name],
		fromE.Ident as [ToEntityIdent],
		fromE.FullName as [ToEntityFullName],
		EC.Active
	FROM 
		ConnectionType CT WITH (NOLOCK)
		INNER JOIN
		EntityConnection EC WITH (NOLOCK)
			ON CT.Ident = EC.ConnectionTypeIdent
		INNER JOIN
		Entity fromE WITH (NOLOCK)
			ON EC.FromEntityIdent = fromE.Ident
				AND CT.FromEntityTypeIdent = fromE.EntityTypeIdent
		INNER JOIN
		Entity toE WITH (NOLOCK)
			ON EC.ToEntityIdent = toE.Ident
				AND CT.ToEntityTypeIdent = toE.EntityTypeIdent
	WHERE 
		CT.IncludeInNetwork = 0 -- Don't include network links
		AND CT.Delegate = 1
		AND EC.Active = 1
		AND CT.Active = 1
		AND toE.Ident = @intIdent
	UNION
	SELECT 
		[SortOrder] = CASE fromE.Ident WHEN 306485 THEN 1 ELSE 0 END, --306485 is aHealthTech
		toE.Ident as [FromEntityIdent],
		toE.FullName as [FromEntityFullName],
		CT.Ident as [ConnectionTypeIdent],
		CT.ReverseName1 as [Name],
		fromE.Ident as [ToEntityIdent],
		fromE.FullName as [ToEntityFullName],
		1 as [Active]
	FROM
		ZenTeam toE WITH (NOLOCK)
		INNER JOIN
		ConnectionType CT WITH (NOLOCK)
			ON CT.ToEntityTypeIdent= toE.EntityTypeIdent
				AND CT.IncludeInNetwork = 0 -- Don't include network links
				AND CT.Delegate = 1
		INNER JOIN
		Customer fromE WITH (NOLOCK)
			ON CT.FromEntityTypeIdent = fromE.EntityTypeIdent
	WHERE 
		toE.Ident = @intIdent
		AND CT.IncludeInNetwork = 0 -- Don't include network links
		AND CT.Delegate = 1
		AND fromE.Active = 1
		AND fromE.Customer = 1 
	ORDER BY
		SortOrder DESC,
		fromE.FullName ASC

GO
uspGetEntityDelegateByIdent 306486
