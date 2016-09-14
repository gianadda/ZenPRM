IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspSetupEntityCustomerTemplates') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspSetupEntityCustomerTemplates
 GO
/* uspSetupEntityCustomerTemplates
 *
 * This procedure will copy our ZenPRM templates into a new customer profile
 *
 *
*/
CREATE PROCEDURE uspSetupEntityCustomerTemplates

	@bntEntityIdent BIGINT,
	@bntEditASUserIdent BIGINT

AS

	SET NOCOUNT ON

	DECLARE @bntTemplateEntityIdent BIGINT

	SELECT
		@bntTemplateEntityIdent = CAST(Value1 AS BIGINT)
	FROM
		ASApplicationVariable WITH (NOLOCK)
	WHERE
		Name1 = 'TemplateProjectEntityIdent'

	/**
	Copy in these tables from ZenPRM templates

	1. EntityConnection (network)
	2. EntityProject
	3. EntityProjectEntity
	4. EntityProjectRequirement
	5. EntityProjectEntityAnswer
	6. EntityProjectEntityAnswerValue
	7. EntityProjectMeasure
	8. EntityProjectMeasureLocationXref
	9. EntityProjectMeasureRange
	
	**/

	CREATE TABLE #tmpEntityProject(
		OldEntityProjectIdent BIGINT,
		NewEntityProjectIdent BIGINT
	)

	CREATE TABLE #tmpEntityProjectRequirement(
		OldEntityProjectIdent BIGINT,
		NewEntityProjectIdent BIGINT,
		OldEntityProjectRequirementIdent BIGINT,
		NewEntityProjectRequirementIdent BIGINT,
		IsFileUpload BIT
	)

	CREATE TABLE #tmpEntityProjectMeasure(
		OldEntityProjectMeasureIdent BIGINT,
		NewEntityProjectMeasureIdent BIGINT
	)

	-- 1. EntityConnection (network)
	INSERT INTO EntityConnection(
		ConnectionTypeIdent,
		FromEntityIdent,
		ToEntityIdent,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT
		ConnectionTypeIdent = ConnectionTypeIdent,
		FromEntityIdent = @bntEntityIdent,
		ToEntityIdent = ToEntityIdent,
		AddASUserIdent = @bntEditASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1
	FROM
		EntityConnection WITH (NOLOCK)
	WHERE
		FromEntityIdent = @bntTemplateEntityIdent
		AND Active = 1

	-- 2. EntityProject
	INSERT INTO EntityProject(
		EntityIdent,
		Name1,
		DueDate,
		PrivateProject,
		ProjectManagerEntityIdent,
		Archived,
		ArchivedASUserIdent,
		ArchivedDateTime,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active,
		ShowOnProfile,
		IncludeEntireNetwork
	) 
	SELECT 
		EntityIdent = @bntEntityIdent,
		Name1 = Name1,
		DueDate = DueDate,
		PrivateProject = PrivateProject,
		ProjectManagerEntityIdent = ProjectManagerEntityIdent,
		Archived = Archived,
		ArchivedASUserIdent = 0,
		ArchivedDateTime = '1/1/1900',
		AddASUserIdent = @bntEditASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1,
		ShowOnProfile = ShowOnProfile,
		IncludeEntireNetwork = IncludeEntireNetwork
	FROM
		EntityProject WITH (NOLOCK)
	WHERE
		EntityIdent = @bntTemplateEntityIdent
		AND Active = 1

	-- store the project translation from old ident to new ident
	INSERT INTO #tmpEntityProject(
		OldEntityProjectIdent,
		NewEntityProjectIdent
	)
	SELECT
		oEP.Ident,
		nEP.Ident
	FROM
		EntityProject oEP WITH (NOLOCK)
		INNER JOIN
		EntityProject nEP WITH (NOLOCK)
			ON nEP.Name1 = oEP.Name1
	WHERE
		oEP.EntityIdent = @bntTemplateEntityIdent
		AND nEP.EntityIdent = @bntEntityIdent

	-- 3. EntityProjectEntity
	INSERT INTO EntityProjectEntity(
		EntityProjectIdent,
		EntityIdent,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT
		EntityProjectIdent = tEP.NewEntityProjectIdent,
		EntityIdent = EPE.EntityIdent,
		AddASUserIdent = @bntEditASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1
	FROM
		EntityProjectEntity EPE WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = EPE.EntityProjectIdent
		INNER JOIN
		#tmpEntityProject tEP WITH (NOLOCK)
			ON tEP.OldEntityProjectIdent = EP.Ident
	WHERE
		EP.EntityIdent = @bntTemplateEntityIdent
		AND EP.Active = 1
		AND EPE.Active = 1

	
	-- 4. EntityProjectRequirement
	INSERT INTO EntityProjectRequirement(
		EntityProjectIdent,
		RequirementTypeIdent,
		Label,
		Desc1,
		PlaceholderText,
		HelpText,
		Options,
		SortOrder,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active,
		CreateToDoUponCompletion,
		ToDoTitle,
		ToDoDesc1,
		ToDoAssigneeEntityIdent,
		ToDoDueDateNoOfDays
	)
	SELECT
		EntityProjectIdent = tEP.NewEntityProjectIdent,
		RequirementTypeIdent = EPR.RequirementTypeIdent,
		Label = EPR.Label,
		Desc1 = EPR.Desc1,
		PlaceholderText = EPR.PlaceholderText,
		HelpText = EPR.HelpText,
		Options = EPR.Options,
		SortOrder = EPR.SortOrder,
		AddASUserIdent = @bntEditASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1,
		CreateToDoUponCompletion = 0,
		ToDoTitle = '',
		ToDoDesc1 = '',
		ToDoAssigneeEntityIdent = 0,
		ToDoDueDateNoOfDays = 0
	FROM
		EntityProjectRequirement EPR WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = EPR.EntityProjectIdent
		INNER JOIN
		#tmpEntityProject tEP WITH (NOLOCK)
			ON tEP.OldEntityProjectIdent = EP.Ident
	WHERE
		EP.EntityIdent = @bntTemplateEntityIdent
		AND EP.Active = 1
		AND EPR.Active = 1

	INSERT INTO #tmpEntityProjectRequirement(
		OldEntityProjectIdent,
		NewEntityProjectIdent,
		OldEntityProjectRequirementIdent,
		NewEntityProjectRequirementIdent,
		IsFileUpload
	)
	SELECT
		oEP.Ident,
		nEP.Ident,
		oEPR.Ident,
		nEPR.Ident,
		RT.IsFileUpload
	FROM
		EntityProjectRequirement oEPR WITH (NOLOCK)
		INNER JOIN
		EntityProject oEP WITH (NOLOCK)
			ON oEP.Ident = oEPR.EntityProjectIdent
		INNER JOIN
		#tmpEntityProject tEP WITH (NOLOCK)
			ON tEP.OldEntityProjectIdent = oEP.Ident
		INNER JOIN
		EntityProject nEP WITH (NOLOCK)
			ON nEP.Ident = tEP.NewEntityProjectIdent
		INNER JOIN
		EntityProjectRequirement nEPR WITH (NOLOCK)
			ON nEPR.EntityProjectIdent = nEP.Ident
			AND nEPR.RequirementTypeIdent = oEPR.RequirementTypeIdent
			AND nEPR.Label = oEPR.Label
		INNER JOIN
		RequirementType RT WITH (NOLOCK)
			ON RT.Ident = nEPR.RequirementTypeIdent
	WHERE
		oEP.EntityIdent = @bntTemplateEntityIdent
		AND oEP.Active = 1
		AND oEPR.Active = 1

	-- 5. EntityProjectEntityAnswer
	INSERT INTO EntityProjectEntityAnswer(
		EntityProjectEntityIdent,
		EntityProjectRequirementIdent,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active,
		ToDoGenerated,
		ToDoGeneratedDateTime
	)
	SELECT
		EntityProjectEntityIdent = nEPE.Ident,
		EntityProjectRequirementIdent = tEPR.NewEntityProjectRequirementIdent,
		AddASUserIdent = @bntEditASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1,
		ToDoGenerated = 0,
		ToDoGeneratedDateTime = '1/1/1900'
	FROM
		EntityProjectEntityAnswer A WITH (NOLOCK)
		INNER JOIN
		#tmpEntityProjectRequirement tEPR WITH (NOLOCK)
			ON tEPR.OldEntityProjectRequirementIdent = A.EntityProjectRequirementIdent
		INNER JOIN
		EntityProjectEntity oEPE WITH (NOLOCK)
			ON oEPE.Ident = A.EntityProjectEntityIdent
			AND oEPE.EntityProjectIdent = tEPR.OldEntityProjectIdent
		INNER JOIN
		EntityProjectEntity nEPE WITH (NOLOCK)
			ON nEPE.EntityProjectIdent = tEPR.NewEntityProjectIdent
			AND nEPE.EntityIdent = oEPE.EntityIdent
	WHERE
		oEPE.Active = 1
		AND A.Active = 1
		AND tEPR.IsFileUpload = 0 -- ignore files as answers in the template copy

	-- 6. EntityProjectEntityAnswerValue
	INSERT INTO EntityProjectEntityAnswerValue(
		EntityProjectEntityAnswerIdent,
		Name1,
		Value1,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT
		EntityProjectEntityAnswerIdent = nA.Ident,
		Name1 = V.Name1,
		Value1 = V.Value1,
		AddASUserIdent = @bntEditASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1
	FROM
		EntityProjectEntityAnswerValue V WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntityAnswer oA WITH (NOLOCK)
			ON oA.Ident = V.EntityProjectEntityAnswerIdent
		INNER JOIN
		#tmpEntityProjectRequirement tEPR WITH (NOLOCK)
			ON tEPR.OldEntityProjectRequirementIdent = oA.EntityProjectRequirementIdent
		INNER JOIN
		EntityProjectEntity oEPE WITH (NOLOCK)
			ON oEPE.Ident = oA.EntityProjectEntityIdent
			AND oEPE.EntityProjectIdent = tEPR.OldEntityProjectIdent
		INNER JOIN
		EntityProjectEntity nEPE WITH (NOLOCK)
			ON nEPE.EntityProjectIdent = tEPR.NewEntityProjectIdent
			AND nEPE.EntityIdent = oEPE.EntityIdent
		INNER JOIN
		EntityProjectEntityAnswer nA WITH (NOLOCK)
			ON nA.EntityProjectEntityIdent = nEPE.Ident
			AND nA.EntityProjectRequirementIdent = tEPR.NewEntityProjectRequirementIdent
	WHERE
		V.Active = 1
		AND oEPE.Active = 1
		AND oA.Active = 1
		AND tEPR.IsFileUpload = 0 -- ignore files as answers in the template copy

	-- 7. EntityProjectMeasure
	INSERT INTO EntityProjectMeasure(
		EntityIdent,
		Name1,
		Desc1,
		MeasureTypeIdent,
		Question1EntityProjectRequirementIdent,
		Question2EntityProjectRequirementIdent,
		TargetValue,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active,
		Recalculate,
		LastRecalculateDate,
		Question1Value,
		Question2Value,
		TotalResourcesComplete,
		TotalResourcesAvailable
	)
	SELECT
		EntityIdent = @bntEntityIdent,
		EPM.Name1,
		EPM.Desc1,
		EPM.MeasureTypeIdent,
		Question1EntityProjectRequirementIdent = COALESCE(EPRone.NewEntityProjectRequirementIdent, 0),
		Question2EntityProjectRequirementIdent = COALESCE(EPRtwo.NewEntityProjectRequirementIdent, 0),
		EPM.TargetValue,
		AddASUserIdent = @bntEditASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		EPM.Active,
		EPM.Recalculate,
		LastRecalculateDate = '1/1/1900',
		EPM.Question1Value,
		EPM.Question2Value,
		EPM.TotalResourcesComplete,
		EPM.TotalResourcesAvailable
	FROM
		EntityProjectMeasure EPM WITH (NOLOCK)
		LEFT OUTER JOIN
		#tmpEntityProjectRequirement EPRone WITH (NOLOCK)
			ON EPRone.OldEntityProjectRequirementIdent = EPM.Question1EntityProjectRequirementIdent
		LEFT OUTER JOIN
		#tmpEntityProjectRequirement EPRtwo WITH (NOLOCK)
			ON EPRtwo.OldEntityProjectRequirementIdent = EPM.Question2EntityProjectRequirementIdent
	WHERE
		EPM.EntityIdent = @bntTemplateEntityIdent
		AND EPM.Active = 1

	INSERT INTO #tmpEntityProjectMeasure(
		OldEntityProjectMeasureIdent,
		NewEntityProjectMeasureIdent
	)
	SELECT
		oEPM.Ident,
		nEPM.Ident
	FROM
		EntityProjectMeasure oEPM WITH (NOLOCK)
		INNER JOIN
		EntityProjectMeasure nEPM WITH (NOLOCK)
			ON nEPM.Name1 = oEPM.Name1
	WHERE
		oEPM.EntityIdent = @bntTemplateEntityIdent
		AND oEPM.Active = 1
		AND nEPM.EntityIdent = @bntEntityIdent

	-- 8. EntityProjectMeasureLocationXref
	INSERT INTO EntityProjectMeasureLocationXref(
		EntityProjectMeasureIdent,
		MeasureLocationIdent,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT
		EntityProjectMeasureIdent = tEPM.NewEntityProjectMeasureIdent,
		MeasureLocationIdent = LX.MeasureLocationIdent,
		AddASUserIdent = @bntEditASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		LX.Active
	FROM
		EntityProjectMeasureLocationXref LX WITH (NOLOCK)
		INNER JOIN
		#tmpEntityProjectMeasure tEPM WITH (NOLOCK)
			ON tEPM.OldEntityProjectMeasureIdent = LX.EntityProjectMeasureIdent
	WHERE
		LX.Active = 1

	-- 9. EntityProjectMeasureRange
	INSERT INTO EntityProjectMeasureRange(
		EntityProjectMeasureIdent,
		Name1,
		Color,
		RangeStartValue,
		RangeEndValue,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT
		EntityProjectMeasureIdent = tEPM.NewEntityProjectMeasureIdent,
		R.Name1,
		R.Color,
		R.RangeStartValue,
		R.RangeEndValue,
		AddASUserIdent = @bntEditASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		R.Active
	FROM
		EntityProjectMeasureRange R WITH (NOLOCK)
		INNER JOIN
		#tmpEntityProjectMeasure tEPM WITH (NOLOCK)
			ON tEPM.OldEntityProjectMeasureIdent = R.EntityProjectMeasureIdent
	WHERE
		R.Active = 1

	-- final debug output
	/**
	select * from #tmpEntityProject WITH (NOLOCK)
	select * from #tmpEntityProjectRequirement WITH (NOLOCK)
	select * from #tmpEntityProjectMeasure WITH (NOLOCK)

	select * from entityProject WITH (NOLOCK) where EntityIdent = @bntEntityIdent
	select * from entityConnection WITH (NOLOCK) where FromEntityIdent = @bntEntityIdent

	SELECT
		EPE.*
	FROM
		EntityProjectEntity EPE WITH (NOLOCK)
		INNER JOIN
		#tmpEntityProject tEP WITH (NOLOCK)
			ON tEP.NewEntityProjectIdent = EPE.EntityProjectIdent
	
	
	SELECT
		EPR.*
	FROM
		EntityProjectEntity EPR WITH (NOLOCK)
		INNER JOIN
		#tmpEntityProject tEP WITH (NOLOCK)
			ON tEP.NewEntityProjectIdent = EPR.EntityProjectIdent

	**/


	DROP TABLE #tmpEntityProject
	DROP TABLE #tmpEntityProjectRequirement
	DROP TABLE #tmpEntityProjectMeasure

GO