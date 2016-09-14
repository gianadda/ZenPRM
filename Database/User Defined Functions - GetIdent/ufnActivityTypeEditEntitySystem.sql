IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeEditEntitySystem') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeEditEntitySystem
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeEditEntitySystem()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(13)

	END

GO