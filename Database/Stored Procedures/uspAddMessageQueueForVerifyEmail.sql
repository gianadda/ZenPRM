IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddMessageQueueForVerifyEmail') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspAddMessageQueueForVerifyEmail
GO

/* uspAddMessageQueueForVerifyEmail
 *
 *	CJM - sends an email for user to verify their email account
 *
 */

CREATE PROCEDURE uspAddMessageQueueForVerifyEmail

	@nvrIdents NVARCHAR(MAX)

AS
	
	SET NOCOUNT ON

	DECLARE @intMessageTemplateVerifyEmailIdent BIGINT,
			@intMessageTypeIdentEmail BIGINT,
			@intMessageQueueIdent BIGINT
			
	DECLARE @InsertedMessageQueue TABLE (
		Ident BIGINT,
		ASUserIdent BIGINT,
		MessageTypeIdent BIGINT,
		MessageTemplateIdent BIGINT,
		MessageSent BIT,
		LastAttemptedDateTime DATETIME,
		NumberOfAttempts INT,
		ToAddress NVARCHAR(MAX),
		CCAddress NVARCHAR(MAX),
		BCCAddress NVARCHAR(MAX),
		FromAddress NVARCHAR(500),
		FromDisplayName NVARCHAR(500),
		ReplyToAddress NVARCHAR(500),
		MessageSubject NVARCHAR(500),
		MessageBody NVARCHAR(MAX),
		SendAsHTML BIT,
		Active BIT,
		AddDateTime DATETIME,
		AddASUserIdent INT,
		EditDateTime DATETIME,
		EditASUserIdent INT,
		LockSessionIdent INT,
		LockTime SMALLDATETIME
	)

	SET @intMessageTypeIdentEmail = dbo.ufnGetMessageTypeIdentEmail()
	SET @intMessageTemplateVerifyEmailIdent = dbo.ufnGetMessageTemplateIdentVerifyEmail()

	CREATE TABLE #tmpEntityEmail(
		Ident BIGINT,
		MessageGUID UNIQUEIDENTIFIER
	)

	INSERT INTO #tmpEntityEmail(
		Ident,
		MessageGUID
	)
	SELECT	
		[Value],
		NEWID()
	FROM
		dbo.ufnSplitString(@nvrIdents,N',')

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
	) OUTPUT INSERTED.* INTO @InsertedMessageQueue
	SELECT
		ASUserIdent = EE.EntityIdent,
		MessageTypeIdent = @intMessageTypeIdentEmail,
		MessageTemplateIdent = MT.Ident,
		MessageSent = 0,
		LastAttemptedDateTime = '1/1/1900',
		NumberOfAttempts = 0,
		ToAddress = EE.Email,
		CCAddress = '',
		BCCAddress = '',
		FromAddress = MT.FromAddress,
		FromDisplayName = MT.FromDisplayName,
		ReplyToAddress = MT.ReplyToAddress,
		MessageSubject = MT.MessageSubject,
		MessageBody = REPLACE(REPLACE(MT.MessageBody,'{{GUID}}',tEE.MessageGUID),'{{FirstName}}',E.FirstName),
		SendAsHTML = MT.SendAsHTML,
		Active = 1,
		AddDateTime = dbo.ufnGetMyDate(),
		AddASUserIdent = 0,
		EditDateTime = '1/1/1900',
		EditASUserIdent = 0,
		LockSessionIdent = 0,
		LockTime = '1/1/1900'
	FROM
		MessageTemplate MT WITH (NOLOCK),
		#tmpEntityEmail tEE WITH (NOLOCK)
		INNER JOIN
		EntityEmail EE WITH (NOLOCK)
			ON EE.Ident = tEE.Ident
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = EE.EntityIdent
	WHERE
		MT.Ident = @intMessageTemplateVerifyEmailIdent
	
	-- the insert records are outputed to @InsertedMessageQueue
	-- join back to that table to insert the necessary child record for the matchin queue record
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
		RecordIdent = tEE.Ident,
		MessageQueueIdent = IMQ.Ident,
		MessageTemplateIdent = IMQ.MessageTemplateIdent,
		MessageGUID = tEE.MessageGUID,
		ExpirationDateTime = DATEADD(HH,MT.MessageExpirationHours, dbo.ufnGetMyDate()),
		AddDateTime = dbo.ufnGetMyDate(),
		Active = 1
	FROM
		@InsertedMessageQueue IMQ 
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = IMQ.ASUserIdent
		INNER JOIN
		EntityEmail EE WITH (NOLOCK)
			ON EE.EntityIdent = E.Ident
		INNER JOIN
		#tmpEntityEmail tEE WITH (NOLOCK)
			ON tEE.Ident = EE.Ident
		INNER JOIN
		MessageTemplate MT WITH (NOLOCK)
			ON MT.Ident = IMQ.MessageTemplateIdent

	DROP TABLE #tmpEntityEmail

GO