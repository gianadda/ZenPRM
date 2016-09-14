
DROP TRIGGER trg_EntityToDoASUserActivityLog
GO 
CREATE TRIGGER trg_EntityToDoASUserActivityLog ON EntityToDo FOR INSERT, UPDATE
AS

-- we need to make sure something is actually edited
-- this will be null if we have a UPDATE with a WHERE clause that doesnt trigger an update
IF EXISTS(SELECT * FROM inserted)
BEGIN

	DECLARE @intActivityTypeAddEntityToDoIdent BIGINT
	DECLARE @intActivityTypeEditEntityToDoIdent BIGINT
	DECLARE @intActivityTypeDeleteEntityToDoIdent BIGINT
	DECLARE @intRecordIdent BIGINT
	DECLARE @intEntityIdent BIGINT
	DECLARE @intToDoInitiatorTypeIdent BIGINT
	DECLARE @intToDoTypeIdent BIGINT
	DECLARE @intToDoStatusIdent BIGINT
	DECLARE @nvrTitle NVARCHAR(MAX)
	DECLARE @nvrDesc1 NVARCHAR(MAX)
	DECLARE @dteStartDate SMALLDATETIME
	DECLARE @dteDueDate SMALLDATETIME
	DECLARE @intRegardingEntityIdent BIGINT
	DECLARE @intAssigneeEntityIdent BIGINT
	DECLARE @intEditASUserIdent BIGINT
	DECLARE @intAddASUserIdent BIGINT
	DECLARE @nvrUserFullname NVARCHAR(MAX)
	DECLARE @nvrRegardingEntityFullname NVARCHAR(MAX)
	DECLARE @nvrAssigneeFullname NVARCHAR(MAX)
	DECLARE @intASUserActivityIdent BIGINT
	DECLARE @dteGetDate DATETIME

	SET @dteGetDate = dbo.ufnGetMyDate()
	SET @intActivityTypeAddEntityToDoIdent = dbo.ufnActivityTypeAddEntityToDo()
	SET @intActivityTypeEditEntityToDoIdent = dbo.ufnActivityTypeEditEntityToDo()
	SET @intActivityTypeDeleteEntityToDoIdent = dbo.ufnActivityTypeDeleteEntityToDo()

	SELECT 
		@intRecordIdent = Ident,
		@intEntityIdent = EntityIdent,
		@intToDoInitiatorTypeIdent = ToDoInitiatorTypeIdent,
		@intToDoTypeIdent = ToDoTypeIdent,
		@intToDoStatusIdent = ToDoStatusIdent,
		@intRegardingEntityIdent = RegardingEntityIdent,
		@intAssigneeEntityIdent = AssigneeEntityIdent,
		@nvrTitle = Title,
		@nvrDesc1 = Desc1,
		@dteStartDate = StartDate,
		@dteDueDate = DueDate,
		@intEditASUserIdent = EditASUserIdent,
		@intAddASUserIdent = AddASUserIdent
	FROM
		inserted

	-- get the name of the resource who the ticket is for
	SELECT
		@nvrRegardingEntityFullname = E.Fullname
	FROM
		Entity E WITH (NOLOCK)
	WHERE
		E.Ident = @intRegardingEntityIdent

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
			ActivityDescription = REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@ToDo',@nvrTitle),'@@Entity',@nvrRegardingEntityFullname),
			ClientIPAddress = '', -- unobtainable at this point
			RecordIdent = @intRecordIdent,
			CustomerEntityIdent = @intEntityIdent,
			UpdatedEntityIdent = @intRegardingEntityIdent
		FROM
			ActivityType AT WITH (NOLOCK)
		WHERE
			AT.Ident = @intActivityTypeAddEntityToDoIdent

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
		ActivityDescription = REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@ToDo',@nvrTitle),'@@Entity',@nvrRegardingEntityFullname),
		ClientIPAddress = '', -- unobtainable at this point
		RecordIdent = @intRecordIdent,
		CustomerEntityIdent = @intEntityIdent,
		UpdatedEntityIdent = @intRegardingEntityIdent
	FROM
		ActivityType AT WITH (NOLOCK)
		INNER JOIN
		inserted ceNew WITH (NOLOCK)
			ON ceNew.Ident = @intRecordIdent
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceOld.Ident = ceNew.Ident
	WHERE
		AT.Ident = @intActivityTypeDeleteEntityToDoIdent
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
		ActivityDescription = REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@ToDo',@nvrTitle),'@@Entity',@nvrRegardingEntityFullname),
		ClientIPAddress = '', -- unobtainable at this point
		RecordIdent = @intRecordIdent,
		CustomerEntityIdent = @intEntityIdent,
		UpdatedEntityIdent = @intRegardingEntityIdent
	FROM
		ActivityType AT WITH (NOLOCK)
		INNER JOIN
		inserted ceNew WITH (NOLOCK)
			ON ceNew.Ident = @intRecordIdent
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceOld.Ident = ceNew.Ident
	WHERE
		AT.Ident = @intActivityTypeEditEntityToDoIdent
		AND (ceNew.Active = 1)
		AND (ceNew.ToDoInitiatorTypeIdent <> ceOld.ToDoInitiatorTypeIdent
				OR ceNew.ToDoTypeIdent <> ceOld.ToDoTypeIdent
				OR ceNew.ToDoStatusIdent <> ceOld.ToDoStatusIdent
				OR ceNew.RegardingEntityIdent <> ceOld.RegardingEntityIdent
				OR ceNew.Title <> ceOld.Title
				OR ceNew.Desc1 <> ceOld.Desc1
				OR ceNew.StartDate <> ceOld.StartDate
				OR ceNew.DueDate <> ceOld.DueDate
				OR ceNew.AssigneeEntityIdent <> ceOld.AssigneeEntityIdent)

	SET @intASUserActivityIdent = SCOPE_IDENTITY()

	INSERT INTO ASUserActivityDetail (
		ASUserActivityIdent,
		FieldName,
		OldValue,
		NewValue
	)
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Title',
		OldValue = ceOld.Title,
		NewValue = ceNew.Title
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.Title <> ceOld.Title

	INSERT INTO ASUserActivityDetail (
		ASUserActivityIdent,
		FieldName,
		OldValue,
		NewValue
	)
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
		FieldName = 'Due Date',
		OldValue = CAST(ceOld.DueDate AS NVARCHAR(MAX)),
		NewValue = CAST(ceNew.DueDate AS NVARCHAR(MAX))
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.DueDate <> ceOld.DueDate	

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Start Date',
		OldValue = CAST(ceOld.StartDate AS NVARCHAR(MAX)),
		NewValue = CAST(ceNew.StartDate AS NVARCHAR(MAX))
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.StartDate <> ceOld.StartDate	

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Assignee',
		OldValue = oldE.FullName,
		NewValue = newE.FullName
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
		INNER JOIN
		Entity oldE WITH (NOLOCK)
			ON oldE.Ident = ceOld.AssigneeEntityIdent
		INNER JOIN
		Entity newE WITH (NOLOCK)
			ON newE.Ident = ceNew.AssigneeEntityIdent
	WHERE
		ceNew.AssigneeEntityIdent <> ceOld.AssigneeEntityIdent


	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Resource',
		OldValue = oldE.FullName,
		NewValue = newE.FullName
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
		INNER JOIN
		Entity oldE WITH (NOLOCK)
			ON oldE.Ident = ceOld.RegardingEntityIdent
		INNER JOIN
		Entity newE WITH (NOLOCK)
			ON newE.Ident = ceNew.RegardingEntityIdent
	WHERE
		ceNew.RegardingEntityIdent <> ceOld.RegardingEntityIdent

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Status',
		OldValue = oldS.Name1,
		NewValue = newS.Name1
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
		INNER JOIN
		ToDoStatus newS WITH (NOLOCK)
			ON newS.Ident = ceNew.ToDoStatusIdent
		INNER JOIN
		ToDoStatus oldS WITH (NOLOCK)
			ON oldS.Ident = ceOld.ToDoStatusIdent
	WHERE
		ceNew.ToDoStatusIdent <> ceOld.ToDoStatusIdent	

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Type',
		OldValue = oldS.Name1,
		NewValue = newS.Name1
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
		INNER JOIN
		ToDoType newS WITH (NOLOCK)
			ON newS.Ident = ceNew.ToDoStatusIdent
		INNER JOIN
		ToDoType oldS WITH (NOLOCK)
			ON oldS.Ident = ceOld.ToDoStatusIdent
	WHERE
		ceNew.ToDoTypeIdent <> ceOld.ToDoTypeIdent	

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Initiator',
		OldValue = oldS.Name1,
		NewValue = newS.Name1
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
		INNER JOIN
		ToDoInitiatorType newS WITH (NOLOCK)
			ON newS.Ident = ceNew.ToDoStatusIdent
		INNER JOIN
		ToDoInitiatorType oldS WITH (NOLOCK)
			ON oldS.Ident = ceOld.ToDoStatusIdent
	WHERE
		ceNew.ToDoInitiatorTypeIdent <> ceOld.ToDoInitiatorTypeIdent

END

GO

