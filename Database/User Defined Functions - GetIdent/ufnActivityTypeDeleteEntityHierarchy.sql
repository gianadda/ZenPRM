IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeDeleteEntityHierarchy') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeDeleteEntityHierarchy
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeDeleteEntityHierarchy()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(59)

	END

GO