IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetOptionListValueCount') 
	AND OBJECTPROPERTY(id, N'IsTableFunction') = 1)
DROP FUNCTION ufnGetOptionListValueCount
GO

/* ufnGetOptionListValueCount
 *
 * Returns the answered value options for a specific question
 *
 *
*/
CREATE FUNCTION ufnGetOptionListValueCount(@tblEntity AS [EntitySearchOutput] READONLY, @bntEntityProjectRequirementIdent BIGINT)
RETURNS @tblResults TABLE
	(
		Value1 NVARCHAR(MAX),
		ValueCount BIGINT
	)
AS

	BEGIN
	
		DECLARE @intValueCount BIGINT
		DECLARE @nvrOther NVARCHAR(5) = dbo.ufnGetEntityProjectMeasureOther()
		DECLARE @intEntityProjectMeasureMaxValueCount INT = dbo.ufnGetEntityProjectMeasureMaxValueCount()
		DECLARE @intEntityProjectMeasureInsertCount INT = (@intEntityProjectMeasureMaxValueCount - 1)

		DECLARE @tblOptions TABLE (
			Value1 NVARCHAR(MAX),
			ValueCount BIGINT
		)

		INSERT INTO @tblOptions(
			Value1,
			ValueCount
		)
		SELECT
			Value1 = V.Name1,
			ValueCount = COUNT(*)
		FROM
			EntityProjectRequirement EPR WITH (NOLOCK)
			INNER JOIN
			RequirementType RT WITH (NOLOCK)
				ON RT.Ident = EPR.RequirementTypeIdent
			INNER JOIN
			EntityProjectEntityAnswer A WITH (NOLOCK)
				ON A.EntityProjectRequirementIdent = EPR.Ident
			INNER JOIN
			EntityProjectEntity EPE WITH (NOLOCK)
				ON EPE.Ident = A.EntityProjectEntityIdent
			INNER JOIN
			@tblEntity tE
				ON tE.EntityIdent = EPE.EntityIdent
			INNER JOIN
			EntityProjectEntityAnswerValue V WITH (NOLOCK)
				ON V.EntityProjectEntityAnswerIdent = A.Ident
		WHERE
			EPR.Ident = @bntEntityProjectRequirementIdent
			AND RT.AllowMultipleOptions = 1
			AND A.Active = 1
			AND EPE.Active = 1
			AND V.Active = 1
			AND UPPER(V.Value1) = 'TRUE'
		GROUP BY
			V.Name1
		UNION ALL
		SELECT
			Value1 = V.Value1,
			ValueCount = COUNT(*)
		FROM
			EntityProjectRequirement EPR WITH (NOLOCK)
			INNER JOIN
			RequirementType RT WITH (NOLOCK)
				ON RT.Ident = EPR.RequirementTypeIdent
			INNER JOIN
			EntityProjectEntityAnswer A WITH (NOLOCK)
				ON A.EntityProjectRequirementIdent = EPR.Ident
			INNER JOIN
			EntityProjectEntity EPE WITH (NOLOCK)
				ON EPE.Ident = A.EntityProjectEntityIdent
			INNER JOIN
			@tblEntity tE
				ON tE.EntityIdent = EPE.EntityIdent
			INNER JOIN
			EntityProjectEntityAnswerValue V WITH (NOLOCK)
				ON V.EntityProjectEntityAnswerIdent = A.Ident
		WHERE
			EPR.Ident = @bntEntityProjectRequirementIdent
			AND RT.AllowMultipleOptions = 0
			AND A.Active = 1
			AND EPE.Active = 1
			AND V.Active = 1
		GROUP BY
			V.Value1

		-- now figure out if we have to consolidate
		IF (@intValueCount <= @intEntityProjectMeasureMaxValueCount)
			BEGIN
				
				INSERT INTO @tblResults(
					Value1,
					ValueCount
				)
				SELECT
					Value1,
					ValueCount
				FROM
					@tblOptions

			END -- (@intValueCount <= @intEntityProjectMeasureMaxValueCount)

		ELSE -- need to inject the Other grouping
			BEGIN
				
				INSERT INTO @tblResults(
					Value1,
					ValueCount
				)
				SELECT TOP (@intEntityProjectMeasureInsertCount)
					Value1,
					ValueCount
				FROM
					@tblOptions
				WHERE
					Value1 <> @nvrOther
				ORDER BY
					ValueCount DESC

				-- delete the top X so we dont recount them
				DELETE
					O
				FROM
					@tblOptions O
					INNER JOIN
					@tblResults tR
						ON tR.Value1 = O.Value1

				INSERT INTO @tblResults(
					Value1,
					ValueCount
				)
				SELECT
					Value1 = @nvrOther,
					ValueCount = SUM(ValueCount)
				FROM
					@tblOptions

			END -- (@intValueCount > @intEntityProjectMeasureMaxValueCount)
		

		RETURN

	END
	
GO
