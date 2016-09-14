
DROP TRIGGER trg_EntityProjectMeasureASUserActivityLog
GO 
CREATE TRIGGER trg_EntityProjectMeasureASUserActivityLog ON EntityProjectMeasure FOR INSERT, UPDATE
AS

-- we need to make sure something is actually edited
-- this will be null if we have a UPDATE with a WHERE clause that doesnt trigger an update
IF EXISTS(SELECT * FROM inserted)
BEGIN

	DECLARE @intActivityTypeAddEntityProjectMeasureIdent BIGINT
	DECLARE @intActivityTypeEditEntityProjectMeasureIdent BIGINT
	DECLARE @intActivityTypeDeleteEntityProjectMeasureIdent BIGINT
	DECLARE @intRecordIdent BIGINT
	DECLARE @nvrName1 NVARCHAR(MAX)
	DECLARE @nvrDesc1 NVARCHAR(MAX)
	DECLARE @bntMeasureTypeIdent BIGINT
	DECLARE @bntQuestion1EntityProjectRequirementIdent BIGINT
	DECLARE @bntQuestion2EntityProjectRequirementIdent BIGINT
	DECLARE @decTargetValue DECIMAL(20,4)
	DECLARE @intEditASUserIdent BIGINT
	DECLARE @intAddASUserIdent BIGINT
	DECLARE @nvrUserFullname NVARCHAR(MAX)
	DECLARE @intASUserActivityIdent BIGINT
	DECLARE @intEntityIdent BIGINT
	DECLARE @dteGetDate DATETIME

	SET @dteGetDate = dbo.ufnGetMyDate()
	SET @intActivityTypeAddEntityProjectMeasureIdent = dbo.ufnActivityTypeAddEntityProjectMeasure()
	SET @intActivityTypeEditEntityProjectMeasureIdent = dbo.ufnActivityTypeEditEntityProjectMeasure()
	SET @intActivityTypeDeleteEntityProjectMeasureIdent = dbo.ufnActivityTypeDeleteEntityProjectMeasure()

	SELECT 
		@intRecordIdent = Ident,
		
		@nvrName1 = Name1,
		@nvrDesc1 = Desc1,
		@bntMeasureTypeIdent = MeasureTypeIdent,
		@bntQuestion1EntityProjectRequirementIdent = Question1EntityProjectRequirementIdent,
		@bntQuestion2EntityProjectRequirementIdent = Question2EntityProjectRequirementIdent,
		@decTargetValue = TargetValue,
		@intEditASUserIdent = EditASUserIdent,
		@intAddASUserIdent = AddASUserIdent
	FROM
		inserted

	SELECT
		@intEntityIdent = EP.EntityIdent
	FROM
		EntityProject EP WITH (NOLOCK)
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.EntityProjectIdent = EP.Ident
	WHERE
		EPR.Ident = @bntQuestion1EntityProjectRequirementIdent -- it doesnt matter if we use Q1 or Q2 here, they will always be the same customer Ident

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
			ActivityDescription = REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@MeasureName1',@nvrName1),
			ClientIPAddress = '', -- unobtainable at this point
			RecordIdent = @intRecordIdent,
			CustomerEntityIdent = @intEntityIdent,
			UpdatedEntityIdent = 0
		FROM
			ActivityType AT WITH (NOLOCK)
		WHERE
			AT.Ident = @intActivityTypeAddEntityProjectMeasureIdent

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
		ActivityDescription = REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@MeasureName1',@nvrName1),
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
		AT.Ident = @intActivityTypeDeleteEntityProjectMeasureIdent
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
		ActivityDescription = REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@MeasureName1',@nvrName1),
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
		AT.Ident = @intActivityTypeEditEntityProjectMeasureIdent
		AND (ceNew.Active = 1)
		AND (ceNew.Name1 <> ceOld.Name1
				OR ceNew.Desc1 <> ceOld.Desc1
				OR ceNew.MeasureTypeIdent <> ceOld.MeasureTypeIdent
				OR ceNew.Question1EntityProjectRequirementIdent <> ceOld.Question1EntityProjectRequirementIdent
				OR ceNew.Question2EntityProjectRequirementIdent <> ceOld.Question2EntityProjectRequirementIdent
				OR ceNew.TargetValue <> ceOld.TargetValue)

	SET @intASUserActivityIdent = SCOPE_IDENTITY()

	INSERT INTO ASUserActivityDetail (
		ASUserActivityIdent,
		FieldName,
		OldValue,
		NewValue
	)
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Name',
		OldValue = ceOld.Name1,
		NewValue = ceNew.Name1
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.Name1 <> ceOld.Name1

	UNION ALL
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

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Target Value',
		OldValue = CAST(ceOld.TargetValue AS NVARCHAR(MAX)),
		NewValue = CAST(ceNew.TargetValue AS NVARCHAR(MAX))
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
	WHERE
		ceNew.TargetValue <> ceOld.TargetValue

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Measure Type',
		OldValue = oldMT.Name1,
		NewValue = newMT.Name1
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
		INNER JOIN
		MeasureType oldMT WITH (NOLOCK)
			ON oldMT.Ident = ceOld.MeasureTypeIdent
		INNER JOIN
		MeasureType newMT WITH (NOLOCK)
			ON newMT.Ident = ceOld.MeasureTypeIdent
	WHERE
		ceNew.MeasureTypeIdent <> ceOld.MeasureTypeIdent

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Question 1',
		OldValue = oEPR.Label,
		NewValue = nEPR.Label
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
		INNER JOIN
		EntityProjectRequirement oEPR WITH (NOLOCK)
			ON oEPR.Ident = ceOld.Question1EntityProjectRequirementIdent
		INNER JOIN
		EntityProjectRequirement nEPR WITH (NOLOCK)
			ON nEPR.Ident = ceNew.Question1EntityProjectRequirementIdent
	WHERE
		ceNew.Question1EntityProjectRequirementIdent <> ceOld.Question1EntityProjectRequirementIdent

	UNION ALL
	SELECT
		ASUserActivityIdent = @intASUserActivityIdent,
		FieldName = 'Question 2',
		OldValue = oEPR.Label,
		NewValue = nEPR.Label
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceNew.Ident = ceOld.Ident
		INNER JOIN
		EntityProjectRequirement oEPR WITH (NOLOCK)
			ON oEPR.Ident = ceOld.Question2EntityProjectRequirementIdent
		INNER JOIN
		EntityProjectRequirement nEPR WITH (NOLOCK)
			ON nEPR.Ident = ceNew.Question2EntityProjectRequirementIdent
	WHERE
		ceNew.Question2EntityProjectRequirementIdent <> ceOld.Question2EntityProjectRequirementIdent


END

GO

