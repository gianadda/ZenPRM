IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetMessageTemplateIdentForgotPasswordNoEmailOnFile') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnGetMessageTemplateIdentForgotPasswordNoEmailOnFile
GO
/*
	
*/

CREATE FUNCTION ufnGetMessageTemplateIdentForgotPasswordNoEmailOnFile()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(2)

	END

GO