IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeDeleteEntityEmail') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeDeleteEntityEmail
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeDeleteEntityEmail()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(37)

	END

GO