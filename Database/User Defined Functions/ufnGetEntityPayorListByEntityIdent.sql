IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetEntityPayorListByEntityIdent') and xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION ufnGetEntityPayorListByEntityIdent
GO

/* ufnGetEntityPayorListByEntityIdent
 *
 *	Returns a string of the active payors concatinated together separated by commas
 *
 */
CREATE FUNCTION ufnGetEntityPayorListByEntityIdent(@bntEntityIdent BIGINT)

	RETURNS NVARCHAR(MAX)
	
WITH SCHEMABINDING
AS

	BEGIN
		
		DECLARE @nvrList NVARCHAR(MAX)
		SELECT 
			@nvrList = COALESCE(@nvrList + ', ','') +  P.Name1
		FROM 
			dbo.EntityPayorXRef X WITH (NOLOCK)
			INNER JOIN
			dbo.Payor P WITH (NOLOCK)
				ON P.Ident = X.PayorIdent
		WHERE 
			X.EntityIdent = @bntEntityIdent
			AND X.Active = 1
			AND P.Active = 1
		GROUP BY 
			P.Name1
		ORDER BY
			P.Name1 ASC

		SELECT 
			@nvrList = COALESCE(@nvrList,  '')


		RETURN RTRIM(LTRIM(@nvrList))

	END
	
GO