IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityExternalLogin') 
	and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspAddEntityExternalLogin
GO

/* uspAddEntityExternalLogin
 *
 *	Adds an Entity's External Login
 *
 */
CREATE PROCEDURE uspAddEntityExternalLogin

	@bntEntityIdent BIGINT,
	@bntAddASUserIdent BIGINT,
	@nvrExternalSource NVARCHAR(MAX),
	@nvrExternalNameIdentifier NVARCHAR(MAX),
	@nvrExternalEmailAddress NVARCHAR(MAX)
	
AS

	SET NOCOUNT ON

	UPDATE
		Entity
	SET
		Username = @nvrExternalSource + ':' + @nvrExternalNameIdentifier,
		ExternalLogin = 1,
		EditASUserIdent = @bntAddASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()
	WHERE
		Ident = @bntEntityIdent

	INSERT INTO EntityExternalLogin(
		EntityIdent,
		ExternalSource,
		ExternalNameIdentifier,
		ExternalEmailAddress,
		Active,
		AddDateTime,
		AddASUserIdent,
		EditDateTime,
		EditASUserIdent
	)
	SELECT
		EntityIdent = @bntEntityIdent,
		ExternalSource = @nvrExternalSource,
		ExternalNameIdentifier = @nvrExternalNameIdentifier,
		ExternalEmailAddress = @nvrExternalEmailAddress,
		Active = 1,
		AddDateTime = dbo.ufnGetMyDate(),
		AddASUserIdent = @bntAddASUserIdent,
		EditDateTime = '1/1/1900',
		EditASUserIdent = 0

	SELECT SCOPE_IDENTITY() AS [Ident]

GO