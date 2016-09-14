IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnEntitySearchDataTypeHoursOfOperationIdent') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnEntitySearchDataTypeHoursOfOperationIdent
GO
/*
	
*/

CREATE FUNCTION ufnEntitySearchDataTypeHoursOfOperationIdent()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(7)

	END

GO