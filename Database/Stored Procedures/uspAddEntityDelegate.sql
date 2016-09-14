IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityDelegate') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntityDelegate
 GO
/* uspAddEntityDelegate
 *
 * Adds an EntityConnection with the appropriate connection type for delegation
 *
 *
*/
CREATE PROCEDURE uspAddEntityDelegate

	@intEntityIdent BIGINT,
	@intEntityDelegateIdent BIGINT,
	@bitSuppressOutput BIT = 0

AS

	SET NOCOUNT ON

	DECLARE @intConnectionTypeDelegateIdent BIGINT,
			@intIdent BIGINT

	SET @intConnectionTypeDelegateIdent = 0
	SET @intIdent = 0

	SELECT 
		@intConnectionTypeDelegateIdent = CT.Ident
	FROM 
		ConnectionType CT WITH (NOLOCK)
		INNER JOIN
		Entity fromE WITH (NOLOCK)
			ON CT.FromEntityTypeIdent = fromE.EntityTypeIdent
		INNER JOIN
		Entity toE WITH (NOLOCK)
			ON CT.ToEntityTypeIdent = toE.EntityTypeIdent
	WHERE 
		fromE.Ident = @intEntityIdent
		AND toE.Ident = @intEntityDelegateIdent
		AND CT.Delegate = 1

	INSERT INTO EntityConnection (
		ConnectionTypeIdent, 
		FromEntityIdent, 
		ToEntityIdent, 
		AddASUserIdent, 
		AddDateTime, 
		EditASUserIdent, 
		EditDateTime, 
		Active
	) 
	SELECT 
		ConnectionTypeIdent = @intConnectionTypeDelegateIdent, 
		FromEntityIdent = @intEntityIdent, 
		ToEntityIdent = @intEntityDelegateIdent, 
		AddASUserIdent = @intEntityIdent, 
		AddDateTime = dbo.ufnGetMyDate(), 
		EditASUserIdent = 0, 
		EditDateTime = '1/1/1900', 
		Active = 1
	WHERE 
		@intConnectionTypeDelegateIdent > 0

	--Only select ScopeIdentity if we actually inserted.
	SELECT 
		@intIdent = SCOPE_IDENTITY()
	WHERE 
		@intConnectionTypeDelegateIdent > 0

	IF @bitSuppressOutput = 0
	BEGIN 
		SELECT @intIdent as [Ident]
	END

GO