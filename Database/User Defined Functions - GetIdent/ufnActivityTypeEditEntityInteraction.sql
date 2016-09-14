IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeEditEntityInteraction') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeEditEntityInteraction
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeEditEntityInteraction()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(50)

	END

GO