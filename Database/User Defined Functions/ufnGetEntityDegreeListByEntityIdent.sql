IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetEntityDegreeListByEntityIdent') and xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION ufnGetEntityDegreeListByEntityIdent
GO

/* ufnGetEntityDegreeListByEntityIdent
 *
 *	Returns a string of the active degrees concatinated together separated by commas
 *
 */
CREATE FUNCTION ufnGetEntityDegreeListByEntityIdent(@bntEntityIdent BIGINT)

	RETURNS NVARCHAR(MAX)
	
WITH SCHEMABINDING
AS

	BEGIN
		
		DECLARE @nvrList NVARCHAR(MAX)
		SELECT 
			@nvrList = COALESCE(@nvrList + ', ','') +  D.Name1
		FROM 
			dbo.EntityDegreeXRef X WITH (NOLOCK)
			INNER JOIN
			dbo.Degree D WITH (NOLOCK)
				ON D.Ident = X.DegreeIdent
		WHERE 
			X.EntityIdent = @bntEntityIdent
			AND X.Active = 1
			AND D.Active = 1
		GROUP BY 
			D.Name1
		ORDER BY
			D.Name1 ASC

		SELECT 
			@nvrList = COALESCE(@nvrList,  '')


		RETURN RTRIM(LTRIM(@nvrList))

	END
	
GO