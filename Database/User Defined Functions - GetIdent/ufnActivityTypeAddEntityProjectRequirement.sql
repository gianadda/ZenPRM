IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeAddEntityProjectRequirement') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeAddEntityProjectRequirement
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeAddEntityProjectRequirement()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(46)

	END

GO