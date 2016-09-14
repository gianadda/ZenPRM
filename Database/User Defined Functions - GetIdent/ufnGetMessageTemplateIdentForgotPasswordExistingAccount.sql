IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetMessageTemplateIdentForgotPasswordExistingAccount') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnGetMessageTemplateIdentForgotPasswordExistingAccount
GO
/*
	
*/

CREATE FUNCTION ufnGetMessageTemplateIdentForgotPasswordExistingAccount()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(7)

	END

GO