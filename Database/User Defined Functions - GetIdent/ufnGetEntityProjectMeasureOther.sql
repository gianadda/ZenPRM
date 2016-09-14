IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetEntityProjectMeasureOther') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnGetEntityProjectMeasureOther
GO
/*
	
*/

CREATE FUNCTION ufnGetEntityProjectMeasureOther()

	RETURNS NVARCHAR(5)

AS

	BEGIN
		
		RETURN('Other')

	END

GO