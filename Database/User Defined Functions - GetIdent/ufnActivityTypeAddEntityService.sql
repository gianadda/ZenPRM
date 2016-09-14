IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeAddEntityService') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeAddEntityService
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeAddEntityService()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(17)

	END

GO