IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetEntityLanguageListByEntityIdent') and xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION ufnGetEntityLanguageListByEntityIdent
GO

/* ufnGetEntityLanguageListByEntityIdent
 *
 *	Returns a string of the active languages concatinated together separated by commas
 *
 */
CREATE FUNCTION ufnGetEntityLanguageListByEntityIdent(@bntEntityIdent BIGINT)

	RETURNS NVARCHAR(MAX)
	
WITH SCHEMABINDING
AS

	BEGIN
		
		DECLARE @nvrList NVARCHAR(MAX)
		SELECT 
			@nvrList = COALESCE(@nvrList + ', ','') +  L.Name1
		FROM 
			dbo.EntityLanguage1XRef X WITH (NOLOCK)
			INNER JOIN
			dbo.Language1 L WITH (NOLOCK)
				ON L.Ident = X.Language1Ident
		WHERE 
			X.EntityIdent = @bntEntityIdent
			AND X.Active = 1
			AND L.Active = 1
		GROUP BY 
			L.Name1
		ORDER BY
			L.Name1 ASC

		SELECT 
			@nvrList = COALESCE(@nvrList,  '')


		RETURN RTRIM(LTRIM(@nvrList))

	END
	
GO