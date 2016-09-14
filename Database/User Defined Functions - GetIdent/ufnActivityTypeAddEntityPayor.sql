IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeAddEntityPayor') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeAddEntityPayor
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeAddEntityPayor()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(19)

	END

GO