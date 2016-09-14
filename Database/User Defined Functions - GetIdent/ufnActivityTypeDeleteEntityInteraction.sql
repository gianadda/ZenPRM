IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeDeleteEntityInteraction') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeDeleteEntityInteraction
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeDeleteEntityInteraction()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(51)

	END

GO