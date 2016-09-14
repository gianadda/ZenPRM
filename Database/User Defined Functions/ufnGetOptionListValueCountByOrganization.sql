IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetOptionListValueCountByOrganization') 
	AND OBJECTPROPERTY(id, N'IsTableFunction') = 1)
DROP FUNCTION ufnGetOptionListValueCountByOrganization
GO

/* ufnGetOptionListValueCountByOrganization
 *
 * Returns the answered value options for a specific question
 *
 *
*/
CREATE FUNCTION ufnGetOptionListValueCountByOrganization(@tblEntity AS [EntityOrganizationAnswerTable] READONLY, @bntEntityProjectRequirementIdent BIGINT)
RETURNS @tblResults TABLE
	(
		OrganizationIdent BIGINT,
		Value1 NVARCHAR(MAX),
		ValueCount BIGINT,
		OrderWeight BIGINT
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
		
		DECLARE @tblOptionsGrouped TABLE (
			Value1 NVARCHAR(MAX),
			ValueCount BIGINT,
			OrderWeight BIGINT
		)
		
		DECLARE @tblOptionsByOrg TABLE (
			OrganizationIdent BIGINT INDEX idx_Options_OrgIdent NONCLUSTERED, -- column index,
			Value1 NVARCHAR(MAX) ,
			ValueCount BIGINT
		)

		DECLARE @tblResultsBreakdown TABLE(
			OrganizationIdent BIGINT INDEX idx_OptionsBreakdown_OrgIdent NONCLUSTERED, -- column index,
			Value1 NVARCHAR(MAX),
			ValueCount BIGINT,
			OrderWeight BIGINT
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

		SELECT
			@intValueCount = COUNT(*)
		FROM
			@tblOptions

		-- now figure out if we have to consolidate
		IF (@intValueCount <= @intEntityProjectMeasureMaxValueCount)
			BEGIN
				
				INSERT INTO @tblOptionsGrouped(
					Value1,
					ValueCount,
					OrderWeight
				)
				SELECT
					Value1,
					ValueCount,
					ValueCount
				FROM
					@tblOptions

			END -- (@intValueCount <= @intEntityProjectMeasureMaxValueCount)

		ELSE -- need to inject the Other grouping
			BEGIN
				
				INSERT INTO @tblOptionsGrouped(
					Value1,
					ValueCount,
					OrderWeight
				)
				SELECT TOP (@intEntityProjectMeasureInsertCount)
					tblO.Value1,
					tblO.ValueCount,
					tblO.ValueCount
				FROM
					@tblOptions tblO
				WHERE
					tblO.Value1 <> @nvrOther
				ORDER BY
					tblO.ValueCount DESC

				-- delete the top X so we dont recount them
				DELETE
					O
				FROM
					@tblOptions O
					INNER JOIN
					@tblOptionsGrouped tOG
						ON tOG.Value1 = O.Value1

				INSERT INTO @tblOptionsGrouped(
					Value1,
					ValueCount,
					OrderWeight
				)
				SELECT
					Value1 = @nvrOther,
					ValueCount = SUM(ValueCount),
					OrderWeight = -99999
				FROM
					@tblOptions

			END -- (@intValueCount > @intEntityProjectMeasureMaxValueCount)
		
		-- now that we have the total counts, we need to breakdown by org
		INSERT INTO @tblOptionsByOrg(
			OrganizationIdent,
			Value1,
			ValueCount
		)
		SELECT
			OrganizationIdent = tE.OrganizationIdent,
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
			tE.OrganizationIdent,
			V.Name1
		UNION ALL
		SELECT
			OrganizationIdent = tE.OrganizationIdent,
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
			tE.OrganizationIdent,
			V.Value1

		INSERT INTO @tblResultsBreakdown(
			OrganizationIdent,
			Value1,
			ValueCount,
			OrderWeight
		)
		SELECT
			tOO.OrganizationIdent,
			tOO.Value1,
			tOO.ValueCount,
			tOG.OrderWeight
		FROM
			@tblOptionsByOrg tOO
			LEFT OUTER JOIN
			@tblOptionsGrouped tOG
				ON tOG.Value1 = tOO.Value1
		UNION ALL
		SELECT -- this gets a list of each value option per org, that way we can match the pie chart array for EACH org so the colors line up across all instances
			tOO.OrganizationIdent,
			tOG.Value1,
			0,
			tOG.OrderWeight
		FROM
			@tblOptionsByOrg tOO,
			@tblOptionsGrouped tOG
		GROUP BY
			tOO.OrganizationIdent,
			tOG.Value1,
			tOG.OrderWeight

		-- any values that are NULL did not join to our consolidated list
		-- meaning that they fall into the other category
		UPDATE
			@tblResultsBreakdown
		SET
			Value1 = @nvrOther,
			OrderWeight = -99999
		WHERE
			OrderWeight IS NULL

		-- get the final select (rolling up the breakdown records)
		INSERT INTO @tblResults(
			OrganizationIdent,
			Value1,
			ValueCount,
			OrderWeight
		)
		SELECT
			tRB.OrganizationIdent,
			tRB.Value1,
			SUM(tRB.ValueCount),
			tRB.OrderWeight
		FROM
			@tblResultsBreakdown tRB
		GROUP BY
			tRB.OrganizationIdent,
			tRB.Value1,
			tRB.OrderWeight

		RETURN

	END
	
GO
