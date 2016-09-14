IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeEditEntityProjectMeasure') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeEditEntityProjectMeasure
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeEditEntityProjectMeasure()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(56)

	END

GO