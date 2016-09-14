IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspRemoveASUserAccess') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspRemoveASUserAccess
 GO
/* uspRemoveASUserAccess
 *
 *
 * Removes a users ability to log into ZenPRM
 *
*/
CREATE PROCEDURE uspRemoveASUserAccess

	@intEntityIdent BIGINT, 
	@intEditASUserIdent BIGINT

AS

	SET NOCOUNT ON

	UPDATE
		Entity
	SET
		Username = '',
		Password1 = '',
		PasswordSalt = '',
		MustChangePassword = 0,
		ExternalLogin = 0,
		SystemRoleIdent = 2, -- Entity
		Customer = 0,
		FailedLoginCount = 0,
		LockedTime = '1/1/1900',
		IsLocked = 0,
		EditASUserIdent = @intEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()
	WHERE
		Ident = @intEntityIdent

GO