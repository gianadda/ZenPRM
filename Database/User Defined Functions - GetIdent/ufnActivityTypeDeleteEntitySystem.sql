IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeDeleteEntitySystem') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeDeleteEntitySystem
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeDeleteEntitySystem()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(14)

	END

GO