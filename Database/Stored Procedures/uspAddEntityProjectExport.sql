IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityProjectExport') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntityProjectExport
 GO
/* uspAddEntityProjectExport
 *
 *
 *
 *
*/
CREATE PROCEDURE uspAddEntityProjectExport

	@bntEntityProjectIdent BIGINT,
	@bntASUserIdent BIGINT,
	@bntNumberOfEntitiesIncluded BIGINT,
	@bntNumberOfFilesAttached BIGINT

AS

	SET NOCOUNT ON

	INSERT INTO EntityProjectExport (
		EntityProjectIdent,
		EntityProjectExportStatusIdent,
		ExportASUserIdent,
		ExportDateTime,
		ExportCompleteDateTime,
		NumberOfEntitiesIncluded,
		NumberOfFilesAttached,
		NumberOfFilesGenerated,
		ProjectFileName,
		ProjectFileSize,
		ProjectFileKey,
		Active,
		DeleteDateTime,
		LockDateTime,
		LockSessionIdent
	) 
	SELECT 
		EntityProjectIdent = @bntEntityProjectIdent,
		EntityProjectExportStatusIdent = 0, -- default to 0
		ExportASUserIdent = @bntASUserIdent,
		ExportDateTime = dbo.ufnGetMyDate(),
		ExportCompleteDateTime = '1/1/1900',
		NumberOfEntitiesIncluded = @bntNumberOfEntitiesIncluded,
		NumberOfFilesAttached = @bntNumberOfFilesAttached,
		NumberOfFilesGenerated = 0,
		ProjectFileName = '',
		ProjectFileSize = '',
		ProjectFileKey = '',
		Active = 1,
		DeleteDateTime = '1/1/1900',
		LockDateTime = '1/1/1900',
		LockSessionIdent = 0

	SELECT SCOPE_IDENTITY() AS [Ident]

GO