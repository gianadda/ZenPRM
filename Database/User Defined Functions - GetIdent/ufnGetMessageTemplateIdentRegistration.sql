IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetMessageTemplateIdentRegistration') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnGetMessageTemplateIdentRegistration
GO
/*
	
*/

CREATE FUNCTION ufnGetMessageTemplateIdentRegistration()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(3)

	END

GO