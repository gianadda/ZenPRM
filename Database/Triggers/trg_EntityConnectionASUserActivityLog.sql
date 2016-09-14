
DROP TRIGGER trg_EntityConnectionASUserActivityLog
GO 
CREATE TRIGGER trg_EntityConnectionASUserActivityLog ON EntityConnection FOR INSERT, UPDATE
AS

-- we need to make sure something is actually edited
-- this will be null if we have a UPDATE with a WHERE clause that doesnt trigger an update
IF EXISTS(SELECT * FROM inserted)
BEGIN

	DECLARE @intActivityTypeAddEntityConnectionIdent BIGINT
	DECLARE @intActivityTypeDeleteEntityConnectionIdent BIGINT
	DECLARE @intFromEntityIdent BIGINT
	DECLARE @intToEntityIdent BIGINT
	DECLARE @intRecordIdent BIGINT
	DECLARE @intEditASUserIdent BIGINT
	DECLARE @intAddASUserIdent BIGINT
	DECLARE @nvrUserFullname NVARCHAR(MAX)
	DECLARE @nvrToEntityFullname NVARCHAR(MAX)
	DECLARE @nvrFromEntityFullname NVARCHAR(MAX)
	DECLARE @intGenderIdent BIGINT
	DECLARE @dteGetDate DATETIME

	SET @dteGetDate = dbo.ufnGetMyDate()
	
	SET @intActivityTypeAddEntityConnectionIdent = dbo.ufnActivityTypeAddEntityConnection()
	SET @intActivityTypeDeleteEntityConnectionIdent = dbo.ufnActivityTypeDeleteEntityConnection()

	SELECT 
		@intRecordIdent = Ident,
		@intFromEntityIdent = FromEntityIdent ,
		@intToEntityIdent = ToEntityIdent ,
		@intEditASUserIdent = EditASUserIdent,
		@intAddASUserIdent = AddASUserIdent
	FROM
		inserted

	SELECT
		@nvrToEntityFullname = E.Fullname
	FROM
		Entity E WITH (NOLOCK)
		INNER JOIN
		inserted i WITH (NOLOCK)
			on I.ToEntityIdent = E.Ident

	SELECT
		@nvrFromEntityFullname = E.Fullname
	FROM
		Entity E WITH (NOLOCK)
		INNER JOIN
		inserted i WITH (NOLOCK)
			on I.FromEntityIdent = E.Ident
			
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

		-- if the editing user isnt the entity where connecting with - 
		-- then we need to log two records here, so in history it could appear for either entities activity
		-- to entity Ident
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
									WHEN @intAddASUserIdent = @intFromEntityIdent AND @intGenderIdent = 0 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@FromEntity','their network'),'@@ToEntity',@nvrToEntityFullname)
									WHEN @intAddASUserIdent = @intFromEntityIdent AND @intGenderIdent = 1 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@FromEntity','his network'),'@@ToEntity',@nvrToEntityFullname)
									WHEN @intAddASUserIdent = @intFromEntityIdent AND @intGenderIdent = 2 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@FromEntity','her network'),'@@ToEntity',@nvrToEntityFullname)
									ELSE REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@FromEntity',@nvrFromEntityFullname + '''s network'),'@@ToEntity',@nvrToEntityFullname)
									END,
			ClientIPAddress = '', -- unobtainable at this point
			RecordIdent = @intRecordIdent,
			CustomerEntityIdent = 0,
			UpdatedEntityIdent = @intToEntityIdent
		FROM
			ActivityType AT WITH (NOLOCK)
		WHERE
			AT.Ident = @intActivityTypeAddEntityConnectionIdent
			AND @intToEntityIdent <> @intAddASUserIdent

		-- we need to log two records here, so in history it could appear for either entities activity
		-- from entity Ident
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
									WHEN @intAddASUserIdent = @intFromEntityIdent AND @intGenderIdent = 0 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@FromEntity','their network'),'@@ToEntity',@nvrToEntityFullname)
									WHEN @intAddASUserIdent = @intFromEntityIdent AND @intGenderIdent = 1 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@FromEntity','his network'),'@@ToEntity',@nvrToEntityFullname)
									WHEN @intAddASUserIdent = @intFromEntityIdent AND @intGenderIdent = 2 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@FromEntity','her network'),'@@ToEntity',@nvrToEntityFullname)
									ELSE REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@FromEntity',@nvrFromEntityFullname + '''s network'),'@@ToEntity',@nvrToEntityFullname)
									END,
			ClientIPAddress = '', -- unobtainable at this point
			RecordIdent = @intRecordIdent,
			CustomerEntityIdent = 0,
			UpdatedEntityIdent = @intFromEntityIdent
		FROM
			ActivityType AT WITH (NOLOCK)
		WHERE
			AT.Ident = @intActivityTypeAddEntityConnectionIdent
			AND @intFromEntityIdent <> @intAddASUserIdent

	END

	-- to entity Ident
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
									WHEN @intEditASUserIdent = @intFromEntityIdent AND @intGenderIdent = 0 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@FromEntity','their network'),'@@ToEntity',@nvrToEntityFullname)
									WHEN @intEditASUserIdent = @intFromEntityIdent AND @intGenderIdent = 1 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@FromEntity','his network'),'@@ToEntity',@nvrToEntityFullname)
									WHEN @intEditASUserIdent = @intFromEntityIdent AND @intGenderIdent = 2 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@FromEntity','her network'),'@@ToEntity',@nvrToEntityFullname)
									ELSE REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@FromEntity',@nvrFromEntityFullname + '''s network'),'@@ToEntity',@nvrToEntityFullname)
									END,
		ClientIPAddress = '', -- unobtainable at this point
		RecordIdent = @intRecordIdent,
		CustomerEntityIdent = 0,
		UpdatedEntityIdent = @intToEntityIdent
	FROM
		ActivityType AT WITH (NOLOCK)
		INNER JOIN
		inserted ceNew WITH (NOLOCK)
			ON ceNew.Ident = @intRecordIdent
	WHERE
		AT.Ident = @intActivityTypeDeleteEntityConnectionIdent
		AND (ceNew.Active = 0)
		AND @intToEntityIdent <> @intAddASUserIdent

	-- from entity Ident
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
									WHEN @intEditASUserIdent = @intFromEntityIdent AND @intGenderIdent = 0 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@FromEntity','their network'),'@@ToEntity',@nvrToEntityFullname)
									WHEN @intEditASUserIdent = @intFromEntityIdent AND @intGenderIdent = 1 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@FromEntity','his network'),'@@ToEntity',@nvrToEntityFullname)
									WHEN @intEditASUserIdent = @intFromEntityIdent AND @intGenderIdent = 2 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@FromEntity','her network'),'@@ToEntity',@nvrToEntityFullname)
									ELSE REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@FromEntity',@nvrFromEntityFullname + '''s network'),'@@ToEntity',@nvrToEntityFullname)
									END,
		ClientIPAddress = '', -- unobtainable at this point
		RecordIdent = @intRecordIdent,
		CustomerEntityIdent = 0,
		UpdatedEntityIdent = @intFromEntityIdent
	FROM
		ActivityType AT WITH (NOLOCK)
		INNER JOIN
		inserted ceNew WITH (NOLOCK)
			ON ceNew.Ident = @intRecordIdent
	WHERE
		AT.Ident = @intActivityTypeDeleteEntityConnectionIdent
		AND (ceNew.Active = 0)
		AND @intFromEntityIdent <> @intAddASUserIdent

END

GO

