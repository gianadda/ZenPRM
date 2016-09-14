IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeDeleteEntityService') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeDeleteEntityService
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeDeleteEntityService()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(18)

	END

GO