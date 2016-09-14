IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveEntitySearchFilterType') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetAllActiveEntitySearchFilterType
 GO
/* uspGetAllActiveEntitySearchFilterType
 *
 *
 *
 *
*/
CREATE PROCEDURE uspGetAllActiveEntitySearchFilterType

AS

	SET NOCOUNT ON

	SELECT
		Ident,
		Name1,
		ReferenceTable,
		BitValue,
		ProjectSpecific,
		HierarchySpecific,
		EntityFilter,
		EntityChildFilter
	FROM
		EntitySearchFilterType WITH (NOLOCK)
	WHERE
		Active = 1
	ORDER BY
		Name1 ASC

GO