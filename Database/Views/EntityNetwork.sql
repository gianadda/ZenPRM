IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityNetwork') 
	AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP View EntityNetwork
GO
CREATE VIEW EntityNetwork 

WITH SCHEMABINDING
AS 

	SELECT DISTINCT
		EC.Ident as [EntityConnectionIdent],
		fromE.Ident as [FromEntityIdent],
		fromE.FullName as [FromEntityFullName],
		CT.Ident as [ConnectionTypeIdent],
		CT.Name1 as [Name],
		toE.Ident as [ToEntityIdent],
		toE.FullName as [ToEntityFullName],
		EC.Active
	FROM 
		dbo.ConnectionType CT WITH (NOLOCK)
		INNER JOIN
		dbo.EntityConnection EC WITH (NOLOCK)
			ON CT.Ident = EC.ConnectionTypeIdent
		INNER JOIN
		dbo.Entity fromE WITH (NOLOCK)
			ON EC.FromEntityIdent = fromE.Ident
				AND CT.FromEntityTypeIdent = fromE.EntityTypeIdent
		INNER JOIN
		dbo.Entity toE WITH (NOLOCK)
			ON EC.ToEntityIdent = toE.Ident
				AND CT.ToEntityTypeIdent = toE.EntityTypeIdent
	WHERE 
		CT.IncludeInNetwork = 1 -- Don't include network links
		AND fromE.Ident <> 0
		AND toE.Ident <> 0
		AND fromE.Active = 1
		AND toE.Active = 1
		AND CT.Delegate = 0
		AND EC.Active = 1
		AND CT.Active = 1


GO


--CREATE UNIQUE CLUSTERED INDEX idx_EntityNetwork_Ident ON dbo.EntityNetwork(Ident) 
--GO