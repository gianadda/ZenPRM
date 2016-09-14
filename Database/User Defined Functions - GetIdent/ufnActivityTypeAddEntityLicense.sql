IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeAddEntityLicense') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeAddEntityLicense
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeAddEntityLicense()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(24)

	END

GO