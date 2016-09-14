IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetASUserByUserName') 
	and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetASUserByUserName
GO

/* uspGetASUserByUserName
 *
 *	Gets a user by username (password match in VB)
 *
 */
CREATE PROCEDURE uspGetASUserByUserName

	@vcrUserName NVARCHAR(75)

AS

	SET NOCOUNT ON

	DECLARE @intASUserIdent BIGINT
	SET @intASUserIdent = 0

	SELECT
		@intASUserIdent = AU.Ident
	FROM
		ASUser AU WITH (NOLOCK)
	WHERE
		AU.UserName = @vcrUserName	
		AND AU.Active = 1

	SELECT
		AU.Ident,
		AU.MustChangePassword,
		AU.SystemRoleIdent,
		AU.FullName,
		AU.Password1,
		AU.PasswordSalt,
		AU.LastPasswordChangedDate,
		AU.FailedLoginCount,
		AU.LastLoginAttempted,
		AU.LastSuccessfulLogin,
		AU.LockedTime,
		AU.IsLocked,
		AU.Customer,
		AU.Active
	FROM
		ASUser AU WITH (NOLOCK)
	WHERE
		AU.Ident = @intASUserIdent
		AND AU.ExternalLogin = 0 -- dont allow external logins through our existing login process

GO