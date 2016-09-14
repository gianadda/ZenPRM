IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddMessageQueueForDelegateEmail') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspAddMessageQueueForDelegateEmail
GO

/* uspAddMessageQueueForDelegateEmail
 *
 *	CJM - queues an email to the resource to let them know someone added them as a delegate
 *
 */

CREATE PROCEDURE uspAddMessageQueueForDelegateEmail

	@vcrEmailAddress NVARCHAR(75),
	@bntDelegateIdent BIGINT,
	@nvrDelegateFirstName NVARCHAR(MAX),
	@nvrEntityFullName NVARCHAR(MAX)

AS
	
	SET NOCOUNT ON

	DECLARE @intMessageTemplateIdent BIGINT,
			@intMessageTypeIdentEmail BIGINT,
			@intMessageQueueIdent BIGINT

	SET @intMessageTypeIdentEmail = dbo.ufnGetMessageTypeIdentEmail()
	SET @intMessageTemplateIdent = dbo.ufnGetMessageTemplateIdentDelegateEmail()
	
	-- add the delegate email to the queue
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
		ASUserIdent = @bntDelegateIdent,
		MessageTypeIdent = @intMessageTypeIdentEmail,
		MessageTemplateIdent = MT.Ident,
		MessageSent = 0,
		LastAttemptedDateTime = '1/1/1900',
		NumberOfAttempts = 0,
		ToAddress = @vcrEmailAddress,
		CCAddress = '',
		BCCAddress = '',
		FromAddress = MT.FromAddress,
		FromDisplayName = MT.FromDisplayName,
		ReplyToAddress = MT.ReplyToAddress,
		MessageSubject = MT.MessageSubject,
		MessageBody = REPLACE(REPLACE(MT.MessageBody,'{{FirstName}}',@nvrDelegateFirstName),'{{EntityName}}',@nvrEntityFullName),
		SendAsHTML = MT.SendAsHTML,
		Active = 1,
		AddDateTime = dbo.ufnGetMyDate(),
		AddASUserIdent = 0,
		EditDateTime = '1/1/1900',
		EditASUserIdent = 0,
		LockSessionIdent = 0,
		LockTime = '1/1/1900'
	FROM
		MessageTemplate MT WITH (NOLOCK)
	WHERE
		MT.Ident = @intMessageTemplateIdent

	SET @intMessageQueueIdent = SCOPE_IDENTITY()

	SELECT COALESCE(@intMessageQueueIdent,0) AS [MessageQueueIdent]

GO