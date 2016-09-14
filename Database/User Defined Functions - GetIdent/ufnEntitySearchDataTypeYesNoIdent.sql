IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnEntitySearchDataTypeYesNoIdent') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnEntitySearchDataTypeYesNoIdent
GO
/*
	
*/

CREATE FUNCTION ufnEntitySearchDataTypeYesNoIdent()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(5)

	END

GO