IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnEntitySearchFilterTypeEmailIdent') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnEntitySearchFilterTypeEmailIdent
GO
/*
	
*/

CREATE FUNCTION ufnEntitySearchFilterTypeEmailIdent()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(12)

	END

GO