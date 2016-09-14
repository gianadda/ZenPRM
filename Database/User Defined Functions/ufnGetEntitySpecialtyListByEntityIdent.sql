IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetEntitySpecialtyListByEntityIdent') and xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION ufnGetEntitySpecialtyListByEntityIdent
GO

/* ufnGetEntitySpecialtyListByEntityIdent
 *
 *	Returns a string of the active specialties concatinated together separated by commas
 *
 */
CREATE FUNCTION ufnGetEntitySpecialtyListByEntityIdent(@bntEntityIdent BIGINT)

	RETURNS NVARCHAR(MAX)
	
WITH SCHEMABINDING
AS

	BEGIN
		
		DECLARE @nvrList NVARCHAR(MAX)
		SELECT 
			@nvrList = COALESCE(@nvrList + ', ','') +  S.Name1
		FROM 
			dbo.EntitySpecialityXRef X WITH (NOLOCK)
			INNER JOIN
			dbo.Speciality S WITH (NOLOCK)
				ON S.Ident = X.SpecialityIdent
		WHERE 
			X.EntityIdent = @bntEntityIdent
			AND X.Active = 1
			AND S.Active = 1
		GROUP BY 
			S.Name1
		ORDER BY
			S.Name1 ASC


		SELECT 
			@nvrList = COALESCE(@nvrList,  '')


		RETURN RTRIM(LTRIM(@nvrList))

	END
	
GO