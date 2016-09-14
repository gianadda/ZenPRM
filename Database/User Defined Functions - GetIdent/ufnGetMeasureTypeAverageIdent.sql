IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetMeasureTypeAverageIdent') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnGetMeasureTypeAverageIdent
GO
/*
	
*/

CREATE FUNCTION ufnGetMeasureTypeAverageIdent()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(1)

	END

GO