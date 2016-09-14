IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeAddEntityOtherID') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeAddEntityOtherID
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeAddEntityOtherID()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(21)

	END

GO