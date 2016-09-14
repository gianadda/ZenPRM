IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddMessageQueueForProjectNotification') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspAddMessageQueueForProjectNotification
GO

/* uspAddMessageQueueForProjectNotification
 *
 *	CJM - sends an email for all participants with a registered email
 *
 */

CREATE PROCEDURE uspAddMessageQueueForProjectNotification

	@bntASUserIdent BIGINT,
	@bntAddEditASUserIdent BIGINT,
	@bntEntityProjectIdent BIGINT,
	@nvrCustomMessage NVARCHAR(MAX) = ''

AS
	
	SET NOCOUNT ON

	DECLARE @intMessageTemplateProjectNotificationIdent BIGINT,
			@intMessageTemplateRegistrationIdent BIGINT,
			@intMessageTypeIdentEmail BIGINT,
			@bitIncludeEntireNetwork BIT,
			@intSentRegistrationEmail INT,
			@intSentProjectNotification INT,
			@intNotRegisteredByNoEmail INT,
			@intRegisteredByMarkedAsNonNotify INT,
			@dteGetDate DATETIME,
			@nvrEntityFullName NVARCHAR(MAX),
			@nvrEntityProjectName NVARCHAR(MAX),
			@intPrivateResources INT
			
	SET @intMessageTypeIdentEmail = dbo.ufnGetMessageTypeIdentEmail()
	SET @intMessageTemplateProjectNotificationIdent = dbo.ufnGetMessageTemplateIdentProjectNotification()
	SET @intMessageTemplateRegistrationIdent = dbo.ufnGetMessageTemplateIdentRegistration()

	SET @dteGetDate = dbo.ufnGetMyDate()

	SELECT 
		@bitIncludeEntireNetwork = EP.IncludeEntireNetwork,
		@nvrEntityProjectName = EP.Name1,
		@nvrEntityFullName = E.FullName
	FROM
		EntityProject EP WITH (NOLOCK)
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = EP.EntityIdent
	WHERE 
		EP.Ident = @bntEntityProjectIdent

	
	IF (LEN(@nvrCustomMessage) > 0)
		BEGIN

			SET @nvrCustomMessage = @nvrEntityFullName + ' has included a message for this project: <br />' + @nvrCustomMessage + '<br /><br />'

		END


	DECLARE @InsertedMessageQueue TABLE (
		Ident BIGINT,
		ASUserIdent BIGINT,
		MessageTypeIdent BIGINT,
		MessageTemplateIdent BIGINT
	)

	CREATE TABLE #tmpEntityProjectEntity (
		EntityIdent BIGINT,
		EntityFirstName NVARCHAR(MAX),
		MessageGUID UNIQUEIDENTIFIER,
		Registered BIT,
		NotRegisteredButHasEmail BIT,
		MarkedAsNotify BIT,
		PublicResource BIT
	)

	INSERT INTO #tmpEntityProjectEntity (
		EntityIdent,
		EntityFirstName,
		MessageGUID,
		Registered,
		NotRegisteredButHasEmail,
		MarkedAsNotify,
		PublicResource
	)
	SELECT 
		EN.ToEntityIdent ,
		EntityFirstName = E.FirstName,
		MessageGUID = NEWID(),
		Registered = E.Registered,
		NotRegisteredButNoEmail = 0,
		MarkedAsNotify = 0,
		PublicResource = ET.IncludeInCNP
	FROM
		EntityNetwork EN WITH (NOLOCK)
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON EN.ToEntityIdent = E.Ident
		INNER JOIN
		EntityType ET WITH (NOLOCK)
			ON ET.Ident = E.EntityTypeIdent
	WHERE 
		@bitIncludeEntireNetwork = 1
		AND EN.FromEntityIdent = @bntASUserIdent
		AND EN.Active = 1
	UNION ALL
	SELECT
		EPE.EntityIdent ,
		EntityFirstName = E.FirstName,
		MessageGUID = NEWID(),
		Registered = E.Registered,
		NotRegisteredButNoEmail = 0,
		MarkedAsNotify = 0,
		PublicResource = ET.IncludeInCNP
	FROM	
		EntityProjectEntity EPE WITH (NOLOCK)
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON EPE.EntityIdent = E.Ident
		INNER JOIN
		EntityType ET WITH (NOLOCK)
			ON ET.Ident = E.EntityTypeIdent
	WHERE 
		@bitIncludeEntireNetwork = 0
		AND EPE.EntityProjectIdent = @bntEntityProjectIdent
		AND EPE.Active = 1

	UPDATE
		tEPE
	SET
		MarkedAsNotify = 1
	FROM
		#tmpEntityProjectEntity tEPE WITH (NOLOCK)
		INNER JOIN
		EntityEmail EE WITH (NOLOCK)
			ON EE.EntityIdent = tEPE.EntityIdent
	WHERE
		EE.Active = 1
		AND EE.Notify = 1

	UPDATE
		tEPE
	SET
		NotRegisteredButHasEmail = 1
	FROM
		#tmpEntityProjectEntity tEPE WITH (NOLOCK)
		INNER JOIN
		EntityEmail EE WITH (NOLOCK)
			ON EE.EntityIdent = tEPE.EntityIdent
	WHERE
		tEPE.Registered = 0
		AND EE.Active = 1
		
	-- SELECT * FROM #tmpEntityProjectEntity WITH (NOLOCK)

	-- now that we've grouped our entities, lets send the emails for those you can receive them
	-- first, the project notification email
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
	) OUTPUT INSERTED.Ident,INSERTED.ASUserIdent,INSERTED.MessageTypeIdent,INSERTED.MessageTemplateIdent INTO @InsertedMessageQueue
	SELECT
		ASUserIdent = tEPE.EntityIdent,
		MessageTypeIdent = @intMessageTypeIdentEmail,
		MessageTemplateIdent = MT.Ident,
		MessageSent = 0,
		LastAttemptedDateTime = '1/1/1900',
		NumberOfAttempts = 0,
		ToAddress = EE.Email,
		CCAddress = dbo.ufnGetEntityDelegateEmailListByEntityIdent(tEPE.EntityIdent), -- include delegates!
		BCCAddress = '',
		FromAddress = MT.FromAddress,
		FromDisplayName = MT.FromDisplayName,
		ReplyToAddress = MT.ReplyToAddress,
		MessageSubject = MT.MessageSubject,
		MessageBody = REPLACE(REPLACE(REPLACE(REPLACE(MT.MessageBody,'{{EntityProjectName}}',@nvrEntityProjectName),'{{EntityName}}',@nvrEntityFullName), '{{CustomMessage}}', @nvrCustomMessage),'{{FirstName}}', tEPE.EntityFirstName),
		SendAsHTML = MT.SendAsHTML,
		Active = 1,
		AddDateTime = @dteGetDate,
		AddASUserIdent = @bntAddEditASUserIdent,
		EditDateTime = '1/1/1900',
		EditASUserIdent = 0,
		LockSessionIdent = 0,
		LockTime = '1/1/1900'
	FROM
		MessageTemplate MT WITH (NOLOCK),
		#tmpEntityProjectEntity tEPE WITH (NOLOCK)
		INNER JOIN
		EntityEmail EE WITH (NOLOCK)
			ON EE.EntityIdent = tEPE.EntityIdent
	WHERE
		MT.Ident = @intMessageTemplateProjectNotificationIdent
		AND (tEPE.Registered = 1 AND tEPE.MarkedAsNotify = 1)
		AND tEPE.PublicResource = 1
		AND EE.Active = 1
		AND EE.Notify = 1

	-- the insert records are outputed to @InsertedMessageQueue
	-- join back to that table to insert the necessary child record for the matching queue record
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
		RecordIdent = @bntEntityProjectIdent,
		MessageQueueIdent = IMQ.Ident,
		MessageTemplateIdent = IMQ.MessageTemplateIdent,
		MessageGUID = tEPE.MessageGUID,
		ExpirationDateTime = DATEADD(HH,MT.MessageExpirationHours, @dteGetDate),
		AddDateTime = @dteGetDate,
		Active = 1
	FROM
		@InsertedMessageQueue IMQ
		INNER JOIN
		#tmpEntityProjectEntity tEPE WITH (NOLOCK)
			ON tEPE.EntityIdent = IMQ.ASUserIdent
		INNER JOIN
		MessageTemplate MT WITH (NOLOCK)
			ON MT.Ident = IMQ.MessageTemplateIdent

	-- clear the result set, then send the registration email
	DELETE FROM @InsertedMessageQueue

	-- second, send the registration email
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
	) OUTPUT INSERTED.Ident,INSERTED.ASUserIdent,INSERTED.MessageTypeIdent,INSERTED.MessageTemplateIdent INTO @InsertedMessageQueue
	SELECT
		ASUserIdent = tEPE.EntityIdent,
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
		MessageSubject = REPLACE(MT.MessageSubject,'{{Customer}}',@nvrEntityFullName),
		MessageBody = REPLACE(REPLACE(REPLACE(MT.MessageBody,'{{GUID}}',tEPE.MessageGUID),'{{FirstName}}',tEPE.EntityFirstName), '{{Customer}}', @nvrEntityFullName),
		SendAsHTML = MT.SendAsHTML,
		Active = 1,
		AddDateTime = @dteGetDate,
		AddASUserIdent = @bntAddEditASUserIdent,
		EditDateTime = '1/1/1900',
		EditASUserIdent = 0,
		LockSessionIdent = 0,
		LockTime = '1/1/1900'
	FROM
		MessageTemplate MT WITH (NOLOCK),
		#tmpEntityProjectEntity tEPE WITH (NOLOCK)
		INNER JOIN
		EntityEmail EE WITH (NOLOCK)
			ON EE.EntityIdent = tEPE.EntityIdent
	WHERE
		MT.Ident = @intMessageTemplateRegistrationIdent
		AND (tEPE.Registered = 0 AND tEPE.NotRegisteredButHasEmail = 1)
		AND tEPE.PublicResource = 1
		AND EE.Active = 1

	-- the insert records are outputed to @InsertedMessageQueue
	-- join back to that table to insert the necessary child record for the matching queue record
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
		RecordIdent = tEPE.EntityIdent,
		MessageQueueIdent = IMQ.Ident,
		MessageTemplateIdent = IMQ.MessageTemplateIdent,
		MessageGUID = tEPE.MessageGUID,
		ExpirationDateTime = DATEADD(HH,MT.MessageExpirationHours, @dteGetDate),
		AddDateTime = @dteGetDate,
		Active = 1
	FROM
		@InsertedMessageQueue IMQ
		INNER JOIN
		#tmpEntityProjectEntity tEPE WITH (NOLOCK)
			ON tEPE.EntityIdent = IMQ.ASUserIdent
		INNER JOIN
		MessageTemplate MT WITH (NOLOCK)
			ON MT.Ident = IMQ.MessageTemplateIdent

	-- Return Counts = Users who were sent a registration email
	SELECT
		@intSentRegistrationEmail = COUNT(*)
	FROM
		#tmpEntityProjectEntity WITH (NOLOCK)
	WHERE
		Registered = 0
		AND NotRegisteredButHasEmail = 1
		AND PublicResource = 1

	-- Return Counts = Users who were sent a project notification email
	SELECT
		@intSentProjectNotification = COUNT(*)
	FROM
		#tmpEntityProjectEntity WITH (NOLOCK)
	WHERE
		Registered = 1
		AND MarkedAsNotify = 1
		AND PublicResource = 1

	-- Return Counts = Users who are not registered and no email on file
	SELECT
		@intNotRegisteredByNoEmail = COUNT(*)
	FROM
		#tmpEntityProjectEntity WITH (NOLOCK)
	WHERE
		Registered = 0
		AND NotRegisteredButHasEmail = 0
		AND PublicResource = 1

	-- Return Counts = Users who are registered but email is not set to notify
	SELECT
		@intRegisteredByMarkedAsNonNotify = COUNT(*)
	FROM
		#tmpEntityProjectEntity WITH (NOLOCK)
	WHERE
		Registered = 1
		AND MarkedAsNotify = 0
		AND PublicResource = 1

	-- Return Counts = Private Resources
	SELECT
		@intPrivateResources = COUNT(*)
	FROM
		#tmpEntityProjectEntity WITH (NOLOCK)
	WHERE
		PublicResource = 0

	-- for the users who received an email, then mark their project notification time
	UPDATE
		EPE
	SET
		LastEmailNotificationSent = @dteGetDate
	FROM
		EntityProjectEntity EPE WITH (NOLOCK)
		INNER JOIN
		#tmpEntityProjectEntity tEPE WITH (NOLOCK)
			ON tEPE.EntityIdent = EPE.EntityIdent
	WHERE
		(tEPE.Registered = 0 AND tEPE.NotRegisteredButHasEmail = 1)
		OR (tEPE.Registered = 1 AND tEPE.MarkedAsNotify = 1)

	SELECT
		@intSentRegistrationEmail as [SentRegistrationEmail],
		@intSentProjectNotification as [SentProjectNotification],
		@intNotRegisteredByNoEmail as [NotRegisteredByNoEmail],
		@intRegisteredByMarkedAsNonNotify as [RegisteredByMarkedAsNonNotify],
		@intPrivateResources as [PrivateResources]

	DROP TABLE #tmpEntityProjectEntity

GO

-- exec uspAddMessageQueueForProjectNotification 306485, 306485, 10062