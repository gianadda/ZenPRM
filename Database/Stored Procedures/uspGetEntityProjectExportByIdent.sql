IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityProjectExportByIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityProjectExportByIdent
GO

/* uspGetEntityProjectExportByIdent
 *
 * gets a specific export record so the user can download the file
 *
 *
*/
CREATE PROCEDURE uspGetEntityProjectExportByIdent

	@bntIdent BIGINT,
	@bntEntityIdent BIGINT

AS

	SET NOCOUNT ON

	SELECT
		EPE.Ident,
		EP.Ident as [ProjectIdent],
		EPE.ProjectFileName,
		EPE.ProjectFileKey
	FROM
		EntityProjectExport EPE WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			 ON EP.Ident = EPE.EntityProjectIdent
		INNER JOIN
		EntityProjectExportStatus S WITH (NOLOCK)
			ON S.Ident = EPE.EntityProjectExportStatusIdent
	WHERE
		EPE.ExportASUserIdent = @bntEntityIdent -- make sure they have permission to the file
		AND EPE.Ident = @bntIdent 
		AND EPE.Active = 1
		AND S.Downloadable = 1 -- and make sure its downloadable

GO