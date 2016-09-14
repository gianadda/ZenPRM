IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeAddEntitySpecialty') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeAddEntitySpecialty
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeAddEntitySpecialty()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(15)

	END

GO