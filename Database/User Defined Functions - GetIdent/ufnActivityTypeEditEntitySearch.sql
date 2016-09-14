IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeEditEntitySearch') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeEditEntitySearch
GO
/*
	
*/
 
CREATE FUNCTION ufnActivityTypeEditEntitySearch()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(63)

	END

GO