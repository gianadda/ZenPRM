IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetEntityTypeIsPersonByEntityTypeIdent') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnGetEntityTypeIsPersonByEntityTypeIdent
GO
/* ufnGetEntityTypeIsPersonByEntityTypeIdent
 *
 *	Desc
 *
 */
CREATE FUNCTION ufnGetEntityTypeIsPersonByEntityTypeIdent(@bntIdent as BIGINT)

	RETURNS INT
	
 BEGIN

	DECLARE @bitIsPerson AS BIT
	SET @bitIsPerson = 0

	SELECT 
		@bitIsPerson = Person
	FROM
		EntityType WITH (NOLOCK)
	WHERE Ident = @bntIdent

	RETURN @bitIsPerson

 END

GO