IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetConnectionTypeInNetworkOfIdent') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnGetConnectionTypeInNetworkOfIdent
GO
/* ufnGetConnectionTypeInNetworkOfIdent
 *
 *	Desc
 *
 */
CREATE FUNCTION ufnGetConnectionTypeInNetworkOfIdent()

	RETURNS INT
	
 BEGIN

	RETURN 8

 END

GO