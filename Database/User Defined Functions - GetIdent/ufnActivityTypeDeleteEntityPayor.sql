IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeDeleteEntityPayor') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeDeleteEntityPayor
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeDeleteEntityPayor()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(20)

	END

GO