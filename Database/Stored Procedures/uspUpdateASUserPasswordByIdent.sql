IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspUpdateASUserPasswordByIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspUpdateASUserPasswordByIdent
GO
/* uspUpdateASUserPasswordByIdent
 *
 *	Updates the ASUser record password and sets their account to not require password change
 *
 */
CREATE PROCEDURE uspUpdateASUserPasswordByIdent

	@intASUserIdent BIGINT,
	@vcrPassword1 NVARCHAR(MAX),
	@vcrPasswordSalt NVARCHAR(200)

AS

	SET NOCOUNT ON

	UPDATE
		Entity
	SET
		Password1 = @vcrPassword1,
		PasswordSalt = @vcrPasswordSalt,
		MustChangePassword = 0,
		LastPasswordChangedDate = dbo.ufnGetMyDate(),
		LockedTime = '1/1/1900'
	WHERE
		Ident = @intASUserIdent

	INSERT INTO ASUserActivity(
		ASUserIdent,
		ActivityTypeIdent,
		ActivityDateTime,
		ActivityDescription,
		ClientIPAddress,
		RecordIdent
	)
	SELECT
		ASUserIdent = @intASUserIdent,
		ActivityTypeIdent = AT.Ident,
		ActivityDateTime = dbo.ufnGetMyDate(),
		ActivityDescription = REPLACE(AT.Desc1,'@@Name', E.FullName),
		ClientIPAddress = '',
		RecordIdent = 0
	FROM
		ActivityType AT WITH (NOLOCK)
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = @intASUserIdent
	WHERE
		AT.Name1 = 'Change Password'

	SELECT @intASUserIdent as [Ident]

GO