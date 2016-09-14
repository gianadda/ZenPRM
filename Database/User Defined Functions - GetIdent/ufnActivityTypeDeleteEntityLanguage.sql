IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeDeleteEntityLanguage') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeDeleteEntityLanguage
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeDeleteEntityLanguage()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(28)

	END

GO