IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeAddEntityConnection') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeAddEntityConnection
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeAddEntityConnection()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(8)

	END

GO