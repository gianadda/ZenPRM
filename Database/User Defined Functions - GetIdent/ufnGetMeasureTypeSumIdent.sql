IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetMeasureTypeSumIdent') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnGetMeasureTypeSumIdent
GO
/*
	
*/

CREATE FUNCTION ufnGetMeasureTypeSumIdent()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(4)

	END

GO