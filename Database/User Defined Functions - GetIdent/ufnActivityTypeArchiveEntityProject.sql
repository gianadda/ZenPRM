IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeArchiveEntityProject') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeArchiveEntityProject
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeArchiveEntityProject()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(32)

	END

GO