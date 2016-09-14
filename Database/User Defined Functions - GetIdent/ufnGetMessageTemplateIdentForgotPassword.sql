IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetMessageTemplateIdentForgotPassword') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnGetMessageTemplateIdentForgotPassword
GO
/*
	
*/

CREATE FUNCTION ufnGetMessageTemplateIdentForgotPassword()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(1)

	END

GO