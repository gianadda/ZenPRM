IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeDeleteEntityOtherID') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeDeleteEntityOtherID
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeDeleteEntityOtherID()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(23)

	END

GO