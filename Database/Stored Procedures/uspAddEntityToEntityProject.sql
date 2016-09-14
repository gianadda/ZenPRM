IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityToEntityProject') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntityToEntityProject
 GO
/* uspAddEntityToEntityProject 506, 230745, 4, 506
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspAddEntityToEntityProject]

	@intFromEntityIdent BIGINT = 0, 
	@intToEntityIdent BIGINT = 0, 
	@intEntityProjectIdent BIGINT = 0, 
	@intAddASUserIdent BIGINT = 0

AS

	SET NOCOUNT ON


	--Let's verify that this project belongs to the from entity
	DECLARE @bitProjectBelongsToFromEntity BIT
	DECLARE @intWasThisEntityAlreadyAttachedInThePastIdent BIGINT
	DECLARE @intIdent BIGINT

	SET @bitProjectBelongsToFromEntity = 0
	SET @intWasThisEntityAlreadyAttachedInThePastIdent = 0

	SELECT 
		@bitProjectBelongsToFromEntity = 1
	FROM
		EntityProject EP WITH (NOLOCK)
	WHERE 
		EP.Ident = @intEntityProjectIdent
		AND EP.EntityIdent = @intFromEntityIdent

	SELECT TOP 1
		@intWasThisEntityAlreadyAttachedInThePastIdent = EPE.Ident
	FROM
		EntityProject EP WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EP.Ident = EPE.EntityProjectIdent
	WHERE
		EP.Ident = @intEntityProjectIdent
		AND EP.EntityIdent = @intFromEntityIdent
		AND EPE.EntityIdent = @intToEntityIdent
	ORDER BY 
		EPE.Ident DESC

	--If it wasn't already connected, add it
	INSERT INTO EntityProjectEntity (
		EntityProjectIdent,
		EntityIdent,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT 
		EntityProjectIdent = @intEntityProjectIdent,
		EntityIdent = @intToEntityIdent,
		AddASUserIdent = @intAddASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1
	WHERE 
		@bitProjectBelongsToFromEntity = 1
		AND @intWasThisEntityAlreadyAttachedInThePastIdent = 0

	SET @intIdent = SCOPE_IDENTITY()

	--if it was already connected, reactivate it.
	UPDATE EPE
	SET 
		Active = 1,
		EditASUserIdent = @intAddASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()
	FROM
		EntityProjectEntity EPE
	WHERE
		EPE.Ident = @intWasThisEntityAlreadyAttachedInThePastIdent
		
	SELECT 
		@intIdent = SCOPE_IDENTITY()
	WHERE 
		@intIdent = 0



	SELECT 
		@intIdent As [Ident]



GO

