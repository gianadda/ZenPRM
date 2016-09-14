
DROP TRIGGER trg_EntityProjectEntityAnswerValue
GO 
CREATE TRIGGER trg_EntityProjectEntityAnswerValue ON EntityProjectEntityAnswerValue FOR INSERT, UPDATE
AS

-- we need to make sure something is actually edited
-- this will be null if we have a UPDATE with a WHERE clause that doesnt trigger an update
IF EXISTS(SELECT * FROM inserted)
BEGIN

	DECLARE @intRecordIdent BIGINT
	DECLARE @intEntityProjectEntityAnswerIdent BIGINT
	DECLARE @intEditASUserIdent BIGINT
	DECLARE @intAddASUserIdent BIGINT
	DECLARE @nvrName1 NVARCHAR(MAX)
	DECLARE @nvrValue1 NVARCHAR(MAX)
	DECLARE @nvrOldValue1 NVARCHAR(MAX)
	DECLARE @dteGetDate DATETIME

	SET @dteGetDate = dbo.ufnGetMyDate()

	SELECT 
		@intRecordIdent = Ident,
		@intEntityProjectEntityAnswerIdent = EntityProjectEntityAnswerIdent,
		@nvrName1 = Name1,
		@nvrValue1 = Value1,
		@intEditASUserIdent = EditASUserIdent,
		@intAddASUserIdent = AddASUserIdent
	FROM
		inserted

	SELECT
		@nvrOldValue1 = Value1
	FROM
		deleted
	
	--If there is no deleted, then it's an Add
	IF NOT EXISTS (SELECT * FROM deleted)
	BEGIN

		INSERT INTO EntityProjectEntityAnswerValueHistory(
			EntityProjectEntityAnswerValueIdent,
			EntityProjectEntityAnswerIdent,
			Name1,
			Value1,
			Active,
			AddDateTime,
			AddASUserIdent
		)
		SELECT
			EntityProjectEntityAnswerValueIdent = @intRecordIdent,
			EntityProjectEntityAnswerIdent = @intEntityProjectEntityAnswerIdent,
			Name1 = @nvrName1,
			Value1 = @nvrValue1,
			Active = 1,
			AddDateTime = @dteGetDate,
			AddASUserIdent = @intAddASUserIdent

	END -- IF NOT EXISTS (SELECT * FROM deleted)

	INSERT INTO EntityProjectEntityAnswerValueHistory(
		EntityProjectEntityAnswerValueIdent,
		EntityProjectEntityAnswerIdent,
		Name1,
		Value1,
		Active,
		AddDateTime,
		AddASUserIdent
	)
	SELECT
		EntityProjectEntityAnswerValueIdent = @intRecordIdent,
		EntityProjectEntityAnswerIdent = @intEntityProjectEntityAnswerIdent,
		Name1 = @nvrName1,
		Value1 = @nvrValue1,
		Active = 1,
		AddDateTime = @dteGetDate,
		AddASUserIdent = @intEditASUserIdent
	FROM
		inserted ceNew WITH (NOLOCK)
		INNER JOIN
		deleted ceOld WITH (NOLOCK)
			ON ceOld.Ident = ceNew.Ident
	WHERE
		ceNew.Ident = @intRecordIdent
		AND (ceNew.Name1 <> ceOld.Name1 
				OR ceNew.Value1 <> ceOld.Value1)

	-- check if the value changed, if so, then go check if the requirement is being tracked
	-- this should help speed up the trigger
	IF ((@nvrValue1 <> @nvrOldValue1) OR (@nvrOldValue1 IS NULL))

		BEGIN

			DECLARE @bntEntityProjectRequirementIdent BIGINT

			-- check and see if the requirement has a measure attached
			SELECT
				@bntEntityProjectRequirementIdent = A.EntityProjectRequirementIdent
			FROM
				EntityProjectEntityAnswer A WITH (NOLOCK)
			WHERE
				A.Ident = @intEntityProjectEntityAnswerIdent

			-- if so, mark it to recalculate
			UPDATE
				EntityProjectMeasure
			SET
				Recalculate = 1
			WHERE
				Question1EntityProjectRequirementIdent = @bntEntityProjectRequirementIdent

			-- check Q2 as well
			UPDATE
				EntityProjectMeasure
			SET
				Recalculate = 1
			WHERE
				Question2EntityProjectRequirementIdent = @bntEntityProjectRequirementIdent

		END

END

GO

