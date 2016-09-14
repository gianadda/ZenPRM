IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspSearchEntityGlobalListForNewEntityConnection') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspSearchEntityGlobalListForNewEntityConnection
GO

/* uspSearchEntityGlobalListForNewEntityConnection
 *
 * - searches the global entities for records that are not already connected to the entity Ident
 *
*/
CREATE PROCEDURE uspSearchEntityGlobalListForNewEntityConnection

	@nvrKeyword NVARCHAR(500),
	@bntEntityIdent BIGINT,
	@bntEntityTypeIdent BIGINT,
	@bntASUserIdent BIGINT
	
AS

	SET NOCOUNT ON

	SET @nvrKeyword = '%' + @nvrKeyword + '%'
	
	SELECT TOP 15
		E.Ident,
		E.FullName,
		E.NPI,
		E.EntityTypeIdent
	FROM
		Entity E WITH (NOLOCK)
		INNER JOIN
		EntityType ET WITH (NOLOCK)
			ON ET.Ident = E.EntityTypeIdent
	OUTER APPLY 
	   ( 
		SELECT 
			EntityConnectionIdent
		FROM 
			EntityCommunity WITH (NOLOCK)
		WHERE 
			FromEntityIdent = @bntEntityIdent
			AND ToEntityIdent = E.Ident
			AND Active = 1
	  ) A 
	WHERE 
		E.Active = 1
		AND E.FullName <> ''
		AND (RTRIM(LTRIM(E.FullName)) LIKE @nvrKeyword)
		AND E.EntityTypeIdent = @bntEntityTypeIdent
		AND ET.IncludeInCNP = 1
		AND A.EntityConnectionIdent IS NULL
	GROUP BY 
		E.Ident,
		E.FullName,
		E.NPI,
		E.EntityTypeIdent
	ORDER BY
		E.FullName ASC

GO

/*************************************
EXEC uspSearchEntityGlobalListForNewEntityConnection 
	@bntEntityIdent = 306487,
	@bntEntityTypeIdent = 3,
	@bntASUserIdent = 306487,
	@nvrKeyword = 'Angela'
************************************/