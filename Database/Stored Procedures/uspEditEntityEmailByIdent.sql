IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspEditEntityEmailByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspEditEntityEmailByIdent
 GO
/* uspEditEntityEmailByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspEditEntityEmailByIdent]

	@intIdent BIGINT, 
	@intEntityIdent BIGINT, 
	@nvrEmail NVARCHAR(MAX), 
	@bitNotify BIT, 
	@bitVerified BIT, 
	@intVerifiedASUserIdent BIGINT, 
	@intEditASUserIdent BIGINT, 
	@sdtEditDateTime SMALLDATETIME, 
	@bitActive BIT

AS

	DECLARE @bitAlreadyVerified BIT 
	DECLARE @bitRegistered BIT
	DECLARE @bitUpdateComplete BIT

	SET @bitAlreadyVerified = 0
	SET @bitUpdateComplete = 0

	SELECT
		@bitRegistered = Registered
	FROM
		Entity (NOLOCK)
	WHERE
		Ident = @intEntityIdent

	SELECT 
		@bitAlreadyVerified = Verified
	FROM
		EntityEmail EE WITH (NOLOCK)
	WHERE
		Ident = @intIdent

	SET NOCOUNT ON

	UPDATE EntityEmail
	SET 
		EntityIdent = @intEntityIdent, 
		Email = @nvrEmail, 
		Notify = @bitNotify, 
		EditASUserIdent = @intEditASUserIdent, 
		EditDateTime = COALESCE(@sdtEditDateTime,EditDateTime), 
		Active = @bitActive,
		@bitUpdateComplete = 1
	WHERE
		Ident = @intIdent
		AND (@bitRegistered = 0 OR
				@intEntityIdent = @intEditASUserIdent)

	UPDATE EntityEmail
	SET 
		Verified = @bitVerified, 
		VerifiedASUserIdent = @intVerifiedASUserIdent, 
		VerifiedDateTime = dbo.ufnGetMyDate()
	WHERE
		Ident = @intIdent
		AND @bitAlreadyVerified = 0
		AND @bitVerified = 1
		
	SELECT 
		@intIdent as [Ident]
	WHERE
		@bitUpdateComplete = 1

GO