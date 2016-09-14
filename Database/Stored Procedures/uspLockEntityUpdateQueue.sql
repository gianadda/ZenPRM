IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspLockEntityUpdateQueue') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspLockEntityUpdateQueue
GO
/* uspLockEntityUpdateQueue
 *
 *	Locks records in the EntityUpdateQueue table for processing
 *
 */
CREATE PROCEDURE uspLockEntityUpdateQueue

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

	UPDATE TOP (@intLockRecordCount) 
		EntityUpdateQueue
	SET
		LockTime = @dteGetDate,
		LockSessionIdent = @intLockSessionIdent
	WHERE
		LockSessionIdent = 0

	SELECT
		Ident,
		NPI,
		AddDateTime,
		LockTime,
		LockSessionIdent
	FROM
		EntityUpdateQueue WITH (NOLOCK)
	WHERE
		LockSessionIdent = @intLockSessionIdent

GO