IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeAssignEntityToDo') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeAssignEntityToDo
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeAssignEntityToDo()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(54)

	END

GO