IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveEntityType') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetAllActiveEntityType
GO

/* uspGetAllActiveEntityType
 *
 *	NG - Get all EntityType Records
 *
 */

CREATE PROCEDURE uspGetAllActiveEntityType

AS
	
	SET NOCOUNT ON

	SELECT
		Ident,
		Person,
		IncludeInCNP,
		Name1,
		CASE 
			WHEN Ident = 0 THEN ''
			WHEN Person = 1 THEN 'Person'
			ELSE 'Groups'
		END AS 'PersonDesc',
		CASE 
			WHEN Ident = 0 THEN 0
			WHEN Person = 1 THEN 1
			ELSE 2
		END AS 'GroupByOrder'
	FROM
		EntityType WITH (NOLOCK)
	WHERE
		Active = 1
	ORDER BY 
		'GroupByOrder' ASC,
		Name1 ASC

GO

-- uspGetAllActiveEntityType