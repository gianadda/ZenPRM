IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnEntitySearchDataTypeFileIdent') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnEntitySearchDataTypeFileIdent
GO
/*
	
*/

CREATE FUNCTION ufnEntitySearchDataTypeFileIdent()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(6)

	END

GO