IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityEmail') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntityEmail
 GO
/* uspAddEntityEmail
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspAddEntityEmail]

	@intEntityIdent BIGINT = 0, 
	@nvrEmail NVARCHAR(MAX) = '', 
	@bitNotify BIT = False, 
	@bitVerified BIT = False, 
	@intVerifiedASUserIdent BIGINT = 0, 
	@intAddASUserIdent BIGINT = 0, 
	@bitActive BIT = False,
	@bitSuppressOutput BIT = 0

AS

	SET NOCOUNT ON

	DECLARE @bitAlreadyRegistered BIT
	DECLARE @intIdent BIGINT

	SET @bitAlreadyRegistered = 0

	-- if the username is already set, then they have completed registration
	SELECT
		@bitAlreadyRegistered = Registered
	FROM
		Entity E WITH (NOLOCK)
	WHERE
		E.Ident = @intEntityIdent

	INSERT INTO EntityEmail (
		EntityIdent, 
		Email, 
		Notify, 
		Verified, 
		VerifiedASUserIdent, 
		VerifiedDateTime, 
		AddASUserIdent, 
		AddDateTime, 
		EditASUserIdent, 
		EditDateTime, 
		Active
	) 
	SELECT 
		EntityIdent = @intEntityIdent, 
		Email = @nvrEmail, 
		Notify = @bitNotify, 
		Verified = @bitVerified, 
		VerifiedASUserIdent = @intVerifiedASUserIdent, 
		VerifiedDateTime = CASE @bitVerified 
							WHEN 1 THEN dbo.ufnGetMyDate()
							ELSE '1/1/1900'
						   END, 
		AddASUserIdent = @intAddASUserIdent, 
		AddDateTime = dbo.ufnGetMyDate(), 
		EditASUserIdent = 0, 
		EditDateTime = '1/1/1900', 
		Active = @bitActive
	WHERE
		@bitAlreadyRegistered = 0 OR
		(@intEntityIdent = @intAddASUserIdent) -- if the resource is registered, then dont let someone else update their emails

	IF @bitSuppressOutput = 0
	BEGIN 

		SET @intIdent = SCOPE_IDENTITY()
		
		SELECT 
			@intIdent as [Ident],
			@bitAlreadyRegistered as [AlreadyRegistered]
		WHERE
			@intIdent IS NOT NULL
	END

GO