IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspCopyEntityProjectRequirement') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspCopyEntityProjectRequirement
 GO
/* uspCopyEntityProjectRequirement
 *
 *
 *
 *
*/
CREATE PROCEDURE uspCopyEntityProjectRequirement

	@bntEntityProjectRequirementIdent BIGINT,
	@bntNewEntityProjectIdent BIGINT,
	@bitIncludeAnswers BIT,
	@bitRemoveOldQuestion BIT,
	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT

AS

	SET NOCOUNT ON

	DECLARE @bitAllowCopy BIT
	DECLARE @bntNewIdent BIGINT
	
	DECLARE @bntQuestionEntityIdent BIGINT
	DECLARE @nvrName1 NVARCHAR(MAX)
	DECLARE @nvrValue1 NVARCHAR(MAX)

	SET @bitAllowCopy = 0

	SELECT
		@bitAllowCopy = 1
	FROM
		EntityProjectRequirement EPR WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = EPR.EntityProjectIdent
	WHERE
		EPR.Ident = @bntEntityProjectRequirementIdent
		AND EPR.Active = 1
		AND EP.EntityIdent = @bntEntityIdent -- make sure they have permission to this project

	-- Copy the question directly, if the copy is allowed
	INSERT INTO EntityProjectRequirement(
		EntityProjectIdent,
		RequirementTypeIdent,
		Label,
		Desc1,
		PlaceholderText,
		HelpText,
		Options,
		SortOrder,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active,
		CreateToDoUponCompletion,
		ToDoTitle,
		ToDoDesc1,
		ToDoAssigneeEntityIdent,
		ToDoDueDateNoOfDays
	)
	SELECT
		EntityProjectIdent = @bntNewEntityProjectIdent,
		RequirementTypeIdent = EPR.RequirementTypeIdent,
		Label = EPR.Label,
		Desc1 = EPR.Desc1,
		PlaceholderText = EPR.PlaceholderText,
		HelpText = EPR.HelpText,
		Options = EPR.Options,
		SortOrder = EPR.SortOrder,
		AddASUserIdent = @bntASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1,
		CreateToDoUponCompletion = 0,
		ToDoTitle = '',
		ToDoDesc1 = '',
		ToDoAssigneeEntityIdent = 0,
		ToDoDueDateNoOfDays = 0
	FROM
		EntityProjectRequirement EPR WITH (NOLOCK)
	WHERE
		@bitAllowCopy = 1
		AND EPR.Ident = @bntEntityProjectRequirementIdent

	SET @bntNewIdent = SCOPE_IDENTITY()

	DECLARE import_cursor CURSOR FOR

		SELECT
			EPE.EntityIdent,
			V.Name1,
			V.Value1
		FROM
			EntityProjectRequirement EPR WITH (NOLOCK)
			INNER JOIN
			EntityProjectEntityAnswer A WITH (NOLOCK)
				ON A.EntityProjectRequirementIdent = EPR.Ident
			INNER JOIN
			EntityProjectEntity EPE WITH (NOLOCK)
				ON EPE.Ident = A.EntityProjectEntityIdent
			INNER JOIN
			EntityProjectEntityAnswerValue V WITH (NOLOCK)
				ON V.EntityProjectEntityAnswerIdent = A.Ident
		WHERE
			@bitAllowCopy = 1
			AND @bitIncludeAnswers = 1
			AND @bntNewIdent > 0
			AND EPR.Ident = @bntEntityProjectRequirementIdent
			AND A.Active = 1
			AND EPE.Active = 1
			AND V.Active = 1

		OPEN import_cursor

		FETCH NEXT FROM import_cursor
		INTO @bntQuestionEntityIdent, @nvrName1, @nvrValue1

		WHILE @@FETCH_STATUS = 0
		BEGIN

			EXEC uspSaveEntityProjectEntityAnswerValue

					@intEntityProjectRequirementIdent = @bntNewIdent, 
					@intEntityIdent = @bntQuestionEntityIdent, 
					@vcrName1 = @nvrName1, 
					@nvrValue1 = @nvrValue1,
					@intASUserIdent = @bntASUserIdent,
					@bitSuppressOutput = 1


			FETCH NEXT FROM import_cursor
			INTO @bntQuestionEntityIdent, @nvrName1, @nvrValue1

		END

	CLOSE import_cursor
	DEALLOCATE import_cursor


	-- if the copy was allowed and the add was successful, and we want to delete the old question,
	-- then do so now
	UPDATE
		EntityProjectRequirement
	SET
		Active = 0,
		EditDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = @bntASUserIdent
	WHERE
		@bitAllowCopy = 1
		AND @bitRemoveOldQuestion = 1
		AND @bntNewIdent > 0
		AND Ident = @bntEntityProjectRequirementIdent

	SELECT @bntNewIdent as [Ident]

GO