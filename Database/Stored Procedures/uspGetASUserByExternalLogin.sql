IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetASUserByExternalLogin') 
	and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetASUserByExternalLogin
GO

/* uspGetASUserByExternalLogin
 *
 *	Gets a user by external source and nameidentifier
 *
 */
CREATE PROCEDURE uspGetASUserByExternalLogin

	@nvrExternalSource NVARCHAR(MAX),
	@nvrExternalNameIdentifier NVARCHAR(MAX),
	@nvrExternalEmailAddress NVARCHAR(MAX)
	
AS

	SET NOCOUNT ON

	DECLARE @intASUserIdent BIGINT
	SET @intASUserIdent = 0

	SELECT
		@intASUserIdent = AU.Ident
	FROM
		ASUser AU WITH (NOLOCK)
		INNER JOIN
		EntityExternalLogin EEL WITH (NOLOCK)
			ON EEL.EntityIdent = AU.Ident
	WHERE
		EEL.ExternalSource = @nvrExternalSource
		AND EEL.ExternalNameIdentifier = @nvrExternalNameIdentifier
		AND EEL.ExternalEmailAddress = @nvrExternalEmailAddress
		AND EEL.Active = 1
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
		AND AU.ExternalLogin = 1

GO