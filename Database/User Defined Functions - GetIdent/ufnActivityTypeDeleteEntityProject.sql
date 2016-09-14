IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeDeleteEntityProject') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeDeleteEntityProject
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeDeleteEntityProject()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(34)

	END

GO