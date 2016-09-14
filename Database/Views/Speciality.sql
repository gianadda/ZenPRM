DROP VIEW Speciality
GO

-- Create view of Speciality via Taxonomy
CREATE VIEW Speciality
WITH SCHEMABINDING

AS

SELECT
	Ident,
	Name1,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
FROM
	dbo.Taxonomy T WITH (NOLOCK)

GO