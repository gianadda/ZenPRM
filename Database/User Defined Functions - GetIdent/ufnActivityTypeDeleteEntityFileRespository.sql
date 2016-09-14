IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeDeleteEntityFileRespository') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeDeleteEntityFileRespository
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeDeleteEntityFileRespository()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(40)

	END

GO