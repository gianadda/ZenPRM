IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeDeleteEntitySpecialty') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeDeleteEntitySpecialty
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeDeleteEntitySpecialty()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(16)

	END

GO