IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeDeleteEntityDegree') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeDeleteEntityDegree
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeDeleteEntityDegree()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(30)

	END

GO