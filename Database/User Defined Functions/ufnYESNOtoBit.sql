IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnYESNOtoBit') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnYESNOtoBit
GO
/* ufnYESNOtoBit
 *
 *	Desc
 *
 */
CREATE FUNCTION ufnYESNOtoBit(@ncrYN as VARCHAR)

	RETURNS BIT
	
 BEGIN

	IF (@ncrYN = 'Y') 
	BEGIN
		RETURN 1
	END
	
	RETURN 0
	
 END

GO