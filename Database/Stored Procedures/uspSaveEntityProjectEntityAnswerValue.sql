IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspSaveEntityProjectEntityAnswerValue') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspSaveEntityProjectEntityAnswerValue
 GO
/* uspSaveEntityProjectEntityAnswerValue
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspSaveEntityProjectEntityAnswerValue]

	@intEntityProjectRequirementIdent BIGINT = 0, 
	@intEntityIdent BIGINT = 0, 
	@vcrName1 VARCHAR(MAX) = '', 
	@nvrValue1 NVARCHAR(MAX) = '',
	@intASUserIdent BIGINT = 0,
	@bitSuppressOutput BIT = 0,
	@bitAllowOptionAdd BIT = 0

AS

	SET NOCOUNT ON

	/*
		1. Check and see if there is a EntityProjectEntity Record (for private profile) and if not, add it
		1a. Get the EntityProjectEntityIdent
		1b. See if there is already a EntityProjectEntityAnswer, if so, get the ident and update the Edit Date time. If not, add it.
		2. Figure out if the user has already answered the question/Name1 combo (i.e. Address/StateIdent). If so, clear their old answer
		3. Insert new EntityProjectEntityAnswerValue with the provided Name1 and Value1
		4. Return that Ident

	*/
	DECLARE @intEntityProjectEntityAnswerIdent AS BIGINT
	DECLARE @intEntityProjectEntityIdent AS BIGINT
	DECLARE @sdtGetDate AS SMALLDATETIME

	DECLARE @bitQuestionHasOptions BIT
	DECLARE @nvrOptions NVARCHAR(MAX)


	SET @intEntityProjectEntityAnswerIdent = 0
	SET @intEntityProjectEntityIdent = 0
	SET @sdtGetDate = dbo.ufnGetMyDate()

	CREATE TABLE #tmpNewAnswerValue (
		EntityProjectEntityAnswerIdent  BIGINT,
		Name1 VARCHAR(MAX),
		Value1 VARCHAR(MAX),
		AddASUserIdent  BIGINT,
		AddDateTime  SMALLDATETIME,
		EditASUserIdent  BIGINT,
		EditDateTime  SMALLDATETIME,
		Active  BIT
	)
	


	SELECT 
		@intEntityProjectEntityIdent = EPE.Ident,
		@nvrOptions = EPR.Options,
		@bitQuestionHasOptions = RT.HasOptions
	FROM
		EntityProjectRequirement EPR WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EPR.EntityProjectIdent = EP.Ident
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityProjectIdent = EP.Ident
		INNER JOIN
		RequirementType RT WITH (NOLOCK)
			ON RT.Ident = EPR.RequirementTypeIdent
	WHERE 
		EPR.Ident = @intEntityProjectRequirementIdent
		AND EPE.EntityIdent = @intEntityIdent
		AND EPE.Active = 1

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
		EntityProjectIdent = EP.Ident,
		EntityIdent = @intEntityIdent,
		AddASUserIdent = @intASUserIdent,
		AddDateTime = @sdtGetDate,
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1
	FROM
		EntityProjectRequirement EPR WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EPR.EntityProjectIdent = EP.Ident
	WHERE 
		EPR.Ident = @intEntityProjectRequirementIdent
		AND @intEntityProjectEntityIdent = 0

	SELECT 
		@intEntityProjectEntityIdent = SCOPE_IDENTITY()
	WHERE 
		@intEntityProjectEntityIdent = 0


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
		EditASUserIdent = @intASUserIdent,
		EditDateTime =  @sdtGetDate,
		Active = CASE -- if the value is empty (and the name is empty, meaning its a single value store) then default to inactive
			WHEN @nvrValue1 = '' AND @vcrName1 = '' THEN 0 
			ELSE 1
		END
	WHERE 
		Ident = @intEntityProjectEntityAnswerIdent
		AND @intEntityProjectEntityAnswerIdent <> 0
		
	--Add it if it doesn't exist
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
	WHERE
		@intEntityProjectEntityAnswerIdent = 0
		AND @nvrValue1 <> ''

	SELECT 
		@intEntityProjectEntityAnswerIdent = SCOPE_IDENTITY()
	WHERE 
		@intEntityProjectEntityAnswerIdent = 0


	INSERT INTO #tmpNewAnswerValue (
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
		EntityProjectEntityAnswerIdent = @intEntityProjectEntityAnswerIdent,
		Name1 = @vcrName1,
		Value1 = @nvrValue1,
		AddASUserIdent = @intASUserIdent,
		AddDateTime = @sdtGetDate, 
		EditASUserIdent = @intASUserIdent,
		EditDateTime = @sdtGetDate, 
		Active = 1



	MERGE INTO EntityProjectEntityAnswerValue AS target
	USING #tmpNewAnswerValue AS source
		ON target.EntityProjectEntityAnswerIdent = source.EntityProjectEntityAnswerIdent
			AND target.Name1 = source.Name1
			AND target.Active = 1
	WHEN MATCHED THEN 
		--if we found one already, mark it as updated and who updated it.
		UPDATE 
			SET 
				target.Value1 = source.Value1,
				target.EditASUserIdent = source.EditASUserIdent,
				target.EditDateTime = source.EditDateTime,
				target.Active = source.Active

	WHEN NOT MATCHED BY TARGET THEN
		-- Put in the new answer
		INSERT (
			EntityProjectEntityAnswerIdent,
			Name1,
			Value1,
			AddASUserIdent,
			AddDateTime,
			EditASUserIdent,
			EditDateTime,
			Active
		)
		VALUES  (
			source.EntityProjectEntityAnswerIdent,
			source.Name1,
			source.Value1,
			source.AddASUserIdent,
			source.AddDateTime,
			source.EditASUserIdent,
			source.EditDateTime,
			source.Active
		);

	-- once we save the answer, lets check and see if its an option 
	-- if it is, and the saved option doesnt exist, add it to the list
	IF (@bitAllowOptionAdd = 1 AND @bitQuestionHasOptions = 1)
		BEGIN
			
			DECLARE @bitOptionExists BIT
			SET @bitOptionExists = 0

			CREATE TABLE #tmpOptions(
				OptionValue NVARCHAR(MAX)
			)

			INSERT INTO #tmpOptions(
				OptionValue
			)
			SELECT
				LTRIM(RTRIM([Value]))
			FROM
				dbo.ufnSplitString(@nvrOptions, '|')

			-- see if the option exists already (single select)
			SELECT
				@bitOptionExists = 1
			FROM
				#tmpOptions WITH (NOLOCK)
			WHERE
				OptionValue = LTRIM(RTRIM(@nvrValue1))
				AND @vcrName1 = ''
			
			-- see if the option exists already (multi select)
			SELECT
				@bitOptionExists = 1
			FROM
				#tmpOptions WITH (NOLOCK)
			WHERE
				OptionValue = LTRIM(RTRIM(@vcrName1))
				AND @vcrName1 <> ''

			-- if the option doesnt exist, then add it (multi select)
			UPDATE
				EPR
			SET
				Options = CASE EPR.Options
							WHEN '' THEN LTRIM(RTRIM(@vcrName1))
							ELSE EPR.Options + '|' + LTRIM(RTRIM(@vcrName1))
						  END,
				EditDateTime = dbo.ufnGetMyDate(),
				EditASUserIdent = @intASUserIdent
			FROM
				EntityProjectRequirement EPR WITH (NOLOCK)
				INNER JOIN
				RequirementType RT WITH (NOLOCK)
					ON RT.Ident = EPR.RequirementTypeIdent
			WHERE
				@bitOptionExists = 0
				AND LTRIM(RTRIM(@vcrName1)) <> ''
				AND EPR.Ident = @intEntityProjectRequirementIdent
				AND RT.HasOptions = 1
				AND RT.AllowMultipleOptions = 1

			-- if the option doesnt exist, then add it (single select)
			UPDATE
				EPR
			SET
				Options = CASE EPR.Options
							WHEN '' THEN LTRIM(RTRIM(@nvrValue1))
							ELSE EPR.Options + '|' + LTRIM(RTRIM(@nvrValue1))
						  END,
				EditDateTime = dbo.ufnGetMyDate(),
				EditASUserIdent = @intASUserIdent
			FROM
				EntityProjectRequirement EPR WITH (NOLOCK)
				INNER JOIN
				RequirementType RT WITH (NOLOCK)
					ON RT.Ident = EPR.RequirementTypeIdent
			WHERE
				@bitOptionExists = 0
				AND LTRIM(RTRIM(@nvrValue1)) <> ''
				AND EPR.Ident = @intEntityProjectRequirementIdent
				AND RT.HasOptions = 1
				AND RT.AllowMultipleOptions = 0

			DROP TABLE #tmpOptions

		END
		
	IF @bitSuppressOutput = 0
	BEGIN 
		SELECT SCOPE_IDENTITY() AS [Ident]
	END

	DROP TABLE #tmpNewAnswerValue

GO