IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityNetworkImportHistory') 
	and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspAddEntityNetworkImportHistory
GO

/* uspAddEntityNetworkImportHistory
 *
 *	Adds a record into EntityNetworkImportHistory table 
 *
 */
CREATE PROCEDURE uspAddEntityNetworkImportHistory

	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT,
	@nvrImportData NVARCHAR(MAX)

AS

	INSERT INTO EntityNetworkImportHistory(
		EntityIdent,
		ASUserIdent,
		ImportDateTime,
		ImportData
	)
	SELECT
		EntityIdent = @bntEntityIdent,
		ASUserIdent = @bntASUserIdent,
		ImportDateTime = dbo.ufnGetMyDate(),
		ImportData = @nvrImportData

GO