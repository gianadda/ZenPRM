IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspCheckEntityEmailUnique') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspCheckEntityEmailUnique
GO
/********************************************************												
 *
 *	uspCheckEntityEmailUnique 
 * - 7/25/16: note this ignores private contacts since they dont matter for registration & login
 *
 ********************************************************/
 
CREATE PROCEDURE uspCheckEntityEmailUnique

	@vcrEmail VARCHAR(MAX)
AS
	
	SELECT
		E.Ident,
		E.FullName
	FROM
		Entity E WITH (NOLOCK)
		INNER JOIN
		EntityEmail EE WITH (NOLOCK)
			ON EE.EntityIdent = E.Ident
		INNER JOIN
		EntityType ET WITH (NOLOCK)
			ON ET.Ident = E.EntityTypeIdent
	WHERE
		EE.Email = @vcrEmail
		AND EE.Active = 1
		AND E.Active = 1
		AND ET.IncludeInCNP = 1 

GO