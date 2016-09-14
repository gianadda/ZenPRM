
DROP TRIGGER trg_EntityHierarchyASUserActivityLog
GO 
CREATE TRIGGER trg_EntityHierarchyASUserActivityLog ON EntityHierarchy FOR INSERT, UPDATE
AS

-- we need to make sure something is actually edited
-- this will be null if we have a UPDATE with a WHERE clause that doesnt trigger an update
IF EXISTS(SELECT * FROM inserted)
BEGIN

	DECLARE @intActivityTypeAddEntityHierarchyIdent BIGINT
	DECLARE @intActivityTypeDeleteEntityHierarchyIdent BIGINT

	DECLARE @intRecordIdent BIGINT
	DECLARE @intHierarchyTypeIdent BIGINT
	DECLARE @intCustomerEntityIdent BIGINT
	DECLARE @intFromEntityIdent BIGINT
	DECLARE @intToEntityIdent BIGINT
	
	DECLARE @intEditASUserIdent BIGINT
	DECLARE @intAddASUserIdent BIGINT
	DECLARE @nvrUserFullname NVARCHAR(MAX)
	DECLARE @nvrEntityFullname NVARCHAR(MAX)
	DECLARE @nvrOrganizationFullname NVARCHAR(MAX)

	DECLARE @dteGetDate DATETIME

	SET @dteGetDate = dbo.ufnGetMyDate()	
	SET @intActivityTypeAddEntityHierarchyIdent = dbo.ufnActivityTypeAddEntityHierarchy()
	SET @intActivityTypeDeleteEntityHierarchyIdent = dbo.ufnActivityTypeDeleteEntityHierarchy()

	SELECT 
		@intRecordIdent = Ident,
		@intHierarchyTypeIdent = HierarchyTypeIdent,
		@intCustomerEntityIdent = EntityIdent,
		@intFromEntityIdent = FromEntityIdent,
		@intToEntityIdent = ToEntityIdent,
		@intEditASUserIdent = EditASUserIdent,
		@intAddASUserIdent = AddASUserIdent
	FROM
		inserted

	-- the entity we are connecting with
	SELECT
		@nvrEntityFullname = E.Fullname
	FROM
		Entity E WITH (NOLOCK)
		INNER JOIN
		inserted i WITH (NOLOCK)
			on I.ToEntityIdent = E.Ident

	-- the organization we are connecting with
	SELECT
		@nvrOrganizationFullname = E.Fullname
	FROM
		Entity E WITH (NOLOCK)
		INNER JOIN
		inserted i WITH (NOLOCK)
			on I.FromEntityIdent = E.Ident

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

		-- insert one record for the From entity
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
			ActivityDescription = REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Person',@nvrEntityFullname),'@@Organization',@nvrOrganizationFullname),
			ClientIPAddress = '', -- unobtainable at this point
			RecordIdent = @intRecordIdent,
			CustomerEntityIdent = @intCustomerEntityIdent,
			UpdatedEntityIdent = @intFromEntityIdent
		FROM
			ActivityType AT WITH (NOLOCK)
		WHERE
			AT.Ident = @intActivityTypeAddEntityHierarchyIdent

		-- insert one record for the To entity
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
			ActivityDescription = REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Person',@nvrEntityFullname),'@@Organization',@nvrOrganizationFullname),
			ClientIPAddress = '', -- unobtainable at this point
			RecordIdent = @intRecordIdent,
			CustomerEntityIdent = @intCustomerEntityIdent,
			UpdatedEntityIdent = @intToEntityIdent
		FROM
			ActivityType AT WITH (NOLOCK)
		WHERE
			AT.Ident = @intActivityTypeAddEntityHierarchyIdent

	END

	-- if not active, then a delete
	-- insert one record for the From entity
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
		ActivityDescription = REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Person',@nvrEntityFullname),'@@Organization',@nvrOrganizationFullname),
		ClientIPAddress = '', -- unobtainable at this point
		RecordIdent = @intRecordIdent,
		CustomerEntityIdent = @intCustomerEntityIdent,
		UpdatedEntityIdent = @intFromEntityIdent
	FROM
		ActivityType AT WITH (NOLOCK)
		INNER JOIN
		inserted ceNew WITH (NOLOCK)
			ON ceNew.Ident = @intRecordIdent
	WHERE
		AT.Ident = @intActivityTypeDeleteEntityHierarchyIdent
		AND (ceNew.Active = 0)

	-- if not active, then a delete
	-- insert one record for the To entity
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
		ActivityDescription = REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Person',@nvrEntityFullname),'@@Organization',@nvrOrganizationFullname),
		ClientIPAddress = '', -- unobtainable at this point
		RecordIdent = @intRecordIdent,
		CustomerEntityIdent = @intCustomerEntityIdent,
		UpdatedEntityIdent = @intToEntityIdent
	FROM
		ActivityType AT WITH (NOLOCK)
		INNER JOIN
		inserted ceNew WITH (NOLOCK)
			ON ceNew.Ident = @intRecordIdent
	WHERE
		AT.Ident = @intActivityTypeDeleteEntityHierarchyIdent
		AND (ceNew.Active = 0)

END

GO

