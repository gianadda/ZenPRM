IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeEditEntityToDo') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeEditEntityToDo
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeEditEntityToDo()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(44)

	END

GO