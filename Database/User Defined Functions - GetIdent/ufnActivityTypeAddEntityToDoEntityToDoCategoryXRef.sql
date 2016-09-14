IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeAddEntityToDoEntityToDoCategoryXRef') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeAddEntityToDoEntityToDoCategoryXRef
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeAddEntityToDoEntityToDoCategoryXRef()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(60)

	END

GO