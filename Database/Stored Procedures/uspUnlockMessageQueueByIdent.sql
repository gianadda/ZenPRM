IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspUnlockMessageQueueByIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspUnlockMessageQueueByIdent
GO
/* uspUnlockMessageQueueByIdent
 *
 *	Unlocks record in the MessageQueue by Ident and updates the Status
 *
 */
CREATE PROCEDURE uspUnlockMessageQueueByIdent

	@intIdent BIGINT,
	@bitSendSuccess BIT

AS

	SET NOCOUNT ON

	DECLARE @intMaxNumberOfAttempts INT

	UPDATE
		MessageQueue
	SET
		MessageSent = @bitSendSuccess,
		LastAttemptedDateTime = dbo.ufnGetMyDate(),
		NumberOfAttempts = NumberOfAttempts + 1,
		LockSessionIdent = 0,
		LockTime = '1/1/1900'
	WHERE
		Ident = @intIdent

	-- if we failed to send, then see if we hit our max, if so, then remove from the queue
	IF (@bitSendSuccess = 0)

		BEGIN

			SELECT
				@intMaxNumberOfAttempts = Value1
			FROM
				ASApplicationVariable WITH (NOLOCK)
			WHERE
				Name1 = 'MessageQueueMaxNumberOfAttempts'
				AND Active = 1

			UPDATE
				MessageQueue
			SET
				Active = 0
			WHERE
				Ident = @intIdent
				AND NumberOfAttempts = @intMaxNumberOfAttempts

		END

GO