IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddMessageQueueForForgotPasswordExistingAccount') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspAddMessageQueueForForgotPasswordExistingAccount
GO

/* uspAddMessageQueueForForgotPasswordExistingAccount
 *
 *	CJM - sends a forgot password email for users who attempt to register but already have an account
 *
 */

CREATE PROCEDURE uspAddMessageQueueForForgotPasswordExistingAccount

	@vcrEmailAddress NVARCHAR(75)

AS
	
	SET NOCOUNT ON

	DECLARE @intASUserIdent BIGINT,
			@vcrFirstName NVARCHAR(MAX),
			@intMessageTemplateForgotPasswordIdent BIGINT,
			@intMessageTemplateForgotPasswordExistingAccountIdent BIGINT,
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
		AND EE.Email = @vcrEmailAddress
		AND EE.Active = 1

	IF (@intASUserIdent > 0)

		BEGIN

			SET @intMessageTemplateForgotPasswordIdent = dbo.ufnGetMessageTemplateIdentForgotPassword()
			SET @intMessageTemplateForgotPasswordExistingAccountIdent = dbo.ufnGetMessageTemplateIdentForgotPasswordExistingAccount()
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
				MT.Ident = @intMessageTemplateForgotPasswordExistingAccountIdent

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
				MessageTemplateIdent = MT.Ident, 
				MessageGUID = @nvrGUID,
				ExpirationDateTime = DATEADD(HH,MT.MessageExpirationHours, dbo.ufnGetMyDate()),
				AddDateTime = dbo.ufnGetMyDate(),
				Active = 1
			FROM
				MessageTemplate MT WITH (NOLOCK)
			WHERE
				Ident = @intMessageTemplateForgotPasswordIdent -- a little bit of trickery here
				-- we want to send out the email template for Forgot Password (Existing Account) , but we want to push the user through the existing
				-- forgot password process, so well save the GUID as a ForgotPassword template Ident instead

		END

	SELECT
		COALESCE(@intMessageQueueIdent,0) AS [MessageQueueIdent]

GO