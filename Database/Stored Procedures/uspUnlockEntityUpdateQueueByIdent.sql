IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspUnlockEntityUpdateQueueByIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspUnlockEntityUpdateQueueByIdent
GO
/* uspUnlockEntityUpdateQueueByIdent
 *
 *	the process unlocks records by deleting them when complete (audit and history occurs within the ASUserActivity table)
 *
 */
CREATE PROCEDURE uspUnlockEntityUpdateQueueByIdent

	@bntIdent BIGINT

AS

	SET NOCOUNT ON

	DELETE
		EntityUpdateQueue
	WHERE
		Ident = @bntIdent

GO