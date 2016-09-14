IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeAddEntityTaxonomy') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeAddEntityTaxonomy
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeAddEntityTaxonomy()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(10)

	END

GO