IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnToDoTypeRequirement') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnToDoTypeRequirement
GO
/*
	
*/

CREATE FUNCTION ufnToDoTypeRequirement()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(3)

	END

GO