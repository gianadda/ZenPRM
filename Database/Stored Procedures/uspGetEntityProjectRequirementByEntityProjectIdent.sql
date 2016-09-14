IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityProjectRequirementByEntityProjectIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityProjectRequirementByEntityProjectIdent
GO

/* uspGetEntityProjectRequirementByEntityProjectIdent 496093, 10077, 2
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetEntityProjectRequirementByEntityProjectIdent]

	@bntEntityIdent BIGINT,
	@bntEntityProjectIdent BIGINT,
	@bntASUserIdent BIGINT

AS

	SET NOCOUNT ON


	DECLARE @intEntityProjectEntityIdent AS BIGINT
	DECLARE @intProjectOwnerEntityIdent AS BIGINT
	SET @intEntityProjectEntityIdent = 0
	SET @intProjectOwnerEntityIdent = 0

	SELECT 
		@intEntityProjectEntityIdent = EPE.Ident
	FROM
		EntityProject EP WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityProjectIdent = EP.Ident
	WHERE 
		EP.Ident = @bntEntityProjectIdent
		AND EPE.EntityIdent = @bntEntityIdent
		AND EPE.Active = 1

	IF (@intEntityProjectEntityIdent = 0)
	BEGIN

		--If they aren't on the project and the project is marked as "Include entire Network", go add them
		INSERT INTO EntityProjectEntity (
			EntityProjectIdent,
			EntityIdent,
			AddASUserIdent,
			AddDateTime,
			EditASUserIdent,
			EditDateTime,
			Active
		)
		SELECT 
			EntityProjectIdent = @bntEntityProjectIdent,
			EntityIdent = @bntEntityIdent,
			AddASUserIdent = @bntASUserIdent,
			AddDateTime = dbo.ufnGetMyDate(),
			EditASUserIdent = 0,
			EditDateTime = '1/1/1900',
			Active = 1
		FROM
			EntityProject EP WITH (NOLOCK)
		WHERE 
			EP.Ident = @bntEntityProjectIdent
			AND EP.IncludeEntireNetwork = 1


				
			SET @intEntityProjectEntityIdent = SCOPE_IDENTITY()

	END


	CREATE TABLE #tmpRequirements (
		Ident BIGINT,
		model BIGINT,
		[type] VARCHAR(MAX),
		EntityProjectIdent BIGINT,
		RequirementTypeIdent BIGINT,
		label VARCHAR(MAX),
		[description] VARCHAR(MAX),
		placeholder VARCHAR(MAX),
		helpText VARCHAR(MAX),
		options VARCHAR(MAX),
		sortOrder INT,
		submitted BIT,
		AnswerIdent BIGINT,
		[values] VARCHAR(MAX),
		RequiresAnswer BIT,
		IsFileUpload BIT,
		EntitySearchDataTypeIdent BIGINT,
		AllowEntityProjectMeasure BIT
	)


	INSERT INTO #tmpRequirements (
		Ident ,
		model ,
		[type] ,
		EntityProjectIdent ,
		RequirementTypeIdent ,
		label ,
		[description] ,
		placeholder,
		helpText,
		options,
		sortOrder,
		submitted,
		[values],
		RequiresAnswer,
		IsFileUpload,
		EntitySearchDataTypeIdent,
		AllowEntityProjectMeasure
	)
	--Get the requirements as an Admin who owns the project
	SELECT 
		EPR.Ident,
		EPR.Ident,
		RT.TemplateName,
		EPR.EntityProjectIdent,
		EPR.RequirementTypeIdent,
		EPR.Label,
		EPR.Desc1,
		EPR.PlaceholderText,
		EPR.HelpText,
		EPR.Options,
		EPR.SortOrder,
		CONVERT(BIT,0),
		'',
		RT.RequiresAnswer,
		RT.IsFileUpload,
		RT.EntitySearchDataTypeIdent,
		RT.AllowEntityProjectMeasure
	FROM
		EntityProjectRequirement EPR WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EPR.EntityProjectIdent = EP.Ident
		INNER JOIN
		RequirementType RT WITH (NOLOCK)
			ON EPR.RequirementTypeIdent = RT.Ident
	WHERE 
		EP.Active = 1
		AND EPR.Active = 1
		AND EP.Ident = @bntEntityProjectIdent
		AND EP.EntityIdent = @bntEntityIdent
	UNION ALL

	--Bring back "private Projects"
	SELECT DISTINCT 
		EPR.Ident,
		EPR.Ident as [model],
		RT.TemplateName as [type],
		EPR.EntityProjectIdent,
		EPR.RequirementTypeIdent,
		EPR.Label as [label],
		EPR.Desc1 as [description],
		EPR.PlaceholderText as [placeholder],
		EPR.HelpText as [helpText],
		EPR.Options as [options],
		EPR.SortOrder as [sortOrder],
		CONVERT(BIT,0) as [submitted],
		'' as [values],
		RT.RequiresAnswer,
		RT.IsFileUpload,
		RT.EntitySearchDataTypeIdent,
		RT.AllowEntityProjectMeasure
	FROM
		EntityProjectRequirement EPR WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EPR.EntityProjectIdent = EP.Ident
		INNER JOIN
		RequirementType RT WITH (NOLOCK)
			ON EPR.RequirementTypeIdent = RT.Ident
		INNER JOIN
		EntityNetwork EN WITH (NOLOCK)
			ON EN.FromEntityIdent = EP.EntityIdent
	WHERE 
		EN.ToEntityIdent = @bntEntityIdent
		AND EP.EntityIdent = @bntASUserIdent
		AND EP.PrivateProject = 1
		AND EP.Ident = @bntEntityProjectIdent
		AND EPR.Active = 1
	UNION ALL

	--Bring back linked projects
	SELECT DISTINCT
		EPR.Ident,
		EPR.Ident as [model],
		RT.TemplateName as [type],
		EPR.EntityProjectIdent,
		EPR.RequirementTypeIdent,
		EPR.Label as [label],
		EPR.Desc1 as [description],
		EPR.PlaceholderText as [placeholder],
		EPR.HelpText as [helpText],
		EPR.Options as [options],
		EPR.SortOrder as [sortOrder],
		CONVERT(BIT,0) as [submitted],
		'' as [values],
		RT.RequiresAnswer,
		RT.IsFileUpload,
		RT.EntitySearchDataTypeIdent,
		RT.AllowEntityProjectMeasure
	FROM
		EntityProjectRequirement EPR WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EPR.EntityProjectIdent = EP.Ident
		INNER JOIN
		RequirementType RT WITH (NOLOCK)
			ON EPR.RequirementTypeIdent = RT.Ident
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityProjectIdent = EP.Ident
	WHERE 
		EPE.EntityIdent = @bntEntityIdent
		AND EP.PrivateProject = 0
		AND EP.Ident = @bntEntityProjectIdent
		AND EPR.Active = 1



	UPDATE tR
	SET 
		submitted = CONVERT(BIT,1),
		AnswerIdent = EPEA.Ident,
		[values] = CASE WHEN ISDATE(EPEAV.Value1) = 1 THEN CONVERT(VARCHAR(MAX),EPEAV.Value1, 101) ELSE CONVERT(VARCHAR(MAX),EPEAV.Value1) END
	FROM
		#tmpRequirements tR
		INNER JOIN
		EntityProjectEntityAnswer EPEA WITH (NOLOCK)
			ON tR.Ident = EPEA.EntityProjectRequirementIdent
		INNER JOIN
		EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
			ON EPEAV.EntityProjectEntityAnswerIdent = EPEA.Ident
	WHERE 
		EPEA.EntityProjectEntityIdent = @intEntityProjectEntityIdent
		AND EPEA.Active = 1
		AND EPEAV.Active = 1

	--Multi selects
	UPDATE tR
	SET 
		submitted = CONVERT(BIT,1),
		AnswerIdent = EPEA.Ident,
		[values] = STUFF((
						select 
							',"' + EPEAV.Name1 + '": "' + EPEAV.Value1 +'"'

						from 
							#tmpRequirements tRi
							INNER JOIN
							EntityProjectEntityAnswer EPEA WITH (NOLOCK)
								ON tRi.Ident = EPEA.EntityProjectRequirementIdent
							INNER JOIN
							EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
								ON EPEAV.EntityProjectEntityAnswerIdent = EPEA.Ident
							INNER JOIN
							RequirementType RT WITH (NOLOCK)
								ON RT.Ident = tRi.RequirementTypeIdent
						WHERE 
							EPEA.EntityProjectEntityIdent = @intEntityProjectEntityIdent
							AND RT.AllowMultipleOptions = 1
							AND RT.Ident <> 11 -- do something different for tags
							AND tRi.Ident = tR.Ident
							AND EPEA.Active = 1
							AND EPEAV.Active = 1
						for xml path(''), type
					).value('.', 'varchar(max)'), 1, 1, '')  
	FROM
		#tmpRequirements tR
		INNER JOIN
		EntityProjectEntityAnswer EPEA WITH (NOLOCK)
			ON tR.Ident = EPEA.EntityProjectRequirementIdent
		INNER JOIN
		EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
			ON EPEAV.EntityProjectEntityAnswerIdent = EPEA.Ident
		INNER JOIN
		RequirementType RT WITH (NOLOCK)
			ON RT.Ident = tR.RequirementTypeIdent
	WHERE 
		EPEA.EntityProjectEntityIdent = @intEntityProjectEntityIdent
		AND RT.AllowMultipleOptions = 1
		AND RT.Ident <> 11 -- do something different for tags
		AND EPEA.Active = 1
		AND EPEAV.Active = 1

	--Multi selects
	UPDATE tR
	SET 
		submitted = CONVERT(BIT,1),
		AnswerIdent = EPEA.Ident,
		[values] = STUFF((
						select 
							',{"name": "' + EPEAV.Name1 +'"}'

						from 
							#tmpRequirements tRi
							INNER JOIN
							EntityProjectEntityAnswer EPEA WITH (NOLOCK)
								ON tRi.Ident = EPEA.EntityProjectRequirementIdent
							INNER JOIN
							EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
								ON EPEAV.EntityProjectEntityAnswerIdent = EPEA.Ident
						WHERE 
							EPEA.EntityProjectEntityIdent = @intEntityProjectEntityIdent
							AND tR.RequirementTypeIdent in (11) -- do something different for tags
							AND tRi.Ident = tR.Ident
							AND EPEA.Active = 1
							AND EPEAV.Active = 1
						for xml path(''), type
					).value('.', 'varchar(max)'), 1, 1, '')  
	FROM
		#tmpRequirements tR
		INNER JOIN
		EntityProjectEntityAnswer EPEA WITH (NOLOCK)
			ON tR.Ident = EPEA.EntityProjectRequirementIdent
		INNER JOIN
		EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
			ON EPEAV.EntityProjectEntityAnswerIdent = EPEA.Ident
	WHERE 
		EPEA.EntityProjectEntityIdent = @intEntityProjectEntityIdent
		AND tR.RequirementTypeIdent in (11) -- do something different for tags
		AND EPEA.Active = 1
		AND EPEAV.Active = 1

	--Address stuff for Ident 12 and Hours of operation Ident 18
	UPDATE tR
	SET 
		submitted = CONVERT(BIT,1),
		AnswerIdent = EPEA.Ident,
		[values] = STUFF((
						select 
							',"' + EPEAV.Name1 + '": "' + EPEAV.Value1 +'"'

						from 
							#tmpRequirements tRi
							INNER JOIN
							EntityProjectEntityAnswer EPEA WITH (NOLOCK)
								ON tRi.Ident = EPEA.EntityProjectRequirementIdent
							INNER JOIN
							EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
								ON EPEAV.EntityProjectEntityAnswerIdent = EPEA.Ident
						WHERE 
							EPEA.EntityProjectEntityIdent = @intEntityProjectEntityIdent
							AND tRi.RequirementTypeIdent in (12, 18, 10, 19)
							AND tRi.Ident = tR.Ident
							AND EPEA.Active = 1
							AND EPEAV.Active = 1
						for xml path(''), type
					).value('.', 'varchar(max)'), 1, 1, '')  
	FROM
		#tmpRequirements tR
		INNER JOIN
		EntityProjectEntityAnswer EPEA WITH (NOLOCK)
			ON tR.Ident = EPEA.EntityProjectRequirementIdent
		INNER JOIN
		EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
			ON EPEAV.EntityProjectEntityAnswerIdent = EPEA.Ident
	WHERE 
		EPEA.EntityProjectEntityIdent = @intEntityProjectEntityIdent
		AND tR.RequirementTypeIdent in (12, 10, 18, 19)
		AND EPEA.Active = 1
		AND EPEAV.Active = 1

	SELECT DISTINCT
		Ident ,
		model ,
		[type] ,
		EntityProjectIdent ,
		RequirementTypeIdent ,
		label ,
		[description] ,
		placeholder,
		helpText,
		options,
		sortOrder,
		submitted,
		COALESCE(AnswerIdent,0) AS [AnswerIdent],
		[values],
		RequiresAnswer,
		IsFileUpload,
		EntitySearchDataTypeIdent,
		AllowEntityProjectMeasure
	FROM 
		#tmpRequirements
	ORDER BY
		sortOrder ASC

	--Bring back the Header Details for the project
	SELECT DISTINCT 
		EP.Ident,
		EP.Name1,
		EP.PrivateProject,
		EP.ShowOnProfile,
		EP.IncludeEntireNetwork,
		PM.FullName as [ProjectManager],
		PM.Ident as [ProjectManagerIdent],
		PM.PrimaryPhone as [ProjectManagerPhone],
		dbo.ufnGetEntityEmailListByEntityIdent(PM.Ident) as [ProjectManagerEmail],
		'' as [EntityName],
		'' as [EntityIdent],
		CONVERT(VARCHAR(10),EP.DueDate, 101) as [DueDate],
		EP.Archived
	FROM
		EntityProject EP WITH (NOLOCK)
		INNER JOIN
		Entity PM WITH (NOLOCK)
			ON EP.ProjectManagerEntityIdent = PM.Ident	
	WHERE 
		EP.Active = 1
		AND EP.Ident = @bntEntityProjectIdent
		AND EP.EntityIdent = @bntEntityIdent
	UNION ALL

	--Bring back "private Projects" where entire network is included
	SELECT DISTINCT 
		EP.Ident,
		EP.Name1,
		EP.PrivateProject,
		EP.ShowOnProfile,
		EP.IncludeEntireNetwork,
		PM.FullName as [ProjectManager],
		PM.Ident as [ProjectManagerIdent],
		PM.PrimaryPhone as [ProjectManagerPhone],
		dbo.ufnGetEntityEmailListByEntityIdent(PM.Ident) as [ProjectManagerEmail],
		E.FullName as [EntityName],
		E.Ident as [EntityIdent],
		CONVERT(VARCHAR(10),EP.DueDate, 101) as [DueDate],
		EP.Archived
	FROM
		EntityProject EP WITH (NOLOCK)
		INNER JOIN
		EntityNetwork EN WITH (NOLOCK)
			ON EN.FromEntityIdent = EP.EntityIdent
		INNER JOIN
		Entity PM WITH (NOLOCK)
			ON EP.ProjectManagerEntityIdent = PM.Ident	
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON EN.ToEntityIdent = E.Ident	
	WHERE 
		EN.ToEntityIdent = @bntEntityIdent
		AND EP.PrivateProject = 1
		AND EP.IncludeEntireNetwork = 1
		AND EP.EntityIdent = @bntASUserIdent
		AND EP.Ident = @bntEntityProjectIdent
	UNION ALL

	--Bring back "private Projects" where entire network is not included
	SELECT DISTINCT 
		EP.Ident,
		EP.Name1,
		EP.PrivateProject,
		EP.ShowOnProfile,
		EP.IncludeEntireNetwork,
		PM.FullName as [ProjectManager],
		PM.Ident as [ProjectManagerIdent],
		PM.PrimaryPhone as [ProjectManagerPhone],
		dbo.ufnGetEntityEmailListByEntityIdent(PM.Ident) as [ProjectManagerEmail],
		E.FullName as [EntityName],
		E.Ident as [EntityIdent],
		CONVERT(VARCHAR(10),EP.DueDate, 101) as [DueDate],
		EP.Archived
	FROM
		EntityProject EP WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityProjectIdent = EP.Ident
		INNER JOIN
		Entity PM WITH (NOLOCK)
			ON EP.ProjectManagerEntityIdent = PM.Ident	
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON EPE.EntityIdent = E.Ident	
	WHERE 
		EPE.EntityIdent = @bntEntityIdent
		AND EPE.Active = 1
		AND EP.PrivateProject = 1
		AND EP.IncludeEntireNetwork = 0
		AND EP.EntityIdent = @bntASUserIdent
		AND EP.Ident = @bntEntityProjectIdent
	UNION ALL

	--Bring back linked projects
	SELECT DISTINCT
		EP.Ident,
		EP.Name1,
		EP.PrivateProject,
		EP.ShowOnProfile,
		EP.IncludeEntireNetwork,
		PM.FullName as [ProjectManager],
		PM.Ident as [ProjectManagerIdent],
		PM.PrimaryPhone as [ProjectManagerPhone],
		dbo.ufnGetEntityEmailListByEntityIdent(PM.Ident) as [ProjectManagerEmail],
		E.FullName as [EntityName],
		E.Ident as [EntityIdent],
		CONVERT(VARCHAR(10),EP.DueDate, 101) as [DueDate],
		EP.Archived
	FROM
		EntityProject EP WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityProjectIdent = EP.Ident
		INNER JOIN
		Entity PM WITH (NOLOCK)
			ON EP.ProjectManagerEntityIdent = PM.Ident
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON EPE.EntityIdent = E.Ident
	WHERE 
		EPE.EntityIdent = @bntEntityIdent
		AND EPE.Active = 1
		AND EP.PrivateProject = 0
		AND EP.Ident = @bntEntityProjectIdent


GO