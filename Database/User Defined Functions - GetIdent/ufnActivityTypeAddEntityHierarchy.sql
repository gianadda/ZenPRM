IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeAddEntityHierarchy') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeAddEntityHierarchy
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeAddEntityHierarchy()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(58)

	END

GO