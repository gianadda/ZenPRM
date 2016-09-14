IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityProjectExportByProjectIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityProjectExportByProjectIdent
GO

/* uspGetEntityProjectExportByProjectIdent
 *
 * gets recent exported projects by entity ident / project ident
 *
 *
*/
CREATE PROCEDURE uspGetEntityProjectExportByProjectIdent

	@bntEntityIdent BIGINT,
	@bntEntityProjectIdent BIGINT

AS

	SET NOCOUNT ON

	DECLARE @intCount INT

	SET @intCount = 2 -- set a default value just in cause 

	SELECT
		@intCount = ASA.Value1
	FROM
		ASApplicationVariable ASA WITH (NOLOCK)
	WHERE
		ASA.Name1 = 'ExportProjectRecentCount'

	SELECT TOP (@intCount)
		EPE.Ident,
		EP.Name1 as [ProjectName],
		CONVERT(NVARCHAR(25),EPE.ExportDateTime,100) as [ExportDateTime],
		EPE.ProjectFileName,
		CASE EPE.ProjectFileSize
			WHEN '' THEN EPE.ProjectFileSize
			ELSE dbo.ufnCalculateFileSize(EPE.ProjectFileSize)
		END as [ProjectFileSize],
		REPLACE(REPLACE(S.Name1,'@@NumberOfFilesAttached',CAST(EPE.NumberOfFilesAttached AS NVARCHAR(10))),'@@NumberOfFilesGenerated',CAST(EPE.NumberOfFilesGenerated AS NVARCHAR(10))) as [Status],
		S.PercentComplete,
		S.Downloadable as [ReadyToDownload],
		S.ProcessFile as [Processing]
	FROM
		EntityProjectExport EPE WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			 ON EP.Ident = EPE.EntityProjectIdent
		INNER JOIN
		EntityProjectExportStatus S WITH (NOLOCK)
			ON S.Ident = EPE.EntityProjectExportStatusIdent
	WHERE
		EPE.ExportASUserIdent = @bntEntityIdent
		AND EPE.EntityProjectIdent = @bntEntityProjectIdent
		AND EPE.Active = 1
	ORDER BY
		EPE.ExportDateTime DESC

GO