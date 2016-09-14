IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspEditASUserIsLockedByIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspEditASUserIsLockedByIdent
GO

/* uspEditASUserIsLockedByIdent
 *
 *	TJF - Edit the IsLocked bit on ASUser table
 *
 */

CREATE PROCEDURE uspEditASUserIsLockedByIdent

	@bntIdent BIGINT,
	@bitLock BIT

AS
	
	SET NOCOUNT ON

	UPDATE Entity
	SET 
		IsLocked = @bitLock
	WHERE
		Ident = @bntIdent

	SELECT 1

GO