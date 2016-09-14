IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeEditEntityEmail') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeEditEntityEmail
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeEditEntityEmail()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(36)

	END

GO