IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetEntityProjectMeasureMaxValueCount') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnGetEntityProjectMeasureMaxValueCount
GO
/*
	Returns the maximum number of values that can be displayed in the Pie Chart dial
*/

CREATE FUNCTION ufnGetEntityProjectMeasureMaxValueCount()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(7)

	END

GO