IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityConnection') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntityConnection
 GO
/* uspAddEntityConnection
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspAddEntityConnection]

	@intConnectionTypeIdent BIGINT = 0, 
	@intFromEntityIdent BIGINT = 0, 
	@intToEntityIdent BIGINT = 0, 
	@intAddASUserIdent BIGINT = 0, 
	@bitActive BIT = False,
	@bitSuppressOutput BIT = 0

AS

	SET NOCOUNT ON

	DECLARE @bitIsValidConnection BIT
	DECLARE @intIdent BIGINT

	SET @bitIsValidConnection = 0
	SET @intIdent = 0

	SELECT 
		@bitIsValidConnection = 1
	FROM
		ConnectionType CT WITH (NOLOCK)
		INNER JOIN
		Entity tE WITH (NOLOCK)
			ON tE.EntityTypeIdent = CT.ToEntityTypeIdent
		INNER JOIN
		Entity fE WITH (NOLOCK)
			ON fE.EntityTypeIdent = CT.FromEntityTypeIdent
	WHERE 
		tE.Ident = @intToEntityIdent
		AND fE.Ident = @intFromEntityIdent
		AND CT.Ident = @intConnectionTypeIdent
		AND tE.Active = 1
		AND fE.Active = 1
		AND CT.Active = 1

	SELECT 
		@bitIsValidConnection = 1
	FROM
		ConnectionType CT WITH (NOLOCK)
		INNER JOIN
		Entity tE WITH (NOLOCK)
			ON tE.EntityTypeIdent = CT.ToEntityTypeIdent
		INNER JOIN
		Entity fE WITH (NOLOCK)
			ON fE.EntityTypeIdent = CT.FromEntityTypeIdent
	WHERE 
		tE.Ident = @intFromEntityIdent
		AND fE.Ident = @intToEntityIdent
		AND CT.Ident = @intConnectionTypeIdent
		AND tE.Active = 1
		AND fE.Active = 1
		AND CT.Active = 1



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
		ConnectionTypeIdent = @intConnectionTypeIdent, 
		FromEntityIdent = @intFromEntityIdent, 
		ToEntityIdent = @intToEntityIdent, 
		AddASUserIdent = @intAddASUserIdent, 
		AddDateTime = dbo.ufnGetMyDate(), 
		EditASUserIdent = 0, 
		EditDateTime = '1/1/1900', 
		Active = @bitActive
	WHERE 
		@bitIsValidConnection = 1

	--Only select ScopeIdentity if we actually inserted.
	SELECT 
		@intIdent = SCOPE_IDENTITY()
	WHERE 
		@bitIsValidConnection = 1
		
	IF @bitSuppressOutput = 0
	BEGIN 
		SELECT @intIdent as [Ident]
	END

GO