IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetMessageTemplateIdentProjectNotification') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnGetMessageTemplateIdentProjectNotification
GO
/*
	
*/

CREATE FUNCTION ufnGetMessageTemplateIdentProjectNotification()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(6)

	END

GO