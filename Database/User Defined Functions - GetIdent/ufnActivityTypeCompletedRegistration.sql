IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeCompletedRegistration') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeCompletedRegistration
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeCompletedRegistration()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(42)

	END

GO