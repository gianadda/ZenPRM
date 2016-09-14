IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeAddEntityToDo') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeAddEntityToDo
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeAddEntityToDo()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(43)

	END

GO