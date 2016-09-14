IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeAddEntitySystem') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeAddEntitySystem
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeAddEntitySystem()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(12)

	END

GO