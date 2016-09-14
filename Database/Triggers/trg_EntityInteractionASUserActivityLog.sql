
DROP TRIGGER trg_EntityInteractionASUserActivityLog
GO 
CREATE TRIGGER trg_EntityInteractionASUserActivityLog ON EntityInteraction FOR INSERT, UPDATE
AS

-- we need to make sure something is actually edited
-- this will be null if we have a UPDATE with a WHERE clause that doesnt trigger an update
IF EXISTS(SELECT * FROM inserted)
BEGIN

	DECLARE @intActivityTypeAddEntityInteractionIdent BIGINT
	DECLARE @intActivityTypeEditEntityInteractionIdent BIGINT
	DECLARE @intActivityTypeDeleteEntityInteractionIdent BIGINT

	DECLARE @intRecordIdent BIGINT
	DECLARE @intFromEntityIdent BIGINT
	DECLARE @intToEntityIdent BIGINT
	DECLARE @nvrInteractionText NVARCHAR(MAX)
	
	DECLARE @intEditASUserIdent BIGINT
	DECLARE @intAddASUserIdent BIGINT
	DECLARE @nvrUserFullname NVARCHAR(MAX)
	DECLARE @nvrEntityFullname NVARCHAR(MAX)

	DECLARE @intASUserActivityIdent BIGINT
	DECLARE @dteGetDate DATETIME

	SET @dteGetDate = dbo.ufnGetMyDate()	
	SET @intActivityTypeAddEntityInteractionIdent = dbo.ufnActivityTypeAddEntityInteraction()
	SET @intActivityTypeEditEntityInteractionIdent = dbo.ufnActivityTypeEditEntityInteraction()
	SET @intActivityTypeDeleteEntityInteractionIdent = dbo.ufnActivityTypeDeleteEntityInteraction()

	SELECT 
		@intRecordIdent = Ident,
		@intFromEntityIdent = FromEntityIdent ,
		@intToEntityIdent = ToEntityIdent ,
		@nvrInteractionText = InteractionText ,
		@intEditASUserIdent = EditASUserIdent,
		@intAddASUserIdent = AddASUserIdent
	FROM
		inserted

	-- the entity we are interacting with
	SELECT
		@nvrEntityFullname = E.Fullname
	FROM
		Entity E WITH (NOLOCK)
		INNER JOIN
		inserted i WITH (NOLOCK)
			on I.ToEntityIdent = E.Ident

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
			ActivityDescription = REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@EntityName',@nvrEntityFullname),
			ClientIPAddress = '', -- unobtainable at this point
			RecordIdent = @intRecordIdent,
			CustomerEntityIdent = @intFromEntityIdent,
			UpdatedEntityIdent = @intToEntityIdent
		FROM
			ActivityType AT WITH (NOLOCK)
		WHERE
			AT.Ident = @intActivityTypeAddEntityInteractionIdent

	END

	-- if not active, then a delete
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
		ActivityDescription = REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@EntityName',@nvrEntityFullname),
		ClientIPAddress = '', -- unobtainable at this point
		RecordIdent = @intRecordIdent,
		CustomerEntityIdent = @intFromEntityIdent,
		UpdatedEntityIdent = @intToEntityIdent
	FROM
		ActivityType AT WITH (NOLOCK)
		INNER JOIN
		inserted ceNew WITH (NOLOCK)
			ON ceNew.Ident = @intRecordIdent
	WHERE
		AT.Ident = @intActivityTypeDeleteEntityInteractionIdent
		AND (ceNew.Active = 0)

	-- else an edit
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
		ActivityDescription = REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@EntityName',@nvrEntityFullname),
		ClientIPAddress = '', -- unobtainable at this point
		RecordIdent = @intRecordIdent,
		CustomerEntityIdent = @intFromEntityIdent,
		UpdatedEntityIdent = @intToEntityIdent
	FROM
		ActivityType AT WITH (NOLOCK)
		INNER JOIN
		inserted ceNew WITH (NOLOCK)
			ON ceNew.Ident = @intRecordIdent
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceOld.Ident = ceNew.Ident
	WHERE
		AT.Ident = @intActivityTypeEditEntityInteractionIdent
		AND (ceNew.Active = 1)
		AND (ceNew.Important <> ceOld.Important
				OR ceNew.InteractionText <> ceOld.InteractionText)

	SET @intASUserActivityIdent = SCOPE_IDENTITY()

	-- if there is no delete, then we just need to insert the current interaction
	IF NOT EXISTS (SELECT * FROM deleted)
		BEGIN

			INSERT INTO ASUserActivityDetail (
				ASUserActivityIdent,
				FieldName,
				OldValue,
				NewValue
			)
			SELECT
				ASUserActivityIdent = @intASUserActivityIdent,
				FieldName = 'Note',
				OldValue = '',
				NewValue = ceNew.InteractionText
			FROM
				inserted ceNew WITH (NOLOCK)

		END
	ELSE
		BEGIN
	
			INSERT INTO ASUserActivityDetail (
				ASUserActivityIdent,
				FieldName,
				OldValue,
				NewValue
			)
			SELECT
				ASUserActivityIdent = @intASUserActivityIdent,
				FieldName = 'Note',
				OldValue = ceOld.InteractionText,
				NewValue = ceNew.InteractionText
			FROM
				inserted ceNew WITH (NOLOCK)
				INNER JOIN
				deleted ceOld WITH (NOLOCK)
					ON ceNew.Ident = ceOld.Ident
			WHERE
				ceNew.InteractionText <> ceOld.InteractionText

		END


END

GO

