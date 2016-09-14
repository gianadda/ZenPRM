IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspSaveEntityProjectEntityAnswerFromEntityFileRepository') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspSaveEntityProjectEntityAnswerFromEntityFileRepository
 GO
/* uspSaveEntityProjectEntityAnswerFromEntityFileRepository
 *
 *
 * This mimics uspSaveEntityProjectEntityAnswerValue except were saving from our file repo
 *
*/
CREATE PROCEDURE uspSaveEntityProjectEntityAnswerFromEntityFileRepository

	@intEntityProjectRequirementIdent BIGINT, 
	@intFromEntityProjectEntityAnswerIdent BIGINT,
	@intEntityIdent BIGINT, 
	@intASUserIdent BIGINT

AS

	SET NOCOUNT ON

	DECLARE @sdtGetDate AS SMALLDATETIME,
			@intToEntityProjectEntityAnswerIdent BIGINT,
			@intEntityProjectEntityIdent BIGINT,
			@intEntityProjectIdent BIGINT

	SET @sdtGetDate = dbo.ufnGetMyDate()
	SET @intToEntityProjectEntityAnswerIdent = 0
	SET @intEntityProjectEntityIdent = 0
	SET @intEntityProjectIdent = 0

	-- BEGIN VERIFYING @intEntityProjectEntityIdent

	SELECT 
		@intEntityProjectEntityIdent = EPE.Ident,
		@intEntityProjectIdent = EP.Ident
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

	-- END VERIFYING @intEntityProjectEntityIdent

	-- BEGIN VERIFYING @intToEntityProjectEntityAnswerIdent

	--clear out this answer, well add a new one so the document ident is unique
	UPDATE A
	SET 
		Active = 0,
		EditASUserIdent = @intASUserIdent,
		EditDateTime =  @sdtGetDate
	FROM
		EntityProjectEntityAnswer A WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntity E WITH (NOLOCK)
			ON E.Ident = A.EntityProjectEntityIdent
	WHERE 
		A.EntityProjectRequirementIdent = @intEntityProjectRequirementIdent
		AND E.EntityIdent = @intEntityIdent
		AND E.Active = 1

	--clear out this answer value, well add a new one so the document ident is unique
	UPDATE V
	SET 
		Active = 0,
		EditASUserIdent = @intASUserIdent,
		EditDateTime =  @sdtGetDate
	FROM
		EntityProjectEntityAnswerValue V
		INNER JOIN
		EntityProjectEntityAnswer A WITH (NOLOCK)
			ON A.Ident = V.EntityProjectEntityAnswerIdent
		INNER JOIN
		EntityProjectEntity E WITH (NOLOCK)
			ON E.Ident = A.EntityProjectEntityIdent
	WHERE 
		A.EntityProjectRequirementIdent = @intEntityProjectRequirementIdent
		AND E.EntityIdent = @intEntityIdent
		AND E.Active = 1
		AND V.Active = 1

	--Add in the new answer record
	INSERT INTO EntityProjectEntityAnswer (
		EntityProjectEntityIdent,
		EntityProjectRequirementIdent,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active,
		ToDoGenerated,
		ToDoGeneratedDateTime
	)
	SELECT 
		EntityProjectEntityIdent = @intEntityProjectEntityIdent,
		EntityProjectRequirementIdent = @intEntityProjectRequirementIdent,
		AddASUserIdent = @intASUserIdent,
		AddDateTime = @sdtGetDate, 
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900', 
		Active = 1,
		ToDoGenerated = 0,
		ToDoGeneratedDateTime = '1/1/1900'

	SET @intToEntityProjectEntityAnswerIdent = SCOPE_IDENTITY()

	-- END VERIFYING @intToEntityProjectEntityAnswerIdent

	INSERT INTO EntityProjectEntityAnswerValue (
		EntityProjectEntityAnswerIdent,
		Name1,
		Value1,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT 
		EntityProjectEntityAnswerIdent = @intToEntityProjectEntityAnswerIdent,
		Name1 = EPEAV.Name1,
		Value1 = EPEAV.Value1,
		AddASUserIdent = @intASUserIdent,
		AddDateTime = @sdtGetDate, 
		EditASUserIdent = @intASUserIdent,
		EditDateTime = @sdtGetDate, 
		Active = 1
	FROM
		EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntityAnswer EPEA WITH (NOLOCK)
			ON EPEA.Ident = EPEAV.EntityProjectEntityAnswerIdent
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.Ident = EPEA.EntityProjectEntityIdent
	WHERE
		EPEAV.EntityProjectEntityAnswerIdent = @intFromEntityProjectEntityAnswerIdent
		AND EPE.Active = 1
		AND EPE.EntityIdent = @intEntityIdent

	SELECT 
		@intToEntityProjectEntityAnswerIdent as [Ident],
		@intEntityProjectIdent as [ProjectIdent]

GO