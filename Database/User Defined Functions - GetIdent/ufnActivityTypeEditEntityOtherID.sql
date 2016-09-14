IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeEditEntityOtherID') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeEditEntityOtherID
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeEditEntityOtherID()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(22)

	END

GO