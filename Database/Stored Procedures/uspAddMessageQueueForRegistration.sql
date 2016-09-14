IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddMessageQueueForRegistration') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspAddMessageQueueForRegistration
GO

/* uspAddMessageQueueForRegistration
 *
 *	CJM - sends an email for user to register based on the provided entityIdent
 *
 */

CREATE PROCEDURE uspAddMessageQueueForRegistration

	@nvrEmailAddress NVARCHAR(MAX),
	@bntEntityIdent BIGINT,
	@nvrEntityFirstName NVARCHAR(MAX),
	@bntASUserIdent BIGINT,
	@bntASUserFullname NVARCHAR(MAX),
	@bntAddEditASUserIdent BIGINT

AS
	
	SET NOCOUNT ON

	DECLARE @intMessageTemplateRegistrationIdent BIGINT,
			@intMessageTypeIdentEmail BIGINT,
			@intMessageQueueIdent BIGINT,
			@nvrGUID UNIQUEIDENTIFIER
			
	SET @intMessageTypeIdentEmail = dbo.ufnGetMessageTypeIdentEmail()
	SET @intMessageTemplateRegistrationIdent = dbo.ufnGetMessageTemplateIdentRegistration()
	SET @nvrGUID = NEWID()

	INSERT INTO MessageQueue(
		ASUserIdent,
		MessageTypeIdent,
		MessageTemplateIdent,
		MessageSent,
		LastAttemptedDateTime,
		NumberOfAttempts,
		ToAddress,
		CCAddress,
		BCCAddress,
		FromAddress,
		FromDisplayName,
		ReplyToAddress,
		MessageSubject,
		MessageBody,
		SendAsHTML,
		Active, 
		AddDateTime,
		AddASUserIdent,
		EditDateTime,
		EditASUserIdent,
		LockSessionIdent,
		LockTime
	) 
	SELECT
		ASUserIdent = @bntEntityIdent,
		MessageTypeIdent = @intMessageTypeIdentEmail,
		MessageTemplateIdent = MT.Ident,
		MessageSent = 0,
		LastAttemptedDateTime = '1/1/1900',
		NumberOfAttempts = 0,
		ToAddress = @nvrEmailAddress,
		CCAddress = '',
		BCCAddress = '',
		FromAddress = MT.FromAddress,
		FromDisplayName = MT.FromDisplayName,
		ReplyToAddress = MT.ReplyToAddress,
		MessageSubject = REPLACE(MT.MessageSubject,'{{Customer}}',@bntASUserFullname),
		MessageBody = REPLACE(REPLACE(REPLACE(MT.MessageBody,'{{GUID}}',@nvrGUID),'{{FirstName}}',@nvrEntityFirstName), '{{Customer}}', @bntASUserFullname),
		SendAsHTML = MT.SendAsHTML,
		Active = 1,
		AddDateTime = dbo.ufnGetMyDate(),
		AddASUserIdent = @bntAddEditASUserIdent,
		EditDateTime = '1/1/1900',
		EditASUserIdent = 0,
		LockSessionIdent = 0,
		LockTime = '1/1/1900'
	FROM
		MessageTemplate MT WITH (NOLOCK)
	WHERE
		MT.Ident = @intMessageTemplateRegistrationIdent

	SET @intMessageQueueIdent = SCOPE_IDENTITY()
	
	INSERT INTO MessageQueueGUID(
		RecordIdent,
		MessageQueueIdent,
		MessageTemplateIdent,
		MessageGUID,
		ExpirationDateTime,
		AddDateTime,
		Active
	)
	SELECT
		RecordIdent = @bntEntityIdent,
		MessageQueueIdent = @intMessageQueueIdent,
		MessageTemplateIdent = MT.Ident,
		MessageGUID = @nvrGUID,
		ExpirationDateTime = DATEADD(HH,MT.MessageExpirationHours, dbo.ufnGetMyDate()),
		AddDateTime = dbo.ufnGetMyDate(),
		Active = 1
	FROM
		MessageTemplate MT WITH (NOLOCK)
	WHERE
		MT.Ident = @intMessageTemplateRegistrationIdent

	SELECT @intMessageQueueIdent AS [MessageQueueIdent]
	
GO