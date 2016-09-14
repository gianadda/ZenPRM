IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspDeleteEntityProjectMeasureByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspDeleteEntityProjectMeasureByIdent
 GO
/* uspDeleteEntityProjectMeasureByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE uspDeleteEntityProjectMeasureByIdent

	@intIdent BIGINT,
	@intEntityIdent BIGINT,
	@intEditASUserIdent BIGINT

AS

	SET NOCOUNT ON

	DECLARE @intEntityProjectIdent BIGINT
	
	SET @intEntityProjectIdent = 0

	SELECT
		@intEntityProjectIdent = EP.Ident
	FROM
		EntityProjectMeasure EPM WITH (NOLOCK)
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.Ident = EPM.Question1EntityProjectRequirementIdent
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = EPR.EntityProjectIdent
	WHERE
		EPM.Ident = @intIdent
		AND EP.EntityIdent = @intEntityIdent

	-- if they dont have access to this project, dont let them delete the measure
	IF (@intEntityProjectIdent = 0)
		BEGIN
			SET @intIdent = 0
		END

	UPDATE EntityProjectMeasure
	SET 
		Active = 0,
		EditASUserIdent = @intEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()
	WHERE
		@intIdent > 0
		AND Ident = @intIdent
		
	SELECT @intIdent as [Ident]

GO