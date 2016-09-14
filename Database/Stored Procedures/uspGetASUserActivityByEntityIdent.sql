IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetASUserActivityByEntityIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetASUserActivityByEntityIdent
GO

/* uspGetASUserActivityByEntityIdent
 *
 *	
 *
 */

CREATE PROCEDURE uspGetASUserActivityByEntityIdent

	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT

AS
	
	SET NOCOUNT ON
	
	SELECT  TOP 5
		AUA.Ident,
		AUA.ActivityDateTime,
		AUA.ActivityDescription
	FROM
		ASUserActivity AUA WITH (NOLOCK)
		INNER JOIN
		EntityNetwork EN WITH (NOLOCK)
			ON AUA.ASUserIdent = EN.ToEntityIdent
	WHERE 
		EN.FromEntityIdent = @bntEntityIdent
	ORDER BY 
		AUA.Ident DESC
		



GO

uspGetASUserActivityByEntityIdent 2, 2
