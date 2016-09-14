IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetEntityTypeName1ByEntityTypeIdent') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnGetEntityTypeName1ByEntityTypeIdent
GO
/* ufnGetEntityTypeName1ByEntityTypeIdent
 *
 *	Desc
 *
 */
CREATE FUNCTION ufnGetEntityTypeName1ByEntityTypeIdent(@bntIdent as BIGINT)

	RETURNS INT
	
 BEGIN

	DECLARE @ncrName1 AS NVARCHAR(150)
	SET @ncrName1 = ''

	SELECT 
		@ncrName1 = Name1
	FROM
		EntityType WITH (NOLOCK)
	WHERE Ident = @bntIdent

	RETURN @ncrName1

 END

GO