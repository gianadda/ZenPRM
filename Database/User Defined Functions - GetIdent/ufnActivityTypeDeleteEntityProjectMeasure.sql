IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeDeleteEntityProjectMeasure') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeDeleteEntityProjectMeasure
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeDeleteEntityProjectMeasure()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(57)

	END

GO