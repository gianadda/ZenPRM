IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityProjectRequirement') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntityProjectRequirement
 GO
/* uspAddEntityProjectRequirement
 *
 *
 *
 *
*/
CREATE PROCEDURE uspAddEntityProjectRequirement

	@bntEntityProjectIdent BIGINT,
	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT,
	@bntRequirementTypeIdent BIGINT,
	@nvrLabel NVARCHAR(MAX),
	@nvrDesc1 NVARCHAR(MAX),
	@nvrPlaceholderText NVARCHAR(MAX),
	@nvrHelpText NVARCHAR(MAX),
	@nvrOptions NVARCHAR(MAX),
	@intSortOrder INT,
	@bitCreateToDoUponCompletion BIT,
	@nvrToDoTitle NVARCHAR(MAX),
	@nvrToDoDesc1 NVARCHAR(MAX),
	@bntToDoAssigneeEntityIdent BIGINT,
	@intToDoDueDateNoOfDays INT,
	@bitSupressOutput BIT

AS

	SET NOCOUNT ON

	DECLARE @bntIdent BIGINT
	DECLARE @bntAddedToEndOfList BIT

	SET @bntAddedToEndOfList = 0

	-- if the sort order is 0, it means were adding it to the end of the question list
	IF (@intSortOrder = 0)
		BEGIN

			SET @bntAddedToEndOfList = 1

			SELECT
				@intSortOrder = MAX(SortOrder)
			FROM
				EntityProjectRequirement WITH (NOLOCK)
			WHERE
				EntityProjectIdent = @bntEntityProjectIdent
				AND Active = 1

			SET @intSortOrder = (COALESCE(@intSortOrder, 0) + 1)

		END

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
		EntityProjectIdent = EP.Ident,
		RequirementTypeIdent = @bntRequirementTypeIdent,
		Label = @nvrLabel,
		Desc1 = @nvrDesc1,
		PlaceholderText = @nvrPlaceholderText,
		HelpText = @nvrHelpText,
		Options = @nvrOptions,
		SortOrder = @intSortOrder,
		AddASUserIdent = @bntASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1,
		CreateToDoUponCompletion = @bitCreateToDoUponCompletion,
		ToDoTitle = @nvrToDoTitle,
		ToDoDesc1 = @nvrToDoDesc1,
		ToDoAssigneeEntityIdent = @bntToDoAssigneeEntityIdent,
		ToDoDueDateNoOfDays = @intToDoDueDateNoOfDays		
	FROM
		EntityProject EP WITH (NOLOCK)
	WHERE
		EP.Ident = @bntEntityProjectIdent
		AND EP.EntityIdent = @bntEntityIdent -- security to ensure that the user has access to this record

	SET @bntIdent = SCOPE_IDENTITY()

	-- if weve added a record and the question isnt being added to the end of the list
	IF (@bntIdent IS NOT NULL AND @bntAddedToEndOfList = 0)
		BEGIN

			-- take the existing questions and bump them down one in the list 
			UPDATE
				EntityProjectRequirement
			SET
				SortOrder = SortOrder + 1
			WHERE
				EntityProjectIdent = @bntEntityProjectIdent
				AND Active = 1
				AND SortOrder >= @intSortOrder
				AND Ident <> @bntIdent

		END

	IF (@bitSupressOutput = 0)
		BEGIN
			SELECT @bntIdent AS [Ident]
		END

GO