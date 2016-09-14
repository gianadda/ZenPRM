IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveImportColumn') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetAllActiveImportColumn
 GO
/* uspGetAllActiveImportColumn
 *
 *
 *
 *
*/
CREATE PROCEDURE uspGetAllActiveImportColumn

AS

	SET NOCOUNT ON
	
	SELECT
		Ident = 0,
		Label = 'N/A',
		ColumnName = ''
	UNION
	SELECT 
		Ident,
		Label,
		ColumnName
	FROM
		ImportColumn WITH (NOLOCK)
	WHERE
		Active = 1
	ORDER BY
		ColumnName

GO