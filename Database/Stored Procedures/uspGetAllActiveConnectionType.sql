IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveConnectionType') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetAllActiveConnectionType
GO

/* uspGetAllActiveConnectionType
 *
 *	NG - Get all ConnectionType Records
 *
 */

CREATE PROCEDURE uspGetAllActiveConnectionType

AS
	
	SET NOCOUNT ON

	SELECT 
		fromET.Ident as [FromEntityTypeIdent],
		fromET.Name1 as [FromEntityTypeName1],
		CT.Ident,
		CT.Name1,
		CT.ReverseName1,
		CT.IncludeInNetwork,
		toET.Ident as [ToEntityTypeIdent],
		toET.Name1 as [ToEntityTypeName1],
		CT.Delegate
	FROM 
		ConnectionType CT WITH (NOLOCK)
		INNER JOIN
		EntityType fromET WITH (NOLOCK)
			ON CT.FromEntityTypeIdent = fromET.Ident
		INNER JOIN
		EntityType toET WITH (NOLOCK)
			ON CT.ToEntityTypeIdent = toET.Ident
	WHERE
		CT.Active = 1
		AND fromET.Active = 1
		AND toET.Active = 1
	ORDER BY
		CT.Name1

GO

-- uspGetAllActiveConnectionType