IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnEntitySearchFilterTypeOrganizationIdent') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnEntitySearchFilterTypeOrganizationIdent
GO
/*
	
*/

CREATE FUNCTION ufnEntitySearchFilterTypeOrganizationIdent()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(11)

	END

GO