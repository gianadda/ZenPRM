IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetSystemRoleSystemAdminIdent') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnGetSystemRoleSystemAdminIdent
GO
/* ufnGetSystemRoleSystemAdminIdent
 *
 *	Desc
 *
 */
CREATE FUNCTION ufnGetSystemRoleSystemAdminIdent()

	RETURNS INT
	
 BEGIN

	RETURN 1

 END

GO