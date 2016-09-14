IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddASApplicationServiceAudit') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspAddASApplicationServiceAudit
GO
/* uspAddASApplicationServiceAudit
 *
 *	Adds the ASApplicationServiceAudit record for the given service execution
 *
 */
CREATE PROCEDURE uspAddASApplicationServiceAudit

	@nvrServerName NVARCHAR(200),
	@nvrServiceName NVARCHAR(200),
	@bntProcessedRecordCount BIGINT,
	@nvrProcessedMessage NVARCHAR(MAX)

AS

	SET NOCOUNT ON

	INSERT INTO ASApplicationServiceAudit(
		ServerName,
		ServiceName,
		ServiceDateTime,
		ProcessedRecordCount,
		ProcessedMessage
	)
	SELECT
		ServerName = @nvrServerName,
		ServiceName = @nvrServiceName,
		ServiceDateTime = dbo.ufnGetMyDate(),
		ProcessedRecordCount = @bntProcessedRecordCount,
		ProcessedMessage = @nvrProcessedMessage

GO