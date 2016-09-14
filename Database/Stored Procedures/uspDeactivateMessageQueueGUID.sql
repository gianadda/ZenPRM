IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspDeactivateMessageQueueGUID') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspDeactivateMessageQueueGUID
GO
/********************************************************
 * Marks a MessageQueueGUID as inactive											
 *
 *	uspDeactivateMessageQueueGUID 
 *
 *
 ********************************************************/
 
CREATE PROCEDURE uspDeactivateMessageQueueGUID

	@vcrGuid VARCHAR(MAX)

AS
	
	DECLARE @sdtGetDate SMALLDATETIME

	SET @sdtGetDate = dbo.ufnGetMyDate()
	
	UPDATE
		MessageQueueGUID
	SET
		Active = 0
	WHERE
		MessageGUID = @vcrGuid
	
GO