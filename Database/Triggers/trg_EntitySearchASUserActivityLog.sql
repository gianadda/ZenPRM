
DROP TRIGGER trg_EntitySearchASUserActivityLog
GO 
CREATE TRIGGER trg_EntitySearchASUserActivityLog ON EntitySearch FOR INSERT, UPDATE
AS

-- we need to make sure something is actually edited
-- this will be null if we have a UPDATE with a WHERE clause that doesnt trigger an update
IF EXISTS(SELECT * FROM inserted)
BEGIN

	DECLARE @intActivityTypeAddEntitySearchIdent BIGINT
	DECLARE @intActivityTypeEditEntitySearchIdent BIGINT
	DECLARE @intActivityTypeDeleteEntitySearchIdent BIGINT
	DECLARE @intRecordIdent BIGINT
	DECLARE @intCustomerEntityIdent BIGINT
	DECLARE @intEditASUserIdent BIGINT
	DECLARE @intAddASUserIdent BIGINT
	DECLARE @nvrUserFullName NVARCHAR(MAX)
	DECLARE @nvrName1 NVARCHAR(MAX)
	DECLARE @nvrDesc1 NVARCHAR(MAX)
	DECLARE @nvrCategory NVARCHAR(MAX)
	DECLARE @nvrKeyword NVARCHAR(MAX)
	DECLARE @nvrLocation NVARCHAR(MAX)
	DECLARE @bitBookmarkSearch BIT
	DECLARE @decLatitude DECIMAL(20,8)
	DECLARE @decLongitude DECIMAL(20,8)
	DECLARE @intDistanceInMiles INT
	DECLARE @dteGetDate DATETIME
	DECLARE @intASUserActivityIdent BIGINT

	SET @dteGetDate = dbo.ufnGetMyDate()
	SET @intActivityTypeAddEntitySearchIdent = dbo.ufnActivityTypeAddEntitySearch()
	SET @intActivityTypeEditEntitySearchIdent = dbo.ufnActivityTypeEditEntitySearch()
	SET @intActivityTypeDeleteEntitySearchIdent = dbo.ufnActivityTypeDeleteEntitySearch()

	SELECT 
		@intRecordIdent = Ident,
		@intCustomerEntityIdent = EntityIdent,
		@nvrName1 = Name1,
		@nvrKeyword = Keyword,
		@nvrLocation = Location,
		@decLatitude = Latitude,
		@decLongitude = Longitude,
		@intDistanceInMiles = DistanceInMiles,
		@nvrDesc1 = Desc1,
		@nvrCategory = Category,
		@bitBookmarkSearch = BookmarkSearch,
		@intEditASUserIdent = EditASUserIdent,
		@intAddASUserIdent = AddASUserIdent
	FROM
		inserted

	-- assume user is editing, well override add in the next clause if need be
	SELECT
		@nvrUserFullName = E.FullName
	FROM
		Entity E WITH (NOLOCK)
	WHERE
		@intEditASUserIdent > 0
		AND E.Ident = @intEditASUserIdent

	--If there is no deleted, then it's an Add
	IF NOT EXISTS (SELECT * FROM deleted)
	BEGIN

		SELECT
			@nvrUserFullName = E.FullName
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
			ActivityDescription = REPLACE(REPLACE(AT.Desc1,'@@Segment',@nvrName1),'@@Name',@nvrUserFullName),
			ClientIPAddress = '', -- unobtainable at this point
			RecordIdent = @intRecordIdent,
			CustomerEntityIdent = @intCustomerEntityIdent,
			UpdatedEntityIdent = @intCustomerEntityIdent
		FROM
			ActivityType AT WITH (NOLOCK)
		WHERE
			AT.Ident = @intActivityTypeAddEntitySearchIdent

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
		ActivityDescription = REPLACE(REPLACE(AT.Desc1,'@@Segment',@nvrName1),'@@Name',@nvrUserFullName),
		ClientIPAddress = '', -- unobtainable at this point
		RecordIdent = @intRecordIdent,
		CustomerEntityIdent = @intCustomerEntityIdent,
		UpdatedEntityIdent = @intCustomerEntityIdent
	FROM
		ActivityType AT WITH (NOLOCK)
		INNER JOIN
		inserted ceNew WITH (NOLOCK)
			ON ceNew.Ident = @intRecordIdent
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceOld.Ident = ceNew.Ident
	WHERE
		AT.Ident = @intActivityTypeDeleteEntitySearchIdent
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
		ActivityDescription = REPLACE(REPLACE(AT.Desc1,'@@Segment',@nvrName1),'@@Name',@nvrUserFullName),
		ClientIPAddress = '', -- unobtainable at this point
		RecordIdent = @intRecordIdent,
		CustomerEntityIdent = @intCustomerEntityIdent,
		UpdatedEntityIdent = @intCustomerEntityIdent
	FROM
		ActivityType AT WITH (NOLOCK)
		INNER JOIN
		inserted ceNew WITH (NOLOCK)
			ON ceNew.Ident = @intRecordIdent
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceOld.Ident = ceNew.Ident
	WHERE
		AT.Ident = @intActivityTypeEditEntitySearchIdent
		AND (ceNew.Active = 1)
		AND (ceNew.Keyword <> ceOld.Keyword
				OR ceNew.Location <> ceOld.Location
				OR ceNew.Latitude <> ceOld.Latitude
				OR ceNew.Longitude <> ceOld.Longitude
				OR ceNew.DistanceInMiles <> ceOld.DistanceInMiles
				OR ceNew.Desc1 <> ceOld.Desc1
				OR ceNew.Category <> ceOld.Category
				OR ceNew.BookmarkSearch <> ceOld.BookmarkSearch)

	SET @intASUserActivityIdent = SCOPE_IDENTITY()

	INSERT INTO ASUserActivityDetail (
		ASUserActivityIdent,
		FieldName,
		OldValue,
		NewValue
	)
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Keyword',
		OldValue = ceOld.Keyword,
		NewValue = ceNew.Keyword
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.Keyword <> ceOld.Keyword

	INSERT INTO ASUserActivityDetail (
		ASUserActivityIdent,
		FieldName,
		OldValue,
		NewValue
	)
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Location',
		OldValue = ceOld.Location,
		NewValue = ceNew.Location
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.Location <> ceOld.Location

	INSERT INTO ASUserActivityDetail (
		ASUserActivityIdent,
		FieldName,
		OldValue,
		NewValue
	)
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Latitude',
		OldValue = ceOld.Latitude,
		NewValue = ceNew.Latitude
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.Latitude <> ceOld.Latitude
		
	INSERT INTO ASUserActivityDetail (
		ASUserActivityIdent,
		FieldName,
		OldValue,
		NewValue
	)
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Longitude',
		OldValue = ceOld.Longitude,
		NewValue = ceNew.Longitude
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.Longitude <> ceOld.Longitude

	INSERT INTO ASUserActivityDetail (
		ASUserActivityIdent,
		FieldName,
		OldValue,
		NewValue
	)
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Distance (In Miles)',
		OldValue = ceOld.DistanceInMiles,
		NewValue = ceNew.DistanceInMiles
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.DistanceInMiles <> ceOld.DistanceInMiles

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

	INSERT INTO ASUserActivityDetail (
		ASUserActivityIdent,
		FieldName,
		OldValue,
		NewValue
	)
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Category',
		OldValue = ceOld.Category,
		NewValue = ceNew.Category
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.Category <> ceOld.Category
		
	INSERT INTO ASUserActivityDetail (
		ASUserActivityIdent,
		FieldName,
		OldValue,
		NewValue
	)
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Bookmarked',
		OldValue = ceOld.BookmarkSearch,
		NewValue = ceNew.BookmarkSearch
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.BookmarkSearch <> ceOld.BookmarkSearch

END

GO

