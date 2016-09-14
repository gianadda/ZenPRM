IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnToDoStatusClosedIdent') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnToDoStatusClosedIdent
GO
/*
	
*/

CREATE FUNCTION ufnToDoStatusClosedIdent()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(3)

	END

GO