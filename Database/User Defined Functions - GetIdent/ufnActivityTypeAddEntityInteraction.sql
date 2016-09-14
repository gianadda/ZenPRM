IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeAddEntityInteraction') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeAddEntityInteraction
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeAddEntityInteraction()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(49)

	END

GO