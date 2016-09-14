IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetMessageTypeIdentEmail') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnGetMessageTypeIdentEmail
GO
/*
	
*/

CREATE FUNCTION ufnGetMessageTypeIdentEmail()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(1)

	END

GO