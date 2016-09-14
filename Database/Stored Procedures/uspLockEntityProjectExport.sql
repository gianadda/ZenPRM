IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspLockEntityProjectExport') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspLockEntityProjectExport
GO
/* uspLockEntityProjectExport
 *
 *	Locks records in the EntityProjectExport table for processing
 *
 */
CREATE PROCEDURE uspLockEntityProjectExport

	@intLockSessionIdent BIGINT

AS

	SET NOCOUNT ON

	DECLARE @dteGetDate DATETIME,
			@intLockRecordCount INT

	SET @dteGetDate = dbo.ufnGetMyDate()

	SELECT
		@intLockRecordCount = Value1
	FROM
		ASApplicationVariable ASA WITH (NOLOCK)
	WHERE
		ASA.Name1 = 'MessageQueueLockRecordCount'

	UPDATE TOP (@intLockRecordCount) 
		EPE
	SET
		LockDateTime = @dteGetDate,
		LockSessionIdent = @intLockSessionIdent
	FROM
		EntityProjectExport EPE WITH (NOLOCK)
		INNER JOIN
		EntityProjectExportStatus S WITH (NOLOCK)
			 ON S.Ident = EPE.EntityProjectExportStatusIdent
	WHERE
		EPE.LockSessionIdent = 0
		AND EPE.Active = 1
		AND S.Downloadable = 0
		AND S.ProcessFile = 1 -- make sure the file is in a status to be processed

	SELECT
		EPE.Ident,
		EPE.EntityProjectIdent,
		EP.Name1 as [ProjectName],
		EPE.EntityProjectExportStatusIdent,
		EPE.ExportASUserIdent,
		EPE.ExportDateTime,
		EPE.ExportCompleteDateTime,
		EPE.NumberOfEntitiesIncluded,
		EPE.NumberOfFilesAttached,
		EPE.NumberOfFilesGenerated,
		EPE.ProjectFileName,
		EPE.ProjectFileSize,
		EPE.Active,
		EPE.DeleteDateTime,
		EPE.LockDateTime,
		EPE.LockSessionIdent
	FROM
		EntityProjectExport EPE WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = EPE.EntityProjectIdent
	WHERE
		EPE.LockSessionIdent = @intLockSessionIdent
	ORDER BY
		EPE.ExportDateTime ASC

GO