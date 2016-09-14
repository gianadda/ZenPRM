DROP VIEW EntitySpecialityXRef
GO


CREATE VIEW EntitySpecialityXRef
WITH SCHEMABINDING

AS

SELECT
	Ident,
	EntityIdent,
	SpecialityIdent = TaxonomyIdent,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
FROM
	DBO.EntityTaxonomyXRef WITH (NOLOCK)
GO