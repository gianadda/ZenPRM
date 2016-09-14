IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeAddEntityProjectEntity') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeAddEntityProjectEntity
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeAddEntityProjectEntity()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(38)

	END

GO