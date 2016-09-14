IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveTaxonomy') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetAllActiveTaxonomy
 GO
/* uspGetAllActiveTaxonomy
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetAllActiveTaxonomy]

AS

	SET NOCOUNT ON

	SELECT 
		Ident, 
		Name1
	FROM
		Taxonomy WITH (NOLOCK)
	WHERE
		Active = 1
	ORDER BY
		Name1
GO