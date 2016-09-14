IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityCommunity') 
	AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP View EntityCommunity
GO

CREATE VIEW EntityCommunity

AS 

--Primary direction
	SELECT
		EC.Ident as [EntityConnectionIdent],
		fromE.Ident as [FromEntityIdent],
		fromE.FullName as [FromEntityFullName],
		CT.Ident as [ConnectionTypeIdent],
		CT.Name1 as [Name],
		1 as [Forward],
		toE.Ident as [ToEntityIdent],
		toE.FullName as [ToEntityFullName],
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
		AND CT.Delegate = 0
		AND fromE.Ident <> 0
		AND toE.Ident <> 0
		AND fromE.Active = 1
		AND toE.Active = 1
		AND EC.Active = 1
		AND CT.Active = 1
	UNION ALL

--Reverse direction
	SELECT 
		EC.Ident as [EntityConnectionIdent],
		fromE.Ident as [FromEntityIdent],
		fromE.FullName as [FromEntityFullName],
		CT.Ident as [ConnectionTypeIdent],
		CT.ReverseName1 as [Name],
		0 as [Forward],
		toE.Ident as [ToEntityIdent],
		toE.FullName as [ToEntityFullName],
		EC.Active
	FROM 
		ConnectionType CT WITH (NOLOCK)
		INNER JOIN
		EntityConnection EC WITH (NOLOCK)
			ON CT.Ident = EC.ConnectionTypeIdent
		INNER JOIN
		Entity toE WITH (NOLOCK)
			ON EC.FromEntityIdent = toE.Ident
				AND CT.FromEntityTypeIdent = toE.EntityTypeIdent
		INNER JOIN
		Entity fromE WITH (NOLOCK)
			ON EC.ToEntityIdent = fromE.Ident
				AND CT.ToEntityTypeIdent = fromE.EntityTypeIdent
	WHERE 
		CT.IncludeInNetwork = 0 -- Don't include network links
		AND fromE.Ident <> 0
		AND toE.Ident <> 0
		AND fromE.Active = 1
		AND toE.Active = 1
		AND CT.Delegate = 0
		AND EC.Active = 1
		AND CT.Active = 1

GO