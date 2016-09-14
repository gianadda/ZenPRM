IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetMessageTemplateIdentDelegateEmail') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnGetMessageTemplateIdentDelegateEmail
GO
/*
	
*/

CREATE FUNCTION ufnGetMessageTemplateIdentDelegateEmail()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(5)

	END

GO