IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeDeleteEntityConnection') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeDeleteEntityConnection
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeDeleteEntityConnection()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(9)

	END

GO