IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeCompletedRequirement') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeCompletedRequirement
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeCompletedRequirement()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(6)

	END

GO