
DROP TRIGGER trg_EntityEmailASUserActivityLog
GO 
CREATE TRIGGER trg_EntityEmailASUserActivityLog ON EntityEmail FOR INSERT, UPDATE
AS

-- we need to make sure something is actually edited
-- this will be null if we have a UPDATE with a WHERE clause that doesnt trigger an update
IF EXISTS(SELECT * FROM inserted)
BEGIN

	DECLARE @intActivityTypeAddEntityEmailIdent BIGINT
	DECLARE @intActivityTypeEditEntityEmailIdent BIGINT
	DECLARE @intActivityTypeDeleteEntityEmailIdent BIGINT
	DECLARE @intRecordIdent BIGINT
	DECLARE @intEntityIdent BIGINT
	DECLARE @intEditASUserIdent BIGINT
	DECLARE @intAddASUserIdent BIGINT
	DECLARE @intGenderIdent BIGINT
	DECLARE @nvrUserFullname NVARCHAR(MAX)
	DECLARE @nvrEntityFullname NVARCHAR(MAX)
	DECLARE @nvrEntityEmail NVARCHAR(MAX)
	DECLARE @intASUserActivityIdent BIGINT
	DECLARE @dteGetDate DATETIME

	SET @dteGetDate = dbo.ufnGetMyDate()

	SET @intActivityTypeAddEntityEmailIdent = dbo.ufnActivityTypeAddEntityEmail()
	SET @intActivityTypeEditEntityEmailIdent = dbo.ufnActivityTypeEditEntityEmail()
	SET @intActivityTypeDeleteEntityEmailIdent = dbo.ufnActivityTypeDeleteEntityEmail()

	SELECT 
		@intRecordIdent = Ident,
		@intEntityIdent = EntityIdent ,
		@nvrEntityEmail = Email ,
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
		@nvrUserFullname = E.Fullname,
		@intGenderIdent = E.GenderIdent
	FROM
		Entity E WITH (NOLOCK)
	WHERE
		@intEditASUserIdent > 0
		AND E.Ident = @intEditASUserIdent


	--If there is no deleted, then it's an Add
	IF NOT EXISTS (SELECT * FROM deleted)
	BEGIN

		SELECT
			@nvrUserFullname = E.Fullname,
			@intGenderIdent = E.GenderIdent
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
			ActivityDescription = CASE
									--0	N/A
									--1	Male
									--2	Female
									WHEN @intAddASUserIdent = @intEntityIdent AND @intGenderIdent = 0 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','their'),'@@Email',@nvrEntityEmail)
									WHEN @intAddASUserIdent = @intEntityIdent AND @intGenderIdent = 1 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','his'),'@@Email',@nvrEntityEmail)
									WHEN @intAddASUserIdent = @intEntityIdent AND @intGenderIdent = 2 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','her'),'@@Email',@nvrEntityEmail)
									ELSE REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity',@nvrEntityFullname + '''s'),'@@Email',@nvrEntityEmail)
									END,
			ClientIPAddress = '', -- unobtainable at this point
			RecordIdent = @intRecordIdent,
			CustomerEntityIdent = 0,
			UpdatedEntityIdent = @intEntityIdent
		FROM
			ActivityType AT WITH (NOLOCK)
		WHERE
			AT.Ident = @intActivityTypeAddEntityEmailIdent

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
		ActivityDescription = CASE
								--0	N/A
								--1	Male
								--2	Female
								WHEN @intEditASUserIdent = @intEntityIdent AND @intGenderIdent = 0 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','their'),'@@Email',@nvrEntityEmail)
								WHEN @intEditASUserIdent = @intEntityIdent AND @intGenderIdent = 1 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','his'),'@@Email',@nvrEntityEmail)
								WHEN @intEditASUserIdent = @intEntityIdent AND @intGenderIdent = 2 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','her'),'@@Email',@nvrEntityEmail)
								ELSE REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity',@nvrEntityFullname + '''s'),'@@Email',@nvrEntityEmail)
								END,
		ClientIPAddress = '', -- unobtainable at this point
		RecordIdent = @intRecordIdent,
		CustomerEntityIdent = 0,
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
		AT.Ident = @intActivityTypeDeleteEntityEmailIdent
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
		ActivityDescription = CASE
								--0	N/A
								--1	Male
								--2	Female
								WHEN @intEditASUserIdent = @intEntityIdent AND @intGenderIdent = 0 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','their'),'@@Email',@nvrEntityEmail)
								WHEN @intEditASUserIdent = @intEntityIdent AND @intGenderIdent = 1 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','his'),'@@Email',@nvrEntityEmail)
								WHEN @intEditASUserIdent = @intEntityIdent AND @intGenderIdent = 2 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','her'),'@@Email',@nvrEntityEmail)
								ELSE REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity',@nvrEntityFullname + '''s'),'@@Email',@nvrEntityEmail)
								END,
		ClientIPAddress = '', -- unobtainable at this point
		RecordIdent = @intRecordIdent,
		CustomerEntityIdent = 0,
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
		AT.Ident = @intActivityTypeEditEntityEmailIdent
		AND (ceNew.Active = 1)
		AND (ceNew.Email <> ceOld.Email
				OR ceNew.notify <> ceOld.notify)

	SET @intASUserActivityIdent = SCOPE_IDENTITY()

	INSERT INTO ASUserActivityDetail (
		ASUserActivityIdent,
		FieldName,
		OldValue,
		NewValue
	)
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Email',
		OldValue = ceOld.Email,
		NewValue = ceNew.Email
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.Email <> ceOld.Email

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Notify',
		OldValue = CASE ceOld.Notify
						WHEN '1' THEN 'True'
						WHEN '0' THEN 'False'
					END,
		NewValue = CASE ceNew.Notify
						WHEN '1' THEN 'True'
						WHEN '0' THEN 'False'
					END
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.Notify <> ceOld.Notify

END

GO

