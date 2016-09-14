IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnEntitySearchDataTypeNumberIdent') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnEntitySearchDataTypeNumberIdent
GO
/*
	
*/

CREATE FUNCTION ufnEntitySearchDataTypeNumberIdent()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(1)

	END

GO