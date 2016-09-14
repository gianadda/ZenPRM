IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspCheckMessageQueueGUIDByMessageTemplateIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspCheckMessageQueueGUIDByMessageTemplateIdent
GO
/********************************************************
 * This procedure will check an incoming GUID to determine
 *	whether a user has appropriate access via an email link
 *	to enter into the system.														
 *
 *	uspCheckMessageQueueGUIDByMessageTemplateIdent 
 *
 *	3/28/16: Removed the deactivated of the GUID upon initial get. Found that some emails clients pre-verified
 *			the link, which would cause user errors since they technically will be the second time clicking the link
 *
 ********************************************************/
 
CREATE PROCEDURE uspCheckMessageQueueGUIDByMessageTemplateIdent

	@vcrGuid VARCHAR(MAX),
	@intMessageTemplateIdent BIGINT

AS
	
	DECLARE @sdtGetDate SMALLDATETIME

	SET @sdtGetDate = dbo.ufnGetMyDate()
	
	SELECT
		MQG.Ident,
		MQG.RecordIdent,
		MQG.MessageGUID,
		MQG.AddDateTime,
		MQG.ExpirationDateTime,
		MQG.Active
	FROM
		MessageQueueGUID MQG WITH (NOLOCK)
	WHERE
		MQG.Active = 1
		AND MQG.MessageGUID = @vcrGuid
		AND MQG.ExpirationDateTime > @sdtGetDate
		AND MQG.MessageTemplateIdent = @intMessageTemplateIdent
	
GO