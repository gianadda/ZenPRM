
DROP TRIGGER trg_EntityProjectEntityASUserActivityLog
GO 
CREATE TRIGGER trg_EntityProjectEntityASUserActivityLog ON EntityProjectEntity FOR INSERT, UPDATE
AS

-- we need to make sure something is actually edited
-- this will be null if we have a UPDATE with a WHERE clause that doesnt trigger an update
IF EXISTS(SELECT * FROM inserted)
BEGIN

	DECLARE @intActivityTypeAddEntityProjectEntityIdent BIGINT
	DECLARE @intActivityTypeDeleteEntityProjectEntityIdent BIGINT
	DECLARE @intRecordIdent BIGINT
	DECLARE @intCustomerEntityIdent BIGINT
	DECLARE @intEntityIdent BIGINT
	DECLARE @intEntityProjectEntityIdent BIGINT
	DECLARE @intEditASUserIdent BIGINT
	DECLARE @intAddASUserIdent BIGINT
	DECLARE @nvrUserFullname NVARCHAR(MAX)
	DECLARE @nvrEntityFullname NVARCHAR(MAX)
	DECLARE @nvrEntityProjectEntityName1 NVARCHAR(MAX)
	DECLARE @nvrEntityProjectName1 NVARCHAR(MAX)
	DECLARE @dteGetDate DATETIME
	DECLARE @bntEntityProjectIdent BIGINT

	SET @dteGetDate = dbo.ufnGetMyDate()
	SET @intActivityTypeAddEntityProjectEntityIdent = dbo.ufnActivityTypeAddEntityProjectEntity()
	SET @intActivityTypeDeleteEntityProjectEntityIdent = dbo.ufnActivityTypeDeleteEntityProjectEntity()

	SELECT 
		@intRecordIdent = Ident,
		@intEntityProjectEntityIdent = EntityIdent ,
		@intEditASUserIdent = EditASUserIdent,
		@intAddASUserIdent = AddASUserIdent
	FROM
		inserted

	SELECT
		@nvrEntityProjectEntityName1 = E.Fullname,
		@intEntityIdent = E.Ident
	FROM
		EntityProjectEntity EPE WITH (NOLOCK)
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = EPE.EntityIdent
	WHERE
		EPE.Ident = @intRecordIdent

	SELECT
		@nvrEntityProjectName1 = EP.Name1,
		@intCustomerEntityIdent = EP.EntityIdent,
		@bntEntityProjectIdent = EP.Ident
	FROM
		EntityProjectEntity EPE WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = EPE.EntityProjectIdent
	WHERE
		EPE.Ident = @intRecordIdent

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
			ActivityDescription = REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Project',@nvrEntityProjectName1),'@@EntityProjectEntity',@nvrEntityProjectEntityName1),
			ClientIPAddress = '', -- unobtainable at this point
			RecordIdent = @intRecordIdent,
			CustomerEntityIdent = @intCustomerEntityIdent,
			UpdatedEntityIdent = @intEntityIdent
		FROM
			ActivityType AT WITH (NOLOCK)
		WHERE
			AT.Ident = @intActivityTypeAddEntityProjectEntityIdent

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
		ActivityDescription = REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Project',@nvrEntityProjectName1),'@@EntityProjectEntity',@nvrEntityProjectEntityName1),
		ClientIPAddress = '', -- unobtainable at this point
		RecordIdent = @intRecordIdent,
		CustomerEntityIdent = @intCustomerEntityIdent,
		UpdatedEntityIdent = @intEntityIdent
	FROM
		ActivityType AT WITH (NOLOCK)
		INNER JOIN
		inserted ceNew WITH (NOLOCK)
			ON ceNew.Ident = @intRecordIdent
	WHERE
		AT.Ident = @intActivityTypeDeleteEntityProjectEntityIdent
		AND (ceNew.Active = 0)

	-- figure out if the added or removed participant from the project affects the measure
	-- if so, mark it to recalculate

	-- Question 1
	UPDATE
		EPM
	SET
		Recalculate = 1
	FROM
		EntityProjectMeasure EPM WITH (NOLOCK)
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.Ident = EPM.Question1EntityProjectRequirementIdent
	WHERE
		EPR.EntityProjectIdent = @bntEntityProjectIdent

	-- Question 2
	UPDATE
		EPM
	SET
		Recalculate = 1
	FROM
		EntityProjectMeasure EPM WITH (NOLOCK)
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.Ident = EPM.Question2EntityProjectRequirementIdent
	WHERE
		EPM.Question2EntityProjectRequirementIdent > 0
		AND EPR.EntityProjectIdent = @bntEntityProjectIdent

END

GO

