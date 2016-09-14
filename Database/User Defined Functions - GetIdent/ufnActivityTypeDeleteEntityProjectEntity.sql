IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeDeleteEntityProjectEntity') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeDeleteEntityProjectEntity
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeDeleteEntityProjectEntity()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(39)

	END

GO