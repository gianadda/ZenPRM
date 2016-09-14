
DROP TRIGGER trg_EntityToDoEntityToDoCategoryXRefASUserActivityLog
GO 
CREATE TRIGGER trg_EntityToDoEntityToDoCategoryXRefASUserActivityLog ON EntityToDoEntityToDoCategoryXRef FOR INSERT, UPDATE
AS

-- we need to make sure something is actually edited
-- this will be null if we have a UPDATE with a WHERE clause that doesnt trigger an update
IF EXISTS(SELECT * FROM inserted)
BEGIN

	DECLARE @intActivityTypeAddEntityToDoEntityToDoCategoryXRefIdent BIGINT
	DECLARE @intActivityTypeDeleteEntityToDoEntityToDoCategoryXRefIdent BIGINT
	DECLARE @intRecordIdent BIGINT
	DECLARE @intCustomerEntityIdent BIGINT
	DECLARE @intRegardingEntityIdent BIGINT
	DECLARE @nvrTitle NVARCHAR(MAX)
	DECLARE @nvrCategory NVARCHAR(MAX)
	DECLARE @intEntityToDoIdent BIGINT
	DECLARE @intEntityToDoCategoryIdent BIGINT
	DECLARE @intEditASUserIdent BIGINT
	DECLARE @intAddASUserIdent BIGINT
	DECLARE @nvrUserFullname NVARCHAR(MAX)
	DECLARE @nvrRegardingEntityFullname NVARCHAR(MAX)
	DECLARE @dteGetDate DATETIME

	SET @dteGetDate = dbo.ufnGetMyDate()
	SET @intActivityTypeAddEntityToDoEntityToDoCategoryXRefIdent = dbo.ufnActivityTypeAddEntityToDoEntityToDoCategoryXRef()
	SET @intActivityTypeDeleteEntityToDoEntityToDoCategoryXRefIdent = dbo.ufnActivityTypeDeleteEntityToDoEntityToDoCategoryXRef()

	SELECT 
		@intRecordIdent = Ident,
		@intEntityToDoIdent = EntityToDoIdent,
		@intEntityToDoCategoryIdent = EntityToDoCategoryIdent,
		@intEditASUserIdent = EditASUserIdent,
		@intAddASUserIdent = AddASUserIdent
	FROM
		inserted

	SELECT
		@intRegardingEntityIdent = RegardingEntityIdent,
		@intCustomerEntityIdent = EntityIdent,
		@nvrTitle = Title
	FROM
		EntityToDo WITH (NOLOCK)
	WHERE
		Ident = @intEntityToDoIdent

	SELECT
		@nvrCategory = Name1
	FROM
		EntityToDoCategory WITH (NOLOCK)
	WHERE
		Ident = @intEntityToDoCategoryIdent

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
			ActivityDescription = REPLACE(REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@ToDo',@nvrTitle),'@@Entity',@nvrRegardingEntityFullname),'@@Category',@nvrCategory),
			ClientIPAddress = '', -- unobtainable at this point
			RecordIdent = @intRecordIdent,
			CustomerEntityIdent = @intCustomerEntityIdent,
			UpdatedEntityIdent = @intRegardingEntityIdent
		FROM
			ActivityType AT WITH (NOLOCK)
		WHERE
			AT.Ident = @intActivityTypeAddEntityToDoEntityToDoCategoryXRefIdent

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
		ActivityDescription = REPLACE(REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@ToDo',@nvrTitle),'@@Entity',@nvrRegardingEntityFullname),'@@Category',@nvrCategory),
		ClientIPAddress = '', -- unobtainable at this point
		RecordIdent = @intRecordIdent,
		CustomerEntityIdent = @intCustomerEntityIdent,
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
		AT.Ident = @intActivityTypeDeleteEntityToDoEntityToDoCategoryXRefIdent
		AND (ceNew.Active = 0)
	
END

GO

