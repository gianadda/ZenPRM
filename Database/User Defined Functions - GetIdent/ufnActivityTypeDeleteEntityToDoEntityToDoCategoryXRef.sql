IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeDeleteEntityToDoEntityToDoCategoryXRef') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeDeleteEntityToDoEntityToDoCategoryXRef
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeDeleteEntityToDoEntityToDoCategoryXRef()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(61)

	END

GO