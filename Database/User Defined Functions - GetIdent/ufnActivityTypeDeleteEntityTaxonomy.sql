IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnActivityTypeDeleteEntityTaxonomy') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnActivityTypeDeleteEntityTaxonomy
GO
/*
	
*/

CREATE FUNCTION ufnActivityTypeDeleteEntityTaxonomy()

	RETURNS BIGINT

AS

	BEGIN
		
		RETURN(11)

	END

GO