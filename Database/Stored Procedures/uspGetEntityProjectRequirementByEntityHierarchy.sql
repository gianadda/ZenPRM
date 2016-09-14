IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityProjectRequirementByEntityHierarchy') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityProjectRequirementByEntityHierarchy
GO

/* uspGetEntityProjectRequirementByEntityHierarchy 306485, 1891, 0, 306487
 *
 *
 * Similar to uspGetEntityProjectMeasureByEntityHierarchy but doesnt require a MeasureIdent
 *
*/
CREATE PROCEDURE uspGetEntityProjectRequirementByEntityHierarchy

	@bntEntityIdent BIGINT,
	@bntEntityProjectRequirementIdent BIGINT,
	@bntMeasureTypeIdent BIGINT,
	@bntASUserIdent BIGINT

AS

	SET NOCOUNT ON

	DECLARE @nvrOther NVARCHAR(5) = dbo.ufnGetEntityProjectMeasureOther()
	DECLARE @intValuesCount INT
	DECLARE @bntEntitySearchDataTypeIdent BIGINT
	DECLARE @nvrEntityProjectRequirement NVARCHAR(MAX)
	DECLARE @bntRequirementTypeIdent BIGINT
	DECLARE @bitIsFileUpload BIT

	DECLARE @bntEntityProjectIdent BIGINT
	DECLARE @bntEntitySearchDataTypeNumberIdent BIGINT
	DECLARE @bntEntitySearchDataTypeOptionsListIdent BIGINT
	DECLARE @bntEntitySearchDataTypeYesNoIdent BIGINT
	DECLARE @bntEntitySearchDataTypeHoursOfOperationIdent BIGINT
	DECLARE @bntEntitySearchDataTypeAddressIdent BIGINT
	DECLARE @bntEntitySearchDataTypeFileIdent BIGINT

	DECLARE @bntMeasureTypeSumIdent BIGINT
	DECLARE @bntMeasureTypeCountIdent BIGINT
	DECLARE @bntMeasureTypeAverageIdent BIGINT

	DECLARE @bntTotalCount BIGINT
	DECLARE @bntTotalCountYes BIGINT
	DECLARE @bntTotalCountAvailable BIGINT
	DECLARE @decTotalSum DECIMAL(20,4)

	DECLARE @bitAllowMultipleOptions BIT

	SET @bntEntitySearchDataTypeNumberIdent = dbo.ufnEntitySearchDataTypeNumberIdent()
	SET @bntEntitySearchDataTypeOptionsListIdent = dbo.ufnEntitySearchDataTypeOptionsListIdent()
	SET @bntEntitySearchDataTypeYesNoIdent = dbo.ufnEntitySearchDataTypeYesNoIdent()
	SET @bntEntitySearchDataTypeHoursOfOperationIdent = dbo.ufnEntitySearchDataTypeHoursOfOperationIdent()
	SET @bntEntitySearchDataTypeAddressIdent = dbo.ufnEntitySearchDataTypeAddressIdent()
	SET @bntEntitySearchDataTypeFileIdent = dbo.ufnEntitySearchDataTypeFileIdent()

	SET @bntMeasureTypeSumIdent = dbo.ufnGetMeasureTypeSumIdent()
	SET @bntMeasureTypeCountIdent = dbo.ufnGetMeasureTypeCountIdent()
	SET @bntMeasureTypeAverageIdent = dbo.ufnGetMeasureTypeAverageIdent()

	--set default values
	SET @bntTotalCount = 0
	SET @bntTotalCountYes = 0
	SET @bntTotalCountAvailable = 0
	SET @decTotalSum = 0

	CREATE TABLE #tmpPractices(
		Ident BIGINT,
		DisplayName NVARCHAR(MAX),
		Organization NVARCHAR(MAX),
		NPI NVARCHAR(10),
		Person BIT
	)

	CREATE TABLE #tmpPracticesResourcesAvailable(
		OrganizationIdent BIGINT,
		TotalResourcesAvailable BIGINT
	)

	CREATE TABLE #tmpPracticesResourcesComplete(
		OrganizationIdent BIGINT,
		TotalResourcesComplete BIGINT,
		Value1 MONEY
	)

	CREATE TABLE #tmpEntitiesAvailable(
		EntityIdent BIGINT,
		OrganizationIdent BIGINT
	)

	CREATE TABLE #tmpDistinctEntitiesAvailable(
		EntityIdent BIGINT,
		OrganizationIdent BIGINT
	)

	CREATE TABLE #tmpEntitiesComplete(
		EntityIdent BIGINT,
		OrganizationIdent BIGINT,
		AnswerIdent BIGINT,
		Value1 MONEY,
		Value1String NVARCHAR(MAX)
	)

	CREATE TABLE #tmpDistinctEntitiesComplete(
		EntityIdent BIGINT,
		Value1 MONEY,
		Value1String NVARCHAR(MAX)
	)

	CREATE TABLE #tmpValuesPrep(
		Value1 NVARCHAR(MAX),
		ValueCount BIGINT
	)

	CREATE TABLE #tmpValues(
		Ident BIGINT IDENTITY(1,1),
		Value1 NVARCHAR(MAX),
		ValueCount BIGINT,
		OrderWeight BIGINT
	)

	CREATE TABLE #tmpOrganizationValues(
		OrganizationIdent BIGINT,
		Value1 NVARCHAR(MAX),
		ValueCount BIGINT
	)
	
	CREATE NONCLUSTERED INDEX idx_tmpEntitiesAvailable_SearchCoveringIndex ON #tmpEntitiesAvailable(EntityIdent)

	-- get the entity project and question data
	SELECT
		@bntEntityProjectIdent = EP.Ident,
		@nvrEntityProjectRequirement = EPR.Label,
		@bntEntitySearchDataTypeIdent = RT.EntitySearchDataTypeIdent,
		@bntRequirementTypeIdent = RT.Ident,
		@bitIsFileUpload = RT.IsFileUpload,
		@bitAllowMultipleOptions = RT.AllowMultipleOptions
	FROM
		EntityProjectRequirement EPR WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = EPR.EntityProjectIdent
		INNER JOIN
		RequirementType RT WITH (NOLOCK)
			ON RT.Ident = EPR.RequirementTypeIdent
	WHERE
		EPR.Ident = @bntEntityProjectRequirementIdent
		AND EPR.Active = 1
		AND EP.EntityIdent = @bntEntityIdent -- make sure we have access to this project
		AND EP.Active = 1

	-- If the measure type is not specified, then setup the default dial type based on data type
	IF (@bntMeasureTypeIdent = 0)
		BEGIN

			SELECT
				@bntMeasureTypeIdent = MT.Ident
			FROM
				MeasureType MT WITH (NOLOCK)
			WHERE
				@bntEntitySearchDataTypeIdent IN (4,5) -- Yes/No and Options have default measure types
				AND MT.EntitySearchDataTypeIdent = @bntEntitySearchDataTypeIdent
				AND MT.Active = 1

			SELECT
				@bntMeasureTypeIdent = MT.Ident
			FROM
				MeasureType MT WITH (NOLOCK)
			WHERE
				@bntEntitySearchDataTypeIdent NOT IN (4,5) -- all others default to count
				AND MT.EntitySearchDataTypeIdent = 0
				AND MT.Active = 1

		END

	-- get all the orgs/practices within this entities hierarchy
	INSERT INTO #tmpPractices(
		Ident,
		DisplayName,
		Organization,
		NPI,
		Person
	)
	EXEC uspGetEntityNetwork @bntEntityIdent, @bntASUserIdent, 0, 1

	-- setup unaffiliated (for those not within a group)
	INSERT INTO #tmpPractices(
		Ident,
		DisplayName,
		Organization,
		NPI,
		Person
	)
	SELECT
		0,
		'Unaffiliated',
		'Unaffiliated',
		'',
		0

	-- now we need a list of all the entities available to answer the question and assigned to an org
	INSERT INTO #tmpEntitiesAvailable(
		EntityIdent,
		OrganizationIdent
	)
	SELECT
		EPP.EntityIdent,
		tP.Ident
	FROM
		#tmpPractices tP WITH (NOLOCK)
		INNER JOIN
		EntityHierarchy EH WITH (NOLOCK)
			ON EH.EntityIdent = @bntEntityIdent
			AND EH.FromEntityIdent = tP.Ident
		INNER JOIN
		dbo.ufnGetEntityProjectParticipants(0, @bntEntityProjectIdent) EPP
			ON EPP.EntityIdent = EH.ToEntityIdent
	WHERE
		EH.Active = 1

	-- PART II
	-- get any organizations where the data is stored at the org level
	INSERT INTO #tmpEntitiesAvailable(
		EntityIdent,
		OrganizationIdent
	)
	SELECT
		EPP.EntityIdent,
		EPP.EntityIdent
	FROM
		#tmpEntitiesAvailable tE WITH (NOLOCK)
		INNER JOIN
		dbo.ufnGetEntityProjectParticipants(0, @bntEntityProjectIdent) EPP
			ON EPP.EntityIdent = tE.OrganizationIdent
	
	-- PART III
	-- now do the same thing for the unaffiliated resources (non orgs)
	INSERT INTO #tmpEntitiesAvailable(
		EntityIdent,
		OrganizationIdent
	)
	SELECT
		EPP.EntityIdent,
		0
	FROM
		dbo.ufnGetEntityProjectParticipants(0, @bntEntityProjectIdent) EPP
		LEFT OUTER JOIN
		#tmpEntitiesAvailable tE WITH (NOLOCK)
			ON tE.EntityIdent = EPP.EntityIdent
	WHERE
		tE.OrganizationIdent IS NULL

	-- get the distinct list of entities
	INSERT INTO #tmpDistinctEntitiesAvailable(
		EntityIdent,
		OrganizationIdent
	)
	SELECT
		EntityIdent,
		OrganizationIdent
	FROM
		#tmpEntitiesAvailable WITH (NOLOCK)
	GROUP BY
		EntityIdent,
		OrganizationIdent

	INSERT INTO #tmpPracticesResourcesAvailable(
		OrganizationIdent,
		TotalResourcesAvailable
	)
	SELECT
		OrganizationIdent,
		COUNT(EntityIdent)
	FROM
		#tmpDistinctEntitiesAvailable WITH (NOLOCK)
	GROUP BY
		OrganizationIdent

	-- now we need a list of all the entities who have answered the question
	-- luckily, this time we can ignore EntityProject.IncludeInNetwork since we only need to know which ones were answered
	INSERT INTO #tmpEntitiesComplete(
		EntityIdent,
		OrganizationIdent,
		AnswerIdent,
		Value1,
		Value1String
	)
	SELECT DISTINCT
		EPE.EntityIdent,
		tDEA.OrganizationIdent,
		EPEA.Ident,
		Value1 = CASE @bntEntitySearchDataTypeIdent
			WHEN 0 THEN 1
			WHEN @bntEntitySearchDataTypeNumberIdent THEN COALESCE(TRY_CAST(EPEAV.Value1 AS MONEY),0.0)
			WHEN @bntEntitySearchDataTypeOptionsListIdent THEN 0.0
			WHEN @bntEntitySearchDataTypeYesNoIdent THEN CASE EPEAV.Value1 WHEN 'Yes' THEN 1 ELSE 0 END
			ELSE 1
		END,
		Value1String = CASE @bntEntitySearchDataTypeIdent
			WHEN 0 THEN CASE EPEAV.Value1 WHEN 'True' THEN EPEAV.Name1 WHEN 'False' THEN '' ELSE EPEAV.Value1 END
			WHEN @bntEntitySearchDataTypeOptionsListIdent THEN CASE EPEAV.Value1 WHEN 'True' THEN EPEAV.Name1 WHEN 'False' THEN '' ELSE EPEAV.Value1 END
			WHEN @bntEntitySearchDataTypeYesNoIdent THEN EPEAV.Value1
			WHEN @bntEntitySearchDataTypeNumberIdent THEN ''
			WHEN @bntEntitySearchDataTypeHoursOfOperationIdent THEN dbo.ufnFormatHoursOfOperation(EPEA.Ident)
			WHEN @bntEntitySearchDataTypeAddressIdent THEN dbo.ufnFormatAddress(EPEA.Ident)
			ELSE EPEAV.Value1
		END
	FROM
		#tmpDistinctEntitiesAvailable tDEA WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityIdent = tDEA.EntityIdent
		INNER JOIN
		EntityProjectEntityAnswer EPEA WITH (NOLOCK)
			ON EPEA.EntityProjectEntityIdent = EPE.Ident
		INNER JOIN
		EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
			ON EPEAV.EntityProjectEntityAnswerIdent = EPEA.Ident
	WHERE
		EPEA.EntityProjectRequirementIdent = @bntEntityProjectRequirementIdent
		AND EPEA.Active = 1
		AND EPE.Active = 1
		AND EPEAV.Active = 1
		AND (EPEAV.Name1 = 'FileName' OR @bntEntitySearchDataTypeIdent <> @bntEntitySearchDataTypeFileIdent)
	GROUP BY
		EPE.EntityIdent,
		tDEA.OrganizationIdent,
		EPEA.Ident,
		EPEAV.Name1,
		EPEAV.Value1
	
	 -- handle the pie chart values, if applicable
	INSERT INTO #tmpValuesPrep(
		Value1,
		ValueCount
	)
	SELECT
		tEC.Value1String,
		COUNT(DISTINCT tEC.EntityIdent)
	FROM
		#tmpEntitiesComplete tEC WITH (NOLOCK)
	WHERE
		@bntEntitySearchDataTypeIdent = @bntEntitySearchDataTypeOptionsListIdent
	GROUP BY
		tEC.Value1String

	SELECT
		@intValuesCount = COUNT(*)
	FROM
		#tmpValuesPrep WITH (NOLOCK)

	IF (@intValuesCount > 0)
		BEGIN
			
			DECLARE @intEntityProjectMeasureMaxValueCount INT = dbo.ufnGetEntityProjectMeasureMaxValueCount()
			DECLARE @intEntityProjectMeasureInsertCount INT = (@intEntityProjectMeasureMaxValueCount - 1)

			-- see if we have more than the desired number of values. if so, we have to consolidate the bottom counts down to Other
			IF (@intValuesCount <= @intEntityProjectMeasureMaxValueCount)

				BEGIN

					INSERT INTO #tmpValues(
						Value1,
						ValueCount,
						OrderWeight
					)
					SELECT
						Value1,
						ValueCount,
						ValueCount
					FROM
						#tmpValuesPrep WITH (NOLOCK)

				END

			ELSE -- insert the top X, then consolidate the remaining values to OTHER

				BEGIN

					INSERT INTO #tmpValues(
						Value1,
						ValueCount,
						OrderWeight
					)
					SELECT TOP (@intEntityProjectMeasureInsertCount)
						tVP.Value1,
						tVP.ValueCount,
						tVP.ValueCount
					FROM
						#tmpValuesPrep tVP WITH (NOLOCK)
					ORDER BY
						tVP.ValueCount DESC

					-- delete the top X so we dont recount them
					DELETE
						tVP
					FROM
						#tmpValuesPrep tVP WITH (NOLOCK)
						INNER JOIN
						#tmpValues tV WITH (NOLOCK)
							ON tVP.Value1 = tV.Value1

					INSERT INTO #tmpValues(
						Value1,
						ValueCount,
						OrderWeight
					)
					SELECT
						Value1 = @nvrOther,
						ValueCount = SUM(tVP.ValueCount),
						OrderWeight = -99999
					FROM
						#tmpValuesPrep tVP WITH (NOLOCK)

				END

			INSERT INTO #tmpOrganizationValues(
				OrganizationIdent,
				Value1,
				ValueCount
			)
			SELECT
				tEC.OrganizationIdent,
				tV.Value1,
				COUNT(tEC.EntityIdent)
			FROM
				#tmpEntitiesComplete tEC WITH (NOLOCK)
				LEFT OUTER JOIN
				#tmpValues tV WITH (NOLOCK)
					ON tV.Value1 = tEC.Value1String
			GROUP BY
				tEC.OrganizationIdent,
				tV.Value1
			UNION
			SELECT -- this gets a list of each value option per org, that way we can match the pie chart array for EACH org so the colors line up across all instances
				tEC.OrganizationIdent,
				tV.Value1,
				0
			FROM
				#tmpEntitiesComplete tEC WITH (NOLOCK),
				#tmpValues tV WITH (NOLOCK)

			-- any values that are NULL did not join to our consolidated list
			-- meaning that they fall into the other category
			UPDATE
				#tmpOrganizationValues
			SET
				Value1 = @nvrOther
			WHERE
				Value1 IS NULL

			-- if we have a multi-select, now that we have all the counts, lets consolidate the selected answers into a single entity record
			IF (@bitAllowMultipleOptions = 1)
				BEGIN
						
					TRUNCATE TABLE #tmpEntitiesComplete

					INSERT INTO #tmpEntitiesComplete(
						EntityIdent,
						OrganizationIdent,
						AnswerIdent,
						Value1,
						Value1String
					)
					-- first for Q1 (we need to get the list based on whether the project spans the entire network)
					SELECT
						EPE.EntityIdent,
						tDEA.OrganizationIdent,
						EPEA.Ident,
						Value1 = 1,
						Value1String = STUFF((
												SELECT 
													'; ' + V.Name1 + ''
												FROM
													#tmpEntitiesAvailable tDEAi WITH (NOLOCK)
													INNER JOIN
													EntityProjectRequirement EPR WITH (NOLOCK)
														ON EPR.Ident = @bntEntityProjectRequirementIdent
													INNER JOIN
													EntityProjectEntity EPEi WITH (NOLOCK)
														ON EPEi.EntityIdent = tDEAi.EntityIdent
													INNER JOIN
													EntityProjectEntityAnswer A WITH (NOLOCK)
														ON A.EntityProjectEntityIdent = EPEi.Ident
														AND A.EntityProjectRequirementIdent = EPR.Ident
													INNER JOIN
													EntityProjectEntityAnswerValue V WITH (NOLOCK)
														ON V.EntityProjectEntityAnswerIdent = A.Ident
												WHERE 
													tDEAi.EntityIdent = tDEA.EntityIdent
													AND EPEi.Active = 1
													AND A.Active = 1
													AND V.Active = 1
													AND UPPER(V.Value1) = 'TRUE'
												GROUP BY
													V.Name1,
													V.Value1
												ORDER BY
													V.Name1 ASC
											for xml path(''), type
										).value('.', 'varchar(max)'), 1, 1, '')
					FROM
						#tmpEntitiesAvailable tDEA WITH (NOLOCK)
						INNER JOIN
						EntityProjectEntity EPE WITH (NOLOCK)
							ON EPE.EntityIdent = tDEA.EntityIdent
						INNER JOIN
						EntityProjectEntityAnswer EPEA WITH (NOLOCK)
							ON EPEA.EntityProjectEntityIdent = EPE.Ident
					WHERE
						EPEA.EntityProjectRequirementIdent = @bntEntityProjectRequirementIdent
						AND EPEA.Active = 1
						AND EPE.Active = 1

				END

		END

	-- finally, get the distinct list of entities
	INSERT INTO #tmpDistinctEntitiesComplete(
		EntityIdent,
		Value1,
		Value1String
	)
	SELECT
		EntityIdent,
		MAX(Value1),
		MAX(Value1String)
	FROM
		#tmpEntitiesComplete WITH (NOLOCK)
	GROUP BY
		EntityIdent

	-- simple calc, get the total count of entities that have completed this (by org)
	INSERT #tmpPracticesResourcesComplete(
		OrganizationIdent,
		TotalResourcesComplete,
		Value1
	)
	SELECT
		OrganizationIdent,
		COUNT(EntityIdent),
		CASE 
			WHEN @bntMeasureTypeIdent = @bntMeasureTypeSumIdent THEN SUM(Value1)
			WHEN @bntMeasureTypeIdent = @bntMeasureTypeAverageIdent THEN SUM(Value1)
			WHEN @bntEntitySearchDataTypeIdent = @bntEntitySearchDataTypeYesNoIdent THEN SUM(Value1)
			ELSE COUNT(Value1)
		END
	FROM
		#tmpEntitiesComplete WITH (NOLOCK)
	GROUP BY
		OrganizationIdent

	-- get our aggregates for the final select
	SELECT
		@bntTotalCount = COUNT(*),
		@decTotalSum = SUM(Value1)
	FROM
		#tmpDistinctEntitiesComplete WITH (NOLOCK)

	SELECT
		@bntTotalCountAvailable = COUNT(DISTINCT EntityIdent)
	FROM
		#tmpEntitiesAvailable WITH (NOLOCK)

	--select * from #tmpEntitiesComplete
	--select * from #tmpPracticesResourcesComplete

	-- final select - Measure Name
	SELECT
		@nvrEntityProjectRequirement as [Name1]

	-- final select - Measures (by Org)
	SELECT
		@bntEntityIdent as [EntityIdent],
		tP.Ident as [OrganizationIdent],
		tP.Organization AS [Name1],
		MT.EntitySearchDataTypeIdent,
		MT.HasDenominator,
		MT.HasTargetValue,
		MT.IsAverage,
		MT.IsPercentage,
		MT.Ident as [MeasureTypeIdent],
		MT.Name1 AS [MeasureType],
		EP.Ident AS [EntityProject1Ident],
		EP.Name1 AS [EntityProject1Name],
		@bntEntityProjectRequirementIdent as [Question1EntityProjectRequirementIdent],
		@bntRequirementTypeIdent AS [Question1RequirementTypeIdent],
		COALESCE(tPRC.Value1, 0.0) as [Question1Value],
		CASE MT.IsPercentage
			WHEN 1 THEN COALESCE(tPRC.TotalResourcesComplete, 0)
			ELSE 0
		END as [Question2Value],
		COALESCE(tPRC.TotalResourcesComplete, 0.0) AS [TotalResourcesComplete],
		tPRA.TotalResourcesAvailable AS [TotalResourcesAvailable]
	FROM
		#tmpPracticesResourcesAvailable tPRA WITH (NOLOCK)
		LEFT OUTER JOIN
		#tmpPracticesResourcesComplete tPRC WITH (NOLOCK)
			ON tPRC.OrganizationIdent = tPRA.OrganizationIdent
		INNER JOIN
		#tmpPractices tP WITH (NOLOCK)
			ON tP.Ident = tPRA.OrganizationIdent
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.Ident = @bntEntityProjectRequirementIdent
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = EPR.EntityProjectIdent
		INNER JOIN
		MeasureType MT WITH (NOLOCK)
			ON MT.Ident = @bntMeasureTypeIdent
	ORDER BY
		CASE tP.Ident 
			WHEN 0 THEN 'ZZZZZZZZZZZZZZZZ'
			ELSE tP.Organization
		END ASC

	-- final select - Measure Values
	SELECT
		tV.Ident,
		tOV.OrganizationIdent,
		tOV.Value1,
		SUM(tOV.ValueCount) AS [ValueCount]
	FROM
		#tmpOrganizationValues tOV WITH (NOLOCK)
		INNER JOIN
		#tmpValues tV WITH (NOLOCK)
			ON tV.Value1 = tOV.Value1
	GROUP BY
		tOV.OrganizationIdent,
		tOV.Value1,
		tV.OrderWeight,
		tV.Ident
	ORDER BY
		tOV.OrganizationIdent ASC,
		tV.OrderWeight DESC

	-- participant list
	SELECT DISTINCT
		tDEA.EntityIdent,
		E.DisplayName,
		E.FullName,
		E.NPI,
		E.ProfilePhoto,
		tDEA.OrganizationIdent,
		tP.Organization,
		COALESCE(tDEC.AnswerIdent, 0) AS [AnswerIdent],
		COALESCE(tDEC.Value1,0.0) AS [Value1],
		0.0 AS [Value2],
		COALESCE(tDEC.Value1String, '') AS [Value1String],
		CASE 
			WHEN Value1 IS NULL THEN CAST(0 AS BIT) 
			ELSE CAST(1 AS BIT)
		END AS [Answered],
		@bitIsFileUpload as [IsFileUpload]
	FROM
		#tmpDistinctEntitiesAvailable tDEA WITH (NOLOCK)
		INNER JOIN
		#tmpPractices tP WITH (NOLOCK)
			ON tP.Ident = tDEA.OrganizationIdent
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = tDEA.EntityIdent
		LEFT OUTER JOIN
		#tmpEntitiesComplete tDEC WITH (NOLOCK)
			ON tDEC.EntityIdent = tDEA.EntityIdent
			AND tDEC.OrganizationIdent = tDEA.OrganizationIdent
	ORDER BY
		E.DisplayName ASC

	-- final select - Measure Totals
	SELECT
		@bntEntityIdent as [EntityIdent],
		0 as [OrganizationIdent],
		MT.Name1 as [Name1],
		MT.EntitySearchDataTypeIdent,
		MT.HasDenominator,
		MT.HasTargetValue,
		MT.IsAverage,
		MT.IsPercentage,
		MT.Ident as [MeasureTypeIdent],
		MT.Name1 AS [MeasureType],
		EP.Ident AS [EntityProject1Ident],
		EP.Name1 AS [EntityProject1Name],
		@bntEntityProjectRequirementIdent as [Question1EntityProjectRequirementIdent],
		@bntRequirementTypeIdent AS [Question1RequirementTypeIdent],
		CASE 
			WHEN MT.Ident = @bntMeasureTypeSumIdent THEN COALESCE(@decTotalSum,0.0)
			WHEN MT.Ident = @bntMeasureTypeAverageIdent THEN COALESCE(@decTotalSum,0.0)
			WHEN @bntEntitySearchDataTypeIdent = @bntEntitySearchDataTypeYesNoIdent THEN COALESCE(@decTotalSum,0.0)
			ELSE COALESCE(@bntTotalCount,0)
		END as [Question1Value],
		CASE MT.IsPercentage
			WHEN 1 THEN COALESCE(@bntTotalCount,0)
			ELSE 0
		END as [Question2Value],
		COALESCE(@bntTotalCount,0) AS [TotalResourcesComplete],
		COALESCE(@bntTotalCountAvailable,0) AS [TotalResourcesAvailable]
	FROM
		MeasureType MT WITH (NOLOCK),
		EntityProjectRequirement EPR WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = EPR.EntityProjectIdent
	WHERE
		-- if its a number, bring back each dial type (avg, count, sum) for display
		((@bntEntitySearchDataTypeIdent = @bntEntitySearchDataTypeNumberIdent AND MT.Ident IN (@bntMeasureTypeSumIdent,@bntMeasureTypeCountIdent,@bntMeasureTypeAverageIdent))
		OR (@bntEntitySearchDataTypeIdent <> @bntEntitySearchDataTypeNumberIdent AND MT.Ident = @bntMeasureTypeIdent))
		AND EPR.Ident = @bntEntityProjectRequirementIdent
	GROUP BY
		MT.EntitySearchDataTypeIdent,
		MT.HasDenominator,
		MT.HasTargetValue,
		MT.IsAverage,
		MT.IsPercentage,
		MT.Ident,
		MT.Name1,
		EP.Ident,
		EP.Name1
	ORDER BY
		[Name1] ASC

	SELECT
		tV.Ident,
		0 as [OrganizationIdent],
		tV.Value1,
		tV.ValueCount
	FROM
		#tmpValues tV WITH (NOLOCK)
	ORDER BY
		tV.OrderWeight DESC

	DROP TABLE #tmpPractices
	DROP TABLE #tmpEntitiesAvailable
	DROP TABLE #tmpEntitiesComplete
	DROP TABLE #tmpPracticesResourcesAvailable
	DROP TABLE #tmpPracticesResourcesComplete
	DROP TABLE #tmpValues
	DROP TABLE #tmpOrganizationValues
	DROP TABLE #tmpValuesPrep
	DROP TABLE #tmpDistinctEntitiesAvailable
	DROP TABLE #tmpDistinctEntitiesComplete

GO