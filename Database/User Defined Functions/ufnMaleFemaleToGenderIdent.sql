IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnMaleFemaleToGenderIdent') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnMaleFemaleToGenderIdent
GO
/* ufnMaleFemaleToGenderIdent
 *
 *	Desc
 *
 */
CREATE FUNCTION ufnMaleFemaleToGenderIdent(@ncrMF as VARCHAR)

	RETURNS INT
	
 BEGIN

	IF (@ncrMF = 'M') 
	BEGIN
		RETURN 1
	END
	
	IF (@ncrMF = 'F') 
	BEGIN
		RETURN 2
	END

	RETURN 0
	
 END

GO