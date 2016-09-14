IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspDeleteEntityEmailByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspDeleteEntityEmailByIdent
 GO
/* uspDeleteEntityEmailByIdent
 *
 * 'Only Allow a registered user to edit their email
 * 'Don't allow a registered user to delete ALL their emails
 *
*/
CREATE PROCEDURE uspDeleteEntityEmailByIdent

	@intIdent BIGINT,
	@intEditASUserIdent BIGINT,
	@sdtEditDateTime SMALLDATETIME

AS

	SET NOCOUNT ON

	DECLARE @bntEmailCountIdent BIGINT,
			@bntEntityIdent BIGINT,
			@bitRegistered BIT

	-- Get the Entity for this Email
	SELECT
		@bntEntityIdent = EntityIdent
	FROM
		EntityEmail WITH (NOLOCK)
	WHERE
		Ident = @intIdent

	-- determine if they are registered
	SELECT
		@bitRegistered = E.Registered
	FROM
		Entity E WITH (NOLOCK)
	WHERE
		E.Ident = @bntEntityIdent

	-- get this users email count
	SELECT
		@bntEmailCountIdent = COUNT(*)
	FROM
		EntityEmail WITH (NOLOCK)
	WHERE
		EntityIdent = @bntEntityIdent
		AND Active = 1	

	UPDATE EntityEmail
	SET 
		Active = 0,
		EditASUserIdent = @intEditASUserIdent,
		EditDateTime = @sdtEditDateTime
	WHERE
		Ident = @intIdent
		AND (@bitRegistered = 0 
			OR (@bntEntityIdent = @intEditASUserIdent AND @bntEmailCountIdent > 1))
		
	SELECT 
		@intIdent as [Ident]
	WHERE
		(@bitRegistered = 0 
		OR (@bntEntityIdent = @intEditASUserIdent AND @bntEmailCountIdent > 1))

GO