IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeAddEntityDegree') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeAddEntityDegree
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeAddEntityDegree()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(29)

	END

GO