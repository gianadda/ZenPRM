IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeAddEntityProject') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeAddEntityProject
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeAddEntityProject()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(31)

	END

GO