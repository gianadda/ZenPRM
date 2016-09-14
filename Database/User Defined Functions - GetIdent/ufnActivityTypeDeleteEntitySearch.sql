IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeDeleteEntitySearch') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeDeleteEntitySearch
GO
/*
	
*/
 
CREATE FUNCTION ufnActivityTypeDeleteEntitySearch()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(64)

	END

GO