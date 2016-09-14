IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspEditEntityUsernamePasswordByIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspEditEntityUsernamePasswordByIdent
GO
/********************************************************
 * This procedure will update an entity account to have the ability to login													
 *
 *	uspEditEntityUsernamePasswordByIdent 
 *
 ********************************************************/
 
CREATE PROCEDURE uspEditEntityUsernamePasswordByIdent

	@intIdent BIGINT,
	@nvrUsername NVARCHAR(75),
	@nvrPassword NVARCHAR(MAX),
	@nvrPasswordSalt NVARCHAR(200),
	@nvrMessageQueueGUID NVARCHAR(MAX)

AS
	
	DECLARE @bntActivityTypeRegisterIdent BIGINT
	DECLARE @nvrAuditDescription NVARCHAR(MAX)

	SET @bntActivityTypeRegisterIdent = dbo.ufnActivityTypeCompletedRegistration()

	SELECT
		@nvrAuditDescription = REPLACE(AT.Desc1,'@@Name',E.FullName)
	FROM
		ActivityType AT WITH (NOLOCK)
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = @intIdent
	WHERE
		AT.Ident = @bntActivityTypeRegisterIdent

	UPDATE
		Entity
	SET
		Username = @nvrUsername,
		MustChangePassword = 0,
		Password1 = @nvrPassword,
		PasswordSalt = @nvrPasswordSalt,
		LastPasswordChangedDate = dbo.ufnGetMyDate(),
		ExternalLogin = 0 -- ensure to mark them as a local user
	WHERE
		Ident = @intIdent

	-- audit entity registration process 
	EXEC uspAddASUserActivity @intIdent, @bntActivityTypeRegisterIdent, @nvrAuditDescription, '',@intIdent,0

	-- deactivate the registration GUID
	EXEC uspDeactivateMessageQueueGUID @nvrMessageQueueGUID

	-- new business rule, when registration is complete, mark emails on file as verified (and notify)
	UPDATE
		EntityEmail
	SET
		Verified = 1,
		VerifiedASUserIdent = @intIdent,
		VerifiedDateTime = dbo.ufnGetMyDate(),
		Notify = 1
	WHERE
		EntityIdent = @intIdent
		AND Active = 1
	
	SELECT @intIdent as [EntityIdent]

GO