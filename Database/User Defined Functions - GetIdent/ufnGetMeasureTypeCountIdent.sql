IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetMeasureTypeCountIdent') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnGetMeasureTypeCountIdent
GO
/*
	
*/

CREATE FUNCTION ufnGetMeasureTypeCountIdent()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(6)

	END

GO