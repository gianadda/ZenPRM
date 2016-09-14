IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeAddEntityLanguage') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeAddEntityLanguage
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeAddEntityLanguage()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(27)

	END

GO