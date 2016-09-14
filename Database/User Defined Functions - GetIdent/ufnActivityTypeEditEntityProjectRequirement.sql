IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeEditEntityProjectRequirement') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeEditEntityProjectRequirement
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeEditEntityProjectRequirement()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(47)

	END

GO