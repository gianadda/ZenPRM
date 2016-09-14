IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeDeleteEntityLicense') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeDeleteEntityLicense
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeDeleteEntityLicense()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(26)

	END

GO