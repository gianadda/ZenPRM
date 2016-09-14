
DROP TRIGGER trg_EntityOtherIDASUserActivityLog
GO 
CREATE TRIGGER trg_EntityOtherIDASUserActivityLog ON EntityOtherID FOR INSERT, UPDATE
AS

-- we need to make sure something is actually edited
-- this will be null if we have a UPDATE with a WHERE clause that doesnt trigger an update
IF EXISTS(SELECT * FROM inserted)
BEGIN

	DECLARE @intActivityTypeAddEntityOtherIDIdent BIGINT
	DECLARE @intActivityTypeEditEntityOtherIDIdent BIGINT
	DECLARE @intActivityTypeDeleteEntityOtherIDIdent BIGINT
	DECLARE @intRecordIdent BIGINT
	DECLARE @intEntityIdent BIGINT
	DECLARE @intEditASUserIdent BIGINT
	DECLARE @intAddASUserIdent BIGINT
	DECLARE @intGenderIdent BIGINT
	DECLARE @nvrUserFullname NVARCHAR(MAX)
	DECLARE @nvrEntityFullname NVARCHAR(MAX)
	DECLARE @intASUserActivityIdent BIGINT
	DECLARE @nvrIDType NVARCHAR(MAX)
	DECLARE @dteGetDate DATETIME

	SET @dteGetDate = dbo.ufnGetMyDate()
	SET @intActivityTypeAddEntityOtherIDIdent = dbo.ufnActivityTypeAddEntityOtherID()
	SET @intActivityTypeEditEntityOtherIDIdent = dbo.ufnActivityTypeEditEntityOtherID()
	SET @intActivityTypeDeleteEntityOtherIDIdent = dbo.ufnActivityTypeDeleteEntityOtherID()

	SELECT 
		@intRecordIdent = Ident,
		@intEntityIdent = EntityIdent ,
		@nvrIDType = IDType,
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
									WHEN @intAddASUserIdent = @intEntityIdent AND @intGenderIdent = 0 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','their'),'@@OtherID',@nvrIDType)
									WHEN @intAddASUserIdent = @intEntityIdent AND @intGenderIdent = 1 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','his'),'@@OtherID',@nvrIDType)
									WHEN @intAddASUserIdent = @intEntityIdent AND @intGenderIdent = 2 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','her'),'@@OtherID',@nvrIDType)
									ELSE REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity',@nvrEntityFullname + '''s'),'@@OtherID',@nvrIDType)
									END,
			ClientIPAddress = '', -- unobtainable at this point
			RecordIdent = @intRecordIdent,
			CustomerEntityIdent = 0,
			UpdatedEntityIdent = @intEntityIdent
		FROM
			ActivityType AT WITH (NOLOCK)
		WHERE
			AT.Ident = @intActivityTypeAddEntityOtherIDIdent

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
								WHEN @intEditASUserIdent = @intEntityIdent AND @intGenderIdent = 0 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','their'),'@@OtherID',@nvrIDType)
								WHEN @intEditASUserIdent = @intEntityIdent AND @intGenderIdent = 1 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','his'),'@@OtherID',@nvrIDType)
								WHEN @intEditASUserIdent = @intEntityIdent AND @intGenderIdent = 2 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','her'),'@@OtherID',@nvrIDType)
								ELSE REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity',@nvrEntityFullname + '''s'),'@@OtherID',@nvrIDType)
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
		AT.Ident = @intActivityTypeDeleteEntityOtherIDIdent
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
								WHEN @intEditASUserIdent = @intEntityIdent AND @intGenderIdent = 0 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','their'),'@@OtherID',@nvrIDType)
								WHEN @intEditASUserIdent = @intEntityIdent AND @intGenderIdent = 1 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','his'),'@@OtherID',@nvrIDType)
								WHEN @intEditASUserIdent = @intEntityIdent AND @intGenderIdent = 2 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','her'),'@@OtherID',@nvrIDType)
								ELSE REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity',@nvrEntityFullname + '''s'),'@@OtherID',@nvrIDType)
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
		AT.Ident = @intActivityTypeEditEntityOtherIDIdent
		AND (ceNew.Active = 1)
		AND (ceNew.IDType <> ceOld.IDType
				OR ceNew.IDNumber <> ceOld.IDNumber)

	SET @intASUserActivityIdent = SCOPE_IDENTITY()

	INSERT INTO ASUserActivityDetail (
		ASUserActivityIdent,
		FieldName,
		OldValue,
		NewValue
	)
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'IDType',
		OldValue = ceOld.IDType,
		NewValue = ceNew.IDType
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.IDType <> ceOld.IDType

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'IDNumber',
		OldValue = ceOld.IDNumber,
		NewValue = ceNew.IDNumber
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.IDNumber <> ceOld.IDNumber

END

GO

