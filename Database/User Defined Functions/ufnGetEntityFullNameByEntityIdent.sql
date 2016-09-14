IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetEntityFullNameByEntityIdent') and xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION ufnGetEntityFullNameByEntityIdent
GO

/* ufnGetEntityFullNameByEntityIdent
 *
 *	Returns the entity full name based on the entityident
 *
 */
CREATE FUNCTION ufnGetEntityFullNameByEntityIdent(@bntEntityIdent BIGINT)

	RETURNS NVARCHAR(MAX)

AS

	BEGIN
		
		DECLARE @nvrFullname NVARCHAR(MAX)

		SELECT 
			@nvrFullname = Fullname
		FROM 
			Entity WITH (NOLOCK)
		WHERE 
			Ident = @bntEntityIdent

		RETURN COALESCE(@nvrFullname,'')

	END
	
GO

-- SELECT dbo.ufnGetEntityFullNameByEntityIdent(306485)