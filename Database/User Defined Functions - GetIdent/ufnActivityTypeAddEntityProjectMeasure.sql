IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeAddEntityProjectMeasure') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeAddEntityProjectMeasure
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeAddEntityProjectMeasure()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(55)

	END

GO