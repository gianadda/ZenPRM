IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspLockMessageQueueByMessageTypeIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspLockMessageQueueByMessageTypeIdent
GO
/* uspLockMessageQueueByMessageTypeIdent
 *
 *	Locks records in the MessageQueue for processing based on MessageTypeIdent
 *
 */
CREATE PROCEDURE uspLockMessageQueueByMessageTypeIdent

	@intMessageTypeIdent BIGINT,
	@intLockSessionIdent BIGINT

AS

	SET NOCOUNT ON

	DECLARE @dteGetDate DATETIME,
			@intLockRecordCount INT

	SET @dteGetDate = dbo.ufnGetMyDate()

	SELECT
		@intLockRecordCount = Value1
	FROM
		ASApplicationVariable ASA WITH (NOLOCK)
	WHERE
		ASA.Name1 = 'MessageQueueLockRecordCount'

	UPDATE TOP (@intLockRecordCount) -- TO DO , determine how to lock in order
		MessageQueue
	SET
		LockTime = @dteGetDate,
		LockSessionIdent = @intLockSessionIdent
	WHERE
		LockSessionIdent = 0
		AND MessageTypeIdent = @intMessageTypeIdent
		AND MessageSent = 0
		AND Active = 1

	SELECT
		MQ.Ident,
		MQ.ASUserIdent,
		MQ.MessageTypeIdent,
		MQ.MessageTemplateIdent,
		MQ.MessageSent,
		MQ.LastAttemptedDateTime,
		MQ.NumberOfAttempts,
		MQ.ToAddress,
		MQ.CCAddress,
		MQ.BCCAddress,
		MQ.FromAddress,
		MQ.FromDisplayName,
		MQ.ReplyToAddress,
		MQ.MessageSubject,
		MQ.MessageBody,
		MQ.SendAsHTML,
		MQ.Active,
		MQ.AddDateTime,
		MQ.AddASUserIdent,
		MQ.EditDateTime,
		MQ.EditASUserIdent,
		MQ.LockSessionIdent,
		MQ.LockTime,
		MT.ServerName,
		MT.ServerUsername,
		MT.ServerPassword,
		MT.ServerPort,
		MT.ServerTimeout
	FROM
		MessageQueue MQ WITH (NOLOCK)
		INNER JOIN
		MessageType MT WITH (NOLOCK)
			ON MT.Ident = MQ.MessageTypeIdent
	WHERE
		MQ.LockSessionIdent = @intLockSessionIdent
		AND MQ.MessageTypeIdent = @intMessageTypeIdent
		AND MQ.MessageSent = 0
		AND MQ.Active = 1
	ORDER BY
		MQ.AddDateTime ASC

GO