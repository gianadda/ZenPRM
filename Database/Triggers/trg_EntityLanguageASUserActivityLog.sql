
DROP TRIGGER trg_EntityLanguageASUserActivityLog
GO 
CREATE TRIGGER trg_EntityLanguageASUserActivityLog ON EntityLanguage1XRef FOR INSERT, UPDATE
AS

-- we need to make sure something is actually edited
-- this will be null if we have a UPDATE with a WHERE clause that doesnt trigger an update
IF EXISTS(SELECT * FROM inserted)
BEGIN

	DECLARE @intActivityTypeAddEntityLanguageIdent BIGINT
	DECLARE @intActivityTypeDeleteEntityLanguageIdent BIGINT
	DECLARE @intRecordIdent BIGINT
	DECLARE @intEntityIdent BIGINT
	DECLARE @intLanguageIdent BIGINT
	DECLARE @intEditASUserIdent BIGINT
	DECLARE @intAddASUserIdent BIGINT
	DECLARE @intGenderIdent BIGINT
	DECLARE @nvrUserFullname NVARCHAR(MAX)
	DECLARE @nvrEntityFullname NVARCHAR(MAX)
	DECLARE @nvrLanguageName1 NVARCHAR(400)
	DECLARE @dteGetDate DATETIME

	SET @dteGetDate = dbo.ufnGetMyDate()
	SET @intActivityTypeAddEntityLanguageIdent = dbo.ufnActivityTypeAddEntityLanguage()
	SET @intActivityTypeDeleteEntityLanguageIdent = dbo.ufnActivityTypeDeleteEntityLanguage()

	SELECT 
		@intRecordIdent = Ident,
		@intEntityIdent = EntityIdent ,
		@intLanguageIdent = Language1Ident ,
		@intEditASUserIdent = EditASUserIdent,
		@intAddASUserIdent = AddASUserIdent
	FROM
		inserted

	SELECT
		@nvrLanguageName1 = Name1
	FROM
		Language1 WITH (NOLOCK)
	WHERE
		Ident = @intLanguageIdent

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
									WHEN @intAddASUserIdent = @intEntityIdent AND @intGenderIdent = 0 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','their'),'@@Language',@nvrLanguageName1)
									WHEN @intAddASUserIdent = @intEntityIdent AND @intGenderIdent = 1 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','his'),'@@Language',@nvrLanguageName1)
									WHEN @intAddASUserIdent = @intEntityIdent AND @intGenderIdent = 2 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','her'),'@@Language',@nvrLanguageName1)
									ELSE REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity',@nvrEntityFullname + '''s'),'@@Language',@nvrLanguageName1)
									END,
			ClientIPAddress = '', -- unobtainable at this point
			RecordIdent = @intRecordIdent,
			CustomerEntityIdent = 0,
			UpdatedEntityIdent = @intEntityIdent
		FROM
			ActivityType AT WITH (NOLOCK)
		WHERE
			AT.Ident = @intActivityTypeAddEntityLanguageIdent

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
								WHEN @intEditASUserIdent = @intEntityIdent AND @intGenderIdent = 0 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','their'),'@@Language',@nvrLanguageName1)
								WHEN @intEditASUserIdent = @intEntityIdent AND @intGenderIdent = 1 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','his'),'@@Language',@nvrLanguageName1)
								WHEN @intEditASUserIdent = @intEntityIdent AND @intGenderIdent = 2 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','her'),'@@Language',@nvrLanguageName1)
								ELSE REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity',@nvrEntityFullname + '''s'),'@@Language',@nvrLanguageName1)
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
	WHERE
		AT.Ident = @intActivityTypeDeleteEntityLanguageIdent
		AND (ceNew.Active = 0)

END

GO

