IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityProject') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntityProject
 GO
/* uspAddEntityProject
 *
 *
 *
 *
*/
CREATE PROCEDURE uspAddEntityProject

	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT,
	@nvrName1 NVARCHAR(MAX),
	@sdtDueDate SMALLDATETIME = NULL,
	@bitPrivateProject BIT,
	@bntProjectManagerEntityIdent BIGINT,
	@bntProjectTemplateIdent BIGINT,
	@bitIncludeParticipants BIT,
	@bitIncludeQuestions BIT,
	@bitShowOnProfile BIT,
	@bitIncludeEntireNetwork BIT,
	@bitAllowOpenRegistration BIT

AS

	SET NOCOUNT ON

	DECLARE @intIdent BIGINT
	DECLARE @bitAddSampleQuestion BIT

	SELECT
		@bitAddSampleQuestion = CAST(Value1 AS BIT)
	FROM
		ASApplicationVariable WITH (NOLOCK)
	WHERE
		Name1 = 'AddSampleQuestionAfterAddEntityProject'

	INSERT INTO EntityProject(
		EntityIdent,
		Name1,
		DueDate,
		PrivateProject,
		ProjectManagerEntityIdent,
		Archived,
		ArchivedASUserIdent,
		ArchivedDateTime,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active,
		ShowOnProfile,
		IncludeEntireNetwork,
		AllowOpenRegistration,
		ProjectGUID
	) 
	SELECT 
		EntityIdent = @bntEntityIdent,
		Name1 = @nvrName1,
		DueDate = @sdtDueDate,
		PrivateProject = @bitPrivateProject,
		ProjectManagerEntityIdent = @bntProjectManagerEntityIdent,
		Archived = 0,
		ArchivedASUserIdent = 0,
		ArchivedDateTime = '1/1/1900',
		AddASUserIdent = @bntASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1,
		ShowOnProfile = @bitShowOnProfile,
		IncludeEntireNetwork = @bitIncludeEntireNetwork,
		AllowOpenRegistration = @bitAllowOpenRegistration,
		ProjectGUID = NEWID()

	SELECT @intIdent = SCOPE_IDENTITY()

	-- if copying from old project and including participants
	INSERT INTO EntityProjectEntity(
		EntityProjectIdent,
		EntityIdent,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT
		EntityProjectIdent = @intIdent,
		EntityIdent = EPE.EntityIdent,
		AddASUserIdent = @bntASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1
	FROM
		EntityProjectEntity EPE WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = EPE.EntityProjectIdent
	WHERE
		@intIdent IS NOT NULL
		AND @bntProjectTemplateIdent > 0
		AND @bitIncludeParticipants = 1
		AND EPE.Active = 1
		AND EP.Ident = @bntProjectTemplateIdent
		AND EP.EntityIdent = @bntEntityIdent -- make sure the entity has access to this project

	-- if copying from old project and including participants
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
		EntityProjectIdent = @intIdent,
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
		CreateToDoUponCompletion = EPR.CreateToDoUponCompletion,
		ToDoTitle = EPR.ToDoTitle,
		ToDoDesc1 = EPR.ToDoDesc1,
		ToDoAssigneeEntityIdent = EPR.ToDoAssigneeEntityIdent,
		ToDoDueDateNoOfDays = EPR.ToDoDueDateNoOfDays
	FROM
		EntityProjectRequirement EPR WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = EPR.EntityProjectIdent
	WHERE
		@intIdent IS NOT NULL
		AND @bntProjectTemplateIdent > 0
		AND @bitIncludeQuestions = 1
		AND EPR.Active = 1
		AND EP.Ident = @bntProjectTemplateIdent
		AND EP.EntityIdent = @bntEntityIdent -- make sure the entity has access to this project

	-- add a sample question, if we are setup to add a sample, and we aren't already copying in questions from another project
	IF (@bitAddSampleQuestion = 1 AND (@bntProjectTemplateIdent = 0 OR @bitIncludeQuestions = 0))
	BEGIN
		EXEC uspAddEntityProjectRequirement @bntEntityProjectIdent = @intIdent,
												@bntEntityIdent = @bntEntityIdent,
												@bntASUserIdent = @bntASUserIdent,
												@bntRequirementTypeIdent = 5, -- Options - Checkboxes
												@nvrLabel = 'Sample Question',
												@nvrDesc1 = '<h4>Description</h4><p>Use this space to provide additional information to users about the question.</p>',
												@nvrPlaceholderText = '',
												@nvrHelpText = '',
												@nvrOptions = 'Sample Option 1|Sample Option 2|Sample Option 3',
												@intSortOrder = 1,
												@bitCreateToDoUponCompletion = 0,
												@nvrToDoTitle = '',
												@nvrToDoDesc1 = '',
												@bntToDoAssigneeEntityIdent = 0,
												@intToDoDueDateNoOfDays = 0,
												@bitSupressOutput = 1
	END

	SELECT @intIdent as [Ident]

GO