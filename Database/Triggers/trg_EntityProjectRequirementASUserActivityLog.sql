
DROP TRIGGER trg_EntityProjectRequirementASUserActivityLog
GO 
CREATE TRIGGER trg_EntityProjectRequirementASUserActivityLog ON EntityProjectRequirement FOR INSERT, UPDATE
AS

-- we need to make sure something is actually edited
-- this will be null if we have a UPDATE with a WHERE clause that doesnt trigger an update
IF EXISTS(SELECT * FROM inserted)
BEGIN

	DECLARE @intActivityTypeAddEntityProjectRequirementIdent BIGINT
	DECLARE @intActivityTypeEditEntityProjectRequirementIdent BIGINT
	DECLARE @intActivityTypeDeleteEntityProjectRequirementIdent BIGINT
	DECLARE @intRecordIdent BIGINT
	DECLARE @intEntityProjectIdent BIGINT
	DECLARE @bntRequirementTypeIdent BIGINT
	DECLARE @nvrLabel NVARCHAR(MAX)
	DECLARE @nvrDesc1 NVARCHAR(MAX)
	DECLARE @nvrPlaceholderText NVARCHAR(MAX)
	DECLARE @nvrHelpText NVARCHAR(MAX)
	DECLARE @nvrOptions NVARCHAR(MAX)
	DECLARE @bntSortOrder BIGINT
	DECLARE @bitCreateToDoUponCompletion BIT
	DECLARE @nvrToDoTitle NVARCHAR(MAX)
	DECLARE @nvrToDoDesc1 NVARCHAR(MAX)
	DECLARE @bntToDoAssigneeEntityIdent BIGINT
	DECLARE @bntToDoDueDateNoOfDays BIGINT
	DECLARE @intEditASUserIdent BIGINT
	DECLARE @intAddASUserIdent BIGINT
	DECLARE @nvrUserFullname NVARCHAR(MAX)
	DECLARE @nvrEntityProjectName NVARCHAR(MAX)
	DECLARE @intASUserActivityIdent BIGINT
	DECLARE @intEntityIdent BIGINT
	DECLARE @dteGetDate DATETIME

	SET @dteGetDate = dbo.ufnGetMyDate()
	SET @intActivityTypeAddEntityProjectRequirementIdent = dbo.ufnActivityTypeAddEntityProjectRequirement()
	SET @intActivityTypeEditEntityProjectRequirementIdent = dbo.ufnActivityTypeEditEntityProjectRequirement()
	SET @intActivityTypeDeleteEntityProjectRequirementIdent = dbo.ufnActivityTypeDeleteEntityProjectRequirement()

	SELECT 
		@intRecordIdent = Ident,
		@intEntityProjectIdent = EntityProjectIdent ,
		@bntRequirementTypeIdent = RequirementTypeIdent,
		@nvrLabel = Label,
		@nvrDesc1 = Desc1,
		@nvrPlaceholderText = PlaceholderText,
		@nvrHelpText = HelpText,
		@nvrOptions = Options,
		@bntSortOrder = SortOrder,
		@bitCreateToDoUponCompletion = CreateToDoUponCompletion,
		@nvrToDoTitle = ToDoTitle,
		@nvrToDoDesc1 = ToDoDesc1,
		@bntToDoAssigneeEntityIdent = ToDoAssigneeEntityIdent,
		@bntToDoDueDateNoOfDays = ToDoDueDateNoOfDays,
		@intEditASUserIdent = EditASUserIdent,
		@intAddASUserIdent = AddASUserIdent
	FROM
		inserted

	SELECT
		@nvrEntityProjectName = EP.Name1,
		@intEntityIdent = EP.EntityIdent
	FROM
		EntityProject EP WITH (NOLOCK)
		INNER JOIN
		inserted i WITH (NOLOCK)
			on I.EntityProjectIdent = EP.Ident

	-- assume user is editing, well override add in the next clause if need be
	SELECT
		@nvrUserFullname = E.Fullname
	FROM
		Entity E WITH (NOLOCK)
	WHERE
		@intEditASUserIdent > 0
		AND E.Ident = @intEditASUserIdent


	--If there is no deleted, then it's an Add
	IF NOT EXISTS (SELECT * FROM deleted)
	BEGIN

		SELECT
			@nvrUserFullname = E.Fullname
		FROM
			Entity E WITH (NOLOCK)
			INNER JOIN
			inserted i WITH (NOLOCK)
				on I.AddASUserIdent = E.Ident

		INSERT INTO ASUserActivity(
			ASUserIdent,
			ActivityTypeIdent,
			ActivityDateTime,
			ActivityDescription,
			ClientIPAddress,
			RecordIdent,
			CustomerEntityIdent,
			UpdatedEntityIdent
		)
		SELECT
			ASUserIdent = @intAddASUserIdent,
			ActivityTypeIdent = AT.Ident,
			ActivityDateTime = @dteGetDate,
			ActivityDescription = REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@RequirementName',@nvrLabel),'@@EntityProject',@nvrEntityProjectName),
			ClientIPAddress = '', -- unobtainable at this point
			RecordIdent = @intRecordIdent,
			CustomerEntityIdent = @intEntityIdent,
			UpdatedEntityIdent = 0
		FROM
			ActivityType AT WITH (NOLOCK)
		WHERE
			AT.Ident = @intActivityTypeAddEntityProjectRequirementIdent

	END

	INSERT INTO ASUserActivity(
		ASUserIdent,
		ActivityTypeIdent,
		ActivityDateTime,
		ActivityDescription,
		ClientIPAddress,
		RecordIdent,
		CustomerEntityIdent,
		UpdatedEntityIdent
	)
	SELECT
		ASUserIdent = @intEditASUserIdent,
		ActivityTypeIdent = AT.Ident,
		ActivityDateTime = @dteGetDate,
		ActivityDescription = REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@RequirementName',@nvrLabel),'@@EntityProject',@nvrEntityProjectName),
		ClientIPAddress = '', -- unobtainable at this point
		RecordIdent = @intRecordIdent,
		CustomerEntityIdent = @intEntityIdent,
		UpdatedEntityIdent = 0
	FROM
		ActivityType AT WITH (NOLOCK)
		INNER JOIN
		inserted ceNew WITH (NOLOCK)
			ON ceNew.Ident = @intRecordIdent
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceOld.Ident = ceNew.Ident
	WHERE
		AT.Ident = @intActivityTypeDeleteEntityProjectRequirementIdent
		AND (ceNew.Active = 0)
	
	INSERT INTO ASUserActivity(
		ASUserIdent,
		ActivityTypeIdent,
		ActivityDateTime,
		ActivityDescription,
		ClientIPAddress,
		RecordIdent,
		CustomerEntityIdent,
		UpdatedEntityIdent
	)
	SELECT
		ASUserIdent = @intEditASUserIdent,
		ActivityTypeIdent = AT.Ident,
		ActivityDateTime = @dteGetDate,
		ActivityDescription = REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@RequirementName',@nvrLabel),'@@EntityProject',@nvrEntityProjectName),
		ClientIPAddress = '', -- unobtainable at this point
		RecordIdent = @intRecordIdent,
		CustomerEntityIdent = @intEntityIdent,
		UpdatedEntityIdent = 0
	FROM
		ActivityType AT WITH (NOLOCK)
		INNER JOIN
		inserted ceNew WITH (NOLOCK)
			ON ceNew.Ident = @intRecordIdent
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceOld.Ident = ceNew.Ident
	WHERE
		AT.Ident = @intActivityTypeEditEntityProjectRequirementIdent
		AND (ceNew.Active = 1)
		AND (ceNew.RequirementTypeIdent <> ceOld.RequirementTypeIdent
				OR ceNew.Label <> ceOld.Label
				OR ceNew.Desc1 <> ceOld.Desc1
				OR ceNew.PlaceholderText <> ceOld.PlaceholderText
				OR ceNew.HelpText <> ceOld.HelpText
				OR ceNew.Options <> ceOld.Options
				OR ceNew.SortOrder <> ceOld.SortOrder
				OR ceNew.CreateToDoUponCompletion <> ceOld.CreateToDoUponCompletion
				OR ceNew.ToDoTitle <> ceOld.ToDoTitle
				OR ceNew.ToDoDesc1 <> ceOld.ToDoDesc1
				OR ceNew.ToDoAssigneeEntityIdent <> ceOld.ToDoAssigneeEntityIdent
				OR ceNew.ToDoDueDateNoOfDays <> ceOld.ToDoDueDateNoOfDays)

	SET @intASUserActivityIdent = SCOPE_IDENTITY()

	INSERT INTO ASUserActivityDetail (
		ASUserActivityIdent,
		FieldName,
		OldValue,
		NewValue
	)
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Field Type',
		OldValue = oldRT.Name1,
		NewValue = newRT.Name1
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
		INNER JOIN
		RequirementType oldRT WITH (NOLOCK)
			ON oldRT.Ident = ceOld.RequirementTypeIdent
		INNER JOIN
		RequirementType newRT WITH (NOLOCK)
			ON newRT.Ident = ceOld.RequirementTypeIdent
	WHERE
		ceNew.RequirementTypeIdent <> ceOld.RequirementTypeIdent

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Label',
		OldValue = ceOld.Label,
		NewValue = ceNew.Label
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.Label <> ceOld.Label

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Description',
		OldValue = ceOld.Desc1,
		NewValue = ceNew.Desc1
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.Desc1 <> ceOld.Desc1

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Placeholder Text',
		OldValue = ceOld.PlaceholderText,
		NewValue = ceNew.PlaceholderText
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.PlaceholderText <> ceOld.PlaceholderText

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Help Text',
		OldValue = ceOld.HelpText,
		NewValue = ceNew.HelpText
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.HelpText <> ceOld.HelpText

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Options',
		OldValue = ceOld.Options,
		NewValue = ceNew.Options
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.Options <> ceOld.Options

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Order No.',
		OldValue = CAST(ceOld.SortOrder AS NVARCHAR(MAX)),
		NewValue = CAST(ceNew.SortOrder AS NVARCHAR(MAX))
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.SortOrder <> ceOld.SortOrder

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Create To-Do item when question is answered',
		OldValue = CASE ceOld.CreateToDoUponCompletion
					WHEN 1 THEN 'Yes'
					WHEN 0 THEN 'No'
				   END,
		NewValue = CASE ceNew.CreateToDoUponCompletion
					WHEN 1 THEN 'Yes'
					WHEN 0 THEN 'No'
				   END
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.CreateToDoUponCompletion <> ceOld.CreateToDoUponCompletion

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'To-Do Title',
		OldValue = ceOld.ToDoTitle,
		NewValue = ceNew.ToDoTitle
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.ToDoTitle <> ceOld.ToDoTitle

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'To-Do Description',
		OldValue = ceOld.ToDoDesc1,
		NewValue = ceNew.ToDoDesc1
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.ToDoDesc1 <> ceOld.ToDoDesc1

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'To-Do Assignee',
		OldValue = oldE.FullName,
		NewValue = newE.FullName
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
		INNER JOIN
		Entity oldE WITH (NOLOCK)
			ON oldE.Ident = ceOld.ToDoAssigneeEntityIdent
		INNER JOIN
		Entity newE WITH (NOLOCK)
			ON newE.Ident = ceNew.ToDoAssigneeEntityIdent
	WHERE
		ceNew.ToDoAssigneeEntityIdent <> ceOld.ToDoAssigneeEntityIdent

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'To-Do Due Date (in days)',
		OldValue = CAST(ceOld.ToDoDueDateNoOfDays AS NVARCHAR(MAX)),
		NewValue = CAST(ceNew.ToDoDueDateNoOfDays AS NVARCHAR(MAX))
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.ToDoDueDateNoOfDays <> ceOld.ToDoDueDateNoOfDays

END

GO

