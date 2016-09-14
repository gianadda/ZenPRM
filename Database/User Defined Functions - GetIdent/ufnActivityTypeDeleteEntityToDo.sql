IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeDeleteEntityToDo') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeDeleteEntityToDo
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeDeleteEntityToDo()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(45)

	END

GO