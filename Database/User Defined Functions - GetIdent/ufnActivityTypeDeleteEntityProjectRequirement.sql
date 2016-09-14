IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeDeleteEntityProjectRequirement') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeDeleteEntityProjectRequirement
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeDeleteEntityProjectRequirement()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(48)

	END

GO