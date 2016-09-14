IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddMessageQueueForForgotPassword') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspAddMessageQueueForForgotPassword
GO

/* uspAddMessageQueueForForgotPassword
 *
 *	CJM - finds a user account based on email/direct account and prepares the email to send
 *
 */

CREATE PROCEDURE uspAddMessageQueueForForgotPassword

	@vcrEmailAddress NVARCHAR(75)

AS
	
	SET NOCOUNT ON

	DECLARE @intASUserIdent BIGINT,
			@vcrFirstName NVARCHAR(MAX),
			@intMessageTemplateIdent BIGINT,
			@intMessageQueueIdent BIGINT,
			@nvrGUID UNIQUEIDENTIFIER,
			@intMessageTypeIdentEmail BIGINT

	SET @intASUserIdent = 0
	SET @intMessageTypeIdentEmail = dbo.ufnGetMessageTypeIdentEmail()

	-- determine if the email used is the generic user email
	SELECT
		@intASUserIdent = U.Ident,
		@vcrFirstName = U.FirstName
	FROM
		ASUser U WITH (NOLOCK)
		INNER JOIN
		EntityEmail EE (NOLOCK)
			ON EE.EntityIdent = U.Ident
	WHERE
		U.Active = 1
		AND U.ExternalLogin = 0 -- dont let external logins utilize our password recovery (since we dont store their creds)
		AND EE.Email = @vcrEmailAddress
		AND EE.Active = 1

	IF (@intASUserIdent > 0)

		BEGIN

			-- user found, send the email template to include the reset link/guid
			SET @intMessageTemplateIdent = dbo.ufnGetMessageTemplateIdentForgotPassword()
			SET @nvrGUID = NEWID() 

			-- add the reset link email to the queue
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
				ASUserIdent = @intASUserIdent,
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
				MessageBody = REPLACE(REPLACE(MT.MessageBody,'{{GUID}}',@nvrGUID),'{{FirstName}}',@vcrFirstName),
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
				RecordIdent = @intASUserIdent,
				MessageQueueIdent = @intMessageQueueIdent,
				MessageTemplateIdent = @intMessageTemplateIdent,
				MessageGUID = @nvrGUID,
				ExpirationDateTime = DATEADD(HH,MT.MessageExpirationHours, dbo.ufnGetMyDate()),
				AddDateTime = dbo.ufnGetMyDate(),
				Active = 1
			FROM
				MessageTemplate MT WITH (NOLOCK)
			WHERE
				Ident = @intMessageTemplateIdent

			--Added Update to MustChangePassword field after email is generated
			UPDATE Entity
			SET 
				MustChangePassword = 1
			WHERE 
				Ident = @intASUserIdent
				AND Active = 1

		END

	ELSE

		BEGIN

			-- no user found, send the email to state that the email is not linked with an account
			SET @intMessageTemplateIdent = dbo.ufnGetMessageTemplateIdentForgotPasswordNoEmailOnFile()

			-- add the no email on record email to the queue
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
				ASUserIdent = @intASUserIdent,
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
				MessageBody = MT.MessageBody,
				SendAsHTML = MT.SendAsHTML,
				Active = 1,
				AddDateTime = dbo.ufnGetMyDate(),
				AddASUserIdent = @intASUserIdent,
				EditDateTime = '1/1/1900',
				EditASUserIdent = 0,
				LockSessionIdent = 0,
				LockTime = '1/1/1900'
			FROM
				MessageTemplate MT WITH (NOLOCK)
			WHERE
				MT.Ident = @intMessageTemplateIdent
			
			SET @intMessageQueueIdent = SCOPE_IDENTITY()

		END

	SELECT
		COALESCE(@intMessageQueueIdent,0) AS [MessageQueueIdent]

GO