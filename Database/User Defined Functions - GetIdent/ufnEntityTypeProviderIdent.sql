IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnEntityTypeProviderIdent') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnEntityTypeProviderIdent
GO
/*
	
*/

CREATE FUNCTION ufnEntityTypeProviderIdent()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(3)

	END

GO