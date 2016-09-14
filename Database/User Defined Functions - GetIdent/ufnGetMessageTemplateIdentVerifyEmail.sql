IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetMessageTemplateIdentVerifyEmail') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnGetMessageTemplateIdentVerifyEmail
GO
/*
	
*/

CREATE FUNCTION ufnGetMessageTemplateIdentVerifyEmail()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(4)

	END

GO