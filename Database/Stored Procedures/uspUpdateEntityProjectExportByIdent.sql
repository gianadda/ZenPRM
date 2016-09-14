IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspUpdateEntityProjectExportByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspUpdateEntityProjectExportByIdent
 GO
/* uspUpdateEntityProjectExportByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE uspUpdateEntityProjectExportByIdent

	@bntIdent BIGINT,
	@bntEntityProjectExportStatusIdent BIGINT,
	@intNumberOfFilesGeneratedIncrement INT,
	@nvrFileName NVARCHAR(MAX),
	@nvrFileSize NVARCHAR(100),
	@nvrFileKey NVARCHAR(MAX),
	@bitUnlockRecord BIT

AS

	SET NOCOUNT ON

	UPDATE
		EntityProjectExport
	SET
		EntityProjectExportStatusIdent = @bntEntityProjectExportStatusIdent,
		ExportCompleteDateTime = CASE @bitUnlockRecord
									WHEN 1 THEN dbo.ufnGetMyDate()
									ELSE ExportCompleteDateTime
								 END,
		NumberOfFilesGenerated = NumberOfFilesGenerated + @intNumberOfFilesGeneratedIncrement,
		ProjectFileName = @nvrFileName,
		ProjectFileSize = @nvrFileSize,
		ProjectFileKey = @nvrFileKey,
		LockDateTime = CASE @bitUnlockRecord
						WHEN 1 THEN '1/1/1900'
						ELSE LockDateTime
					   END,
		LockSessionIdent = CASE @bitUnlockRecord
							WHEN 1 THEN 0
							ELSE LockSessionIdent
						   END
	WHERE
		Ident = @bntIdent

GO