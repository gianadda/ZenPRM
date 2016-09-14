IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetGenderName1ByIdent') and xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION ufnGetGenderName1ByIdent
GO

/* ufnGetGenderName1ByIdent
 *
 *	Returns a string of the name of the gender
 *
 */
CREATE FUNCTION ufnGetGenderName1ByIdent(@bntIdent BIGINT)

	RETURNS NVARCHAR(MAX)

AS

	BEGIN
		
		DECLARE @nvrGender NVARCHAR(MAX) = ''
		SELECT 
			@nvrGender = G.Name1
		FROM 
			Gender G WITH (NOLOCK)
		WHERE 
			G.Ident = @bntIdent
			AND G.Active = 1
		

		RETURN @nvrGender

	END
	
GO