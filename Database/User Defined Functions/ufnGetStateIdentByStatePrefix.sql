IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetStateIdentByStatePrefix') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnGetStateIdentByStatePrefix
GO
/* ufnGetStateIdentByStatePrefix
 *
 *	Desc
 *
 */
CREATE FUNCTION ufnGetStateIdentByStatePrefix(@ncrName1 as NVARCHAR(75))

	RETURNS BIGINT
	
 BEGIN

	DECLARE @intIdent AS BIGINT
	SET @intIdent = 0

	SELECT 
		@intIdent = Ident
	FROM
		States WITH (NOLOCK)
	WHERE Name1 = @ncrName1

	RETURN @intIdent

 END

GO