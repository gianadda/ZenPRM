IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspClearEntityProjectEntityAnswerValue') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspClearEntityProjectEntityAnswerValue
 GO
/* uspClearEntityProjectEntityAnswerValue
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspClearEntityProjectEntityAnswerValue]

	@intEntityProjectRequirementIdent BIGINT = 0, 
	@intEntityIdent BIGINT = 0, 
	@intASUserIdent BIGINT = 0

AS

	SET NOCOUNT ON

	DECLARE @intEntityProjectEntityAnswerIdent AS BIGINT
	DECLARE @intEntityProjectEntityIdent AS BIGINT

	SET @intEntityProjectEntityAnswerIdent = 0
	SET @intEntityProjectEntityIdent = 0


	SELECT 
		@intEntityProjectEntityIdent = EPE.Ident
	FROM
		EntityProjectRequirement EPR WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EPR.EntityProjectIdent = EP.Ident
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityProjectIdent = EP.Ident
	WHERE 
		EPR.Ident = @intEntityProjectRequirementIdent
		AND EPE.EntityIdent = @intEntityIdent
		AND EPE.Active = 1

	SELECT 
		@intEntityProjectEntityAnswerIdent = Ident
	FROM
		EntityProjectEntityAnswer EPEA WITH (NOLOCK)
	WHERE 
		EPEA.EntityProjectRequirementIdent = @intEntityProjectRequirementIdent
		AND EPEA.EntityProjectEntityIdent = @intEntityProjectEntityIdent
		AND @intEntityProjectEntityIdent <> 0
		AND EPEA.Active = 1

	--Update it if it exists
	UPDATE EntityProjectEntityAnswer
	SET 
		Active = 0,
		EditASUserIdent = @intASUserIdent,
		EditDateTime =  dbo.ufnGetMyDate()
	WHERE 
		Ident = @intEntityProjectEntityAnswerIdent
		AND @intEntityProjectEntityAnswerIdent <> 0
	
	
	--Clear any old answers for this Answer/Name1 
	UPDATE EntityProjectEntityAnswerValue
	SET 
		Name1 = '', -- need to clear the actual answer so that the trigger works as designed for history logging
		Value1 = '', -- need to clear the actual answer so that the trigger works as designed for history logging
		EditASUserIdent = @intASUserIdent,
		EditDateTime =  dbo.ufnGetMyDate(),
		Active = 0
	WHERE 
		@intEntityProjectEntityAnswerIdent <> 0
		AND EntityProjectEntityAnswerIdent = @intEntityProjectEntityAnswerIdent

	SELECT @intEntityProjectEntityAnswerIdent as [Ident]

GO