IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeEditProfile') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeEditProfile
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeEditProfile()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(5)

	END

GO