
DROP TRIGGER trg_EntityProjectASUserActivityLog
GO 
CREATE TRIGGER trg_EntityProjectASUserActivityLog ON EntityProject FOR INSERT, UPDATE
AS

-- we need to make sure something is actually edited
-- this will be null if we have a UPDATE with a WHERE clause that doesnt trigger an update
IF EXISTS(SELECT * FROM inserted)
BEGIN

	DECLARE @intActivityTypeAddEntityProjectIdent BIGINT
	DECLARE @intActivityTypeArchiveEntityProjectIdent BIGINT
	DECLARE @intActivityTypeRestoreEntityProjectIdent BIGINT
	DECLARE @intActivityTypeDeleteEntityProjectIdent BIGINT
	DECLARE @intRecordIdent BIGINT
	DECLARE @intEntityIdent BIGINT
	DECLARE @intEditASUserIdent BIGINT
	DECLARE @intAddASUserIdent BIGINT
	DECLARE @nvrUserFullname NVARCHAR(MAX)
	DECLARE @nvrEntityFullname NVARCHAR(MAX)
	DECLARE @intASUserActivityIdent BIGINT
	DECLARE @nvrProjectName1 NVARCHAR(MAX)
	DECLARE @dteGetDate DATETIME

	SET @dteGetDate = dbo.ufnGetMyDate()
	SET @intActivityTypeAddEntityProjectIdent = dbo.ufnActivityTypeAddEntityProject()
	SET @intActivityTypeArchiveEntityProjectIdent = dbo.ufnActivityTypeArchiveEntityProject()
	SET @intActivityTypeRestoreEntityProjectIdent = dbo.ufnActivityTypeRestoreEntityProject()
	SET @intActivityTypeDeleteEntityProjectIdent = dbo.ufnActivityTypeDeleteEntityProject()


	SELECT 
		@intRecordIdent = Ident,
		@intEntityIdent = EntityIdent ,
		@nvrProjectName1 = Name1,
		@intEditASUserIdent = EditASUserIdent,
		@intAddASUserIdent = AddASUserIdent
	FROM
		inserted

	SELECT
		@nvrEntityFullname = E.Fullname
	FROM
		Entity E WITH (NOLOCK)
		INNER JOIN
		inserted i WITH (NOLOCK)
			on I.EntityIdent = E.Ident

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
			ActivityDescription = REPLACE(REPLACE(AT.Desc1,'@@Project',@nvrProjectName1),'@@Name',@nvrUserFullname),
			ClientIPAddress = '', -- unobtainable at this point
			RecordIdent = @intRecordIdent,
			CustomerEntityIdent = @intEntityIdent,
			UpdatedEntityIdent = 0
		FROM
			ActivityType AT WITH (NOLOCK)
		WHERE
			AT.Ident = @intActivityTypeAddEntityProjectIdent

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
		ActivityDescription = REPLACE(REPLACE(AT.Desc1,'@@Project',@nvrProjectName1),'@@Name',@nvrUserFullname),
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
		AT.Ident = @intActivityTypeDeleteEntityProjectIdent
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
		ActivityDescription = REPLACE(REPLACE(AT.Desc1,'@@Project',@nvrProjectName1),'@@Name',@nvrUserFullname),
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
		AT.Ident = @intActivityTypeArchiveEntityProjectIdent
		AND ceNew.Active = 1
		AND ceNew.Archived = 1
		AND ceOld.Archived = 0 

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
		ActivityDescription = REPLACE(REPLACE(AT.Desc1,'@@Project',@nvrProjectName1),'@@Name',@nvrUserFullname),
		ClientIPAddress = '', -- unobtainable at this point
		RecordIdent = @intRecordIdent,
		CustomerEntityIdent = @intEntityIdent,
		UpdatedEntityIdent = @intEntityIdent
	FROM
		ActivityType AT WITH (NOLOCK)
		INNER JOIN
		inserted ceNew WITH (NOLOCK)
			ON ceNew.Ident = @intRecordIdent
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceOld.Ident = ceNew.Ident
	WHERE
		AT.Ident = @intActivityTypeRestoreEntityProjectIdent
		AND ceNew.Active = 1
		AND ceNew.Archived = 0
		AND ceOld.Archived = 1 

END

GO

