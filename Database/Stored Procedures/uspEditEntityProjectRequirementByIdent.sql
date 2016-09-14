IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspEditEntityProjectRequirementByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspEditEntityProjectRequirementByIdent
 GO
/* uspEditEntityProjectRequirementByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE uspEditEntityProjectRequirementByIdent

	@bntIdent BIGINT,
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
	@intToDoDueDateNoOfDays INT

AS

	SET NOCOUNT ON

	UPDATE EPR
	SET
		RequirementTypeIdent = @bntRequirementTypeIdent,
		Label = @nvrLabel,
		Desc1 = @nvrDesc1,
		PlaceholderText = @nvrPlaceholderText,
		HelpText = @nvrHelpText,
		Options = @nvrOptions,
		SortOrder = @intSortOrder,
		EditASUserIdent = @bntASUserIdent,
		EditDateTime = dbo.ufnGetMyDate(),
		Active = 1,
		CreateToDoUponCompletion = @bitCreateToDoUponCompletion,
		ToDoTitle = @nvrToDoTitle,
		ToDoDesc1 = @nvrToDoDesc1,
		ToDoAssigneeEntityIdent = @bntToDoAssigneeEntityIdent,
		ToDoDueDateNoOfDays = @intToDoDueDateNoOfDays	
	FROM
		EntityProjectRequirement EPR WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = EPR.EntityProjectIdent
	WHERE
		EPR.Ident = @bntIdent
		AND EP.EntityIdent = @bntEntityIdent -- security to ensure that the user has access to this record

	SELECT @bntIdent as [Ident]

GO