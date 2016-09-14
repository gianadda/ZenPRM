IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspSearchEntityNetworkForToDoAssignment') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspSearchEntityNetworkForToDoAssignment
GO

/* uspSearchEntityNetworkForToDoAssignment
 *
 * - searches an entities network for a matching entity based on keyword
 * - used anywhere we are trying to assign an entity to a To Do Item
 *
*/
CREATE PROCEDURE uspSearchEntityNetworkForToDoAssignment

	@bntEntityIdent BIGINT,
	@nvrKeyword NVARCHAR(500)

AS

	SET NOCOUNT ON

	SET @nvrKeyword = '%' + @nvrKeyword + '%'
	
	SELECT
		E.Ident,
		E.FullName,
		E.NPI,
		E.ProfilePhoto
	FROM
		Entity E WITH (NOLOCK)
		INNER JOIN
		EntityNetwork EN WITH (NOLOCK)
			ON EN.FromEntityIdent = @bntEntityIdent
				AND EN.ToEntityIdent = E.Ident
	WHERE 
		E.Active = 1
		AND E.FullName <> ''
		AND (RTRIM(LTRIM(E.FullName)) LIKE @nvrKeyword OR E.NPI LIKE @nvrKeyword)
	GROUP BY 
		E.Ident,
		E.FullName,
		E.NPI,
		E.ProfilePhoto
	ORDER BY
		E.FullName ASC

GO

/*************************************
EXEC uspSearchEntityNetworkForToDoAssignment 
	@bntEntityIdent = 306485,
	@nvrKeyword = 'Ang'
************************************/