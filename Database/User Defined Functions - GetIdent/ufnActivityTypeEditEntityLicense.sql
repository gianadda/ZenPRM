IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeEditEntityLicense') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeEditEntityLicense
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeEditEntityLicense()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(25)

	END

GO