IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeAddEntitySearch') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeAddEntitySearch
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeAddEntitySearch()
 
	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(62)

	END

GO