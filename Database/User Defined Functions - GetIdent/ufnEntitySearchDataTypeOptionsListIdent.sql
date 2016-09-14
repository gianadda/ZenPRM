IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnEntitySearchDataTypeOptionsListIdent') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnEntitySearchDataTypeOptionsListIdent
GO
/*
	
*/

CREATE FUNCTION ufnEntitySearchDataTypeOptionsListIdent()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(4)

	END

GO