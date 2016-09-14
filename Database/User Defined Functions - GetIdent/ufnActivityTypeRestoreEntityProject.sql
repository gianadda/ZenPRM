IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeRestoreEntityProject') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeRestoreEntityProject
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeRestoreEntityProject()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(33)

	END

GO