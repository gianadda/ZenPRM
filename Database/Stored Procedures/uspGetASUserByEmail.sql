IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetASUserByEmail') 
	and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetASUserByEmail
GO

/* uspGetASUserByEmail
 *
 *	Gets a user by email address
 *
 */
CREATE PROCEDURE uspGetASUserByEmail

	@nvrEmail NVARCHAR(MAX)
	
AS

	SET NOCOUNT ON

	DECLARE @bntEntityIdent BIGINT

	SELECT
		@bntEntityIdent = EE.EntityIdent
	FROM
		EntityEmail EE WITH (NOLOCK)
		INNER JOIN
		ASUser U WITH (NOLOCK)
			ON U.Ident = EE.EntityIdent
	WHERE
		EE.Email = @nvrEmail
		AND EE.Active = 1

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
		AU.Active
	FROM
		ASUser AU WITH (NOLOCK)
	WHERE
		AU.Ident = @bntEntityIdent

	SELECT
		Ident,
		EntityIdent,
		ExternalSource,
		ExternalNameIdentifier,
		ExternalEmailAddress
	FROM
		EntityExternalLogin WITH (NOLOCK)
	WHERE
		EntityIdent = @bntEntityIdent
		AND Active = 1

GO