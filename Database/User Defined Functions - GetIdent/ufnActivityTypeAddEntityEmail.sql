IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeAddEntityEmail') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeAddEntityEmail
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeAddEntityEmail()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(35)

	END

GO