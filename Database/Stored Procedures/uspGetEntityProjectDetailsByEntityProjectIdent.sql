IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityProjectDetailsByEntityProjectIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityProjectDetailsByEntityProjectIdent
GO

/* uspGetEntityProjectDetailsByEntityProjectIdent 506, 2, 506
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetEntityProjectDetailsByEntityProjectIdent]

	@bntEntityIdent BIGINT,
	@bntEntityProjectIdent BIGINT,
	@bntASUserIdent BIGINT,
	@bitIncludeQuestions BIT = 0,
	@bitIncludeParticipants BIT = 0,
	@bitIncludeAnswerCount BIT = 0

AS

/*
We need to bring back 3 tables, 
	1. the questions with percent completes
	2. The PM
	3. The patricipants with percent completes
	
*/

	DECLARE @intSendRegistrationEmail INT,
			@intSendProjectNotification INT,
			@intNotRegisteredByNoEmail INT,
			@intRegisteredByMarkedAsNonNotify INT,
			@intPrivateResources INT,
			@bntTotalEntityProjectEntityEntityProjectRequirement BIGINT

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
		CreateToDoUponCompletion BIT,
		ToDoTitle NVARCHAR(MAX),
		ToDoDesc1 NVARCHAR(MAX),
		ToDoAssigneeEntityIdent BIGINT,
		ToDoAssignee NVARCHAR(MAX),
		ToDoAssigneeProfilePhoto NVARCHAR(MAX),
		ToDoDueDateNoOfDays INT,
		TotalEntityProjectEntity BIGINT,
		TotalEntityProjectEntityEntityProjectRequirement BIGINT,
		TotalEntityProjectEntityEntityProjectAnswers BIGINT,
		PercentComplete VARCHAR(MAX)
	)
	
	
	CREATE TABLE #tmpTotalEntityProjectEntity (
		Ident BIGINT,
		TotalEntityProjectEntity BIGINT
	)
	
	CREATE TABLE #tmpTotalEntityProjectEntityEntityProjectAnswers (
		EntityProjectRequirementIdent BIGINT,
		TotalEntityProjectEntityEntityProjectAnswers BIGINT
	)
	
	CREATE TABLE #tmpTotalEntityProjectEntityEntityProjectRequirement (
		Ident BIGINT,
		TotalEntityProjectEntityEntityProjectRequirement BIGINT
	)

	CREATE TABLE #tmpEntityProjectEntity (
		EntityIdent BIGINT,
		FullName NVARCHAR(MAX),
		DisplayName NVARCHAR(MAX),
		NPI VARCHAR(500),
		PrimaryPhone NVARCHAR(MAX),
		EntityEmail NVARCHAR(MAX),
		ProfilePhoto NVARCHAR(MAX),
		Registered BIT,
		LastEmailNotificationSent DATETIME,
		PublicResource BIT
	)
	
	CREATE TABLE #tmpEntityProjectEntityAnswerCount(
		EntityIdent BIGINT,
		AnswerCount BIGINT
	)
	
-- Go get all of the Questions
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
		CreateToDoUponCompletion,
		ToDoTitle,
		ToDoDesc1,
		ToDoAssigneeEntityIdent,
		ToDoAssignee,
		ToDoAssigneeProfilePhoto,
		ToDoDueDateNoOfDays,
		TotalEntityProjectEntity,
		TotalEntityProjectEntityEntityProjectRequirement ,
		TotalEntityProjectEntityEntityProjectAnswers ,
		PercentComplete
	)
	SELECT 
		EPR.Ident,
		'model' = EPR.Ident,
		'type' = RT.Name1,
		EPR.EntityProjectIdent,
		EPR.RequirementTypeIdent,
		'label' = EPR.Label,
		'description' = EPR.Desc1,
		'placeholder' = EPR.PlaceholderText,
		'helpText' = EPR.HelpText,
		'options' = EPR.Options,
		'sortOrder' = EPR.SortOrder,
		EPR.CreateToDoUponCompletion,
		EPR.ToDoTitle,
		EPR.ToDoDesc1,
		EPR.ToDoAssigneeEntityIdent,
		ToDoAssignee = '', -- update later if Entity > 0
		ToDoAssigneeProfilePhoto = '', -- update later if Entity > 0
		EPR.ToDoDueDateNoOfDays,
		'TotalEntityProjectEntity' = 0,
		'TotalEntityProjectEntityEntityProjectRequirement' = 0 ,
		'TotalEntityProjectEntityEntityProjectAnswers' = 0,
		'PercentComplete' = 0
	FROM
		EntityProjectRequirement EPR WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EPR.EntityProjectIdent = EP.Ident
		INNER JOIN
		RequirementType RT WITH (NOLOCK)
			ON EPR.RequirementTypeIdent = RT.Ident
	WHERE 
		@bitIncludeQuestions = 1
		AND EP.Active = 1
		AND EPR.Active = 1
		AND EP.Ident = @bntEntityProjectIdent
		AND EP.EntityIdent = @bntEntityIdent

	UPDATE tR
	SET
		ToDoAssignee = E.FullName,
		ToDoAssigneeProfilePhoto = E.ProfilePhoto
	FROM
		#tmpRequirements tR WITH (NOLOCK)
		INNER JOIN
		Entity E WITH (NOLOCK)
			 ON E.Ident = tR.ToDoAssigneeEntityIdent
	WHERE
		tR.ToDoAssigneeEntityIdent > 0
		
/*
*
*  We are going to get all of the Entities that are linked to the project for the stats calculations
*
*/
	INSERT INTO #tmpTotalEntityProjectEntity(
		Ident,
		TotalEntityProjectEntity
	)
	SELECT 
		EPP.EntityProjectIdent,
		TotalEntityProjectEntity = COUNT(DISTINCT EPP.EntityIdent)
	FROM
		dbo.ufnGetEntityProjectParticipants(0, @bntEntityProjectIdent) EPP
	WHERE 
		@bitIncludeAnswerCount = 1
	GROUP BY
		EPP.EntityProjectIdent

	--Go update the total and the full denominator
	UPDATE tR 
	SET TotalEntityProjectEntity = tV.TotalEntityProjectEntity
	FROM
		#tmpRequirements tR
		INNER JOIN
		#tmpTotalEntityProjectEntity tV WITH (NOLOCK)
			ON tR.EntityProjectIdent = tV.Ident
	WHERE
		@bitIncludeAnswerCount = 1

/*
*
*  We are going to get the count of requirements (by project) so we can calculate percent complete 
*		NOTE: only include ones that "RequiresAnswer"
*/
	INSERT INTO #tmpTotalEntityProjectEntityEntityProjectRequirement(
		Ident,
		TotalEntityProjectEntityEntityProjectRequirement
	)
	SELECT 
		EP.Ident,
		TotalEntityProjectEntityEntityProjectRequirement = COUNT(DISTINCT EPR.Ident)
	FROM
        EntityProject EP WITH (NOLOCK)
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.EntityProjectIdent = EP.Ident
		INNER JOIN
		RequirementType RT WITH (NOLOCK)
			ON EPR.RequirementTypeIdent = RT.Ident
	WHERE 
		@bitIncludeAnswerCount = 1
		AND EP.Active = 1
		AND EP.Ident = @bntEntityProjectIdent
		AND EPR.Active = 1
		AND RT.RequiresAnswer = 1
	GROUP BY
		EP.Ident
		

	UPDATE tR
		SET TotalEntityProjectEntityEntityProjectRequirement = tV.TotalEntityProjectEntityEntityProjectRequirement
	FROM
		#tmpRequirements tR
		INNER JOIN
		#tmpTotalEntityProjectEntityEntityProjectRequirement tV WITH (NOLOCK)
			ON tR.EntityProjectIdent = tV.Ident
	WHERE
		@bitIncludeQuestions = 1
		AND @bitIncludeAnswerCount = 1

	IF (@bitIncludeQuestions = 1 AND @bitIncludeAnswerCount = 1)
	BEGIN

		SELECT @bntTotalEntityProjectEntityEntityProjectRequirement = tR.TotalEntityProjectEntityEntityProjectRequirement 
		FROM
			#tmpRequirements tR WITH (NOLOCK)

	END

	
	IF (@bitIncludeParticipants = 1 AND @bitIncludeAnswerCount = 1 AND @bitIncludeQuestions = 0)
	BEGIN

		SELECT @bntTotalEntityProjectEntityEntityProjectRequirement = COUNT(*)
		FROM
			EntityProjectRequirement EPR WITH (NOLOCK)
			INNER JOIN
			RequirementType RT WITH (NOLOCK)
				ON EPR.RequirementTypeIdent = RT.Ident
		WHERE
			EPR.Active = 1
			AND EPR.EntityProjectIdent = @bntEntityProjectIdent
			AND RT.RequiresAnswer = 1

	END


/*
*
*  We are going to get the count of answers (by project and requirement) so we can calculate percent complete (we also use this to determine if the question is answered)
*
*/
	INSERT INTO #tmpTotalEntityProjectEntityEntityProjectAnswers(
		EntityProjectRequirementIdent,
		TotalEntityProjectEntityEntityProjectAnswers
	)
	SELECT 
		EPEA.EntityProjectRequirementIdent,
		TotalEntityProjectEntityEntityProjectAnswers = COUNT(DISTINCT EPEA.Ident)
	FROM
        EntityProject EP WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityProjectIdent = EP.Ident
		INNER JOIN
		EntityProjectEntityAnswer EPEA WITH (NOLOCK)
			ON EPEA.EntityProjectEntityIdent = EPE.Ident
	WHERE 
		(@bitIncludeAnswerCount = 1 OR @bitIncludeQuestions = 1)
		AND EP.Active = 1
		AND EPE.Active = 1
		AND EPEA.Active = 1
		AND EP.Ident = @bntEntityProjectIdent
	GROUP BY 
		EPEA.EntityProjectRequirementIdent

	UPDATE tR 
	SET TotalEntityProjectEntityEntityProjectAnswers = tV.TotalEntityProjectEntityEntityProjectAnswers
	FROM
		#tmpRequirements tR
		INNER JOIN
		#tmpTotalEntityProjectEntityEntityProjectAnswers tV WITH (NOLOCK)
			ON tR.Ident  = tV.EntityProjectRequirementIdent
	WHERE
		(@bitIncludeAnswerCount = 1 OR @bitIncludeQuestions = 1)
	

	--Calculate percent complete, we need all of the CASTs to get a rounded decimal of 2 after the .
	UPDATE tR 
	SET PercentComplete =  CAST(CAST(TotalEntityProjectEntityEntityProjectAnswers AS DECIMAl) / CAST(TotalEntityProjectEntity AS DECIMAL) * 100  as DECIMAL (6,2))
	FROM
		#tmpRequirements tR
	WHERE 
		 @bitIncludeAnswerCount = 1
		 AND TotalEntityProjectEntityEntityProjectRequirement <> 0
		 AND TotalEntityProjectEntity > 0


/*
* We need to get a list of the Entity on the project
*
*/
	INSERT INTO #tmpEntityProjectEntity (
		EntityIdent ,
		FullName ,
		DisplayName ,
		NPI ,
		PrimaryPhone ,
		EntityEmail ,	
		ProfilePhoto,	
		Registered,
		PublicResource
	)
	SELECT 
		E.Ident ,
		E.FullName,
		E.DisplayName,
		E.NPI,
		E.PrimaryPhone,
		dbo.ufnGetEntityEmailListForNotifyByEntityIdent(E.Ident, E.Username),
		E.ProfilePhoto,
		E.Registered,
		ET.IncludeInCNP
	FROM
		dbo.ufnGetEntityProjectParticipants(0, @bntEntityProjectIdent) EPP
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = EPP.EntityIdent
		INNER JOIN
		EntityType ET WITH (NOLOCK)
			ON ET.Ident = E.EntityTypeIdent
	WHERE 
		@bitIncludeParticipants = 1

	UPDATE
		tEPE
	SET
		LastEmailNotificationSent = EPE.LastEmailNotificationSent
	FROM
		#tmpEntityProjectEntity tEPE WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityIdent = tEPE.EntityIdent
			AND EPE.EntityProjectIdent = @bntEntityProjectIdent
	WHERE
		@bitIncludeParticipants = 1
		AND EPE.Active = 1
		
--FINAL Selects

	SELECT DISTINCT 
		tR.Ident ,
		tR.model ,
		tR.[type] ,
		tR.EntityProjectIdent ,
		tR.RequirementTypeIdent ,
		tR.label ,
		tR.[description] ,
		tR.placeholder,
		tR.helpText,
		tR.options,
		RT.HasOptions,
		RT.AllowMultipleOptions,
		RT.RequiresAnswer,
		tR.sortOrder,
		tR.CreateToDoUponCompletion,
		tR.ToDoTitle,
		tR.ToDoDesc1,
		tR.ToDoAssigneeEntityIdent,
		tR.ToDoAssignee,
		tR.ToDoAssigneeProfilePhoto,
		tR.ToDoDueDateNoOfDays,
		tR.TotalEntityProjectEntity as [TotalEntityProjectEntityEntityProjectRequirement],
		tR.TotalEntityProjectEntityEntityProjectAnswers ,
		tR.PercentComplete
	FROM 
		#tmpRequirements tR WITH (NOLOCK)
		INNER JOIN
		RequirementType RT WITH (NOLOCK)
			ON RT.Ident = tR.RequirementTypeIdent
	ORDER BY
		tR.sortOrder ASC

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
		CONVERT(VARCHAR(10),EP.DueDate, 101) as [DueDate],
		EP.Archived,
		EP.AllowOpenRegistration,
		EP.ProjectGUID
	FROM
		EntityProject EP WITH (NOLOCK)
		INNER JOIN
		Entity PM WITH (NOLOCK)
			ON EP.ProjectManagerEntityIdent = PM.Ident		
	WHERE 
		EP.Active = 1
		AND EP.Ident = @bntEntityProjectIdent
		AND EP.EntityIdent = @bntEntityIdent

	INSERT INTO #tmpEntityProjectEntityAnswerCount(
		EntityIdent,
		AnswerCount
	)
	SELECT
		tEPE.EntityIdent,	
		COUNT(DISTINCT EPEA.Ident) as [TotalEntityProjectEntityEntityProjectAnswers] 
	FROM
		#tmpEntityProjectEntity tEPE WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityIdent = tEPE.EntityIdent
				AND EPE.EntityProjectIdent = @bntEntityProjectIdent
		INNER JOIN
		EntityProjectEntityAnswer EPEA WITH (NOLOCK)
			ON EPEA.EntityProjectEntityIdent = EPE.Ident	
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.Ident = EPEA.EntityProjectRequirementIdent
	WHERE
		@bitIncludeAnswerCount = 1
		AND EPEA.Active = 1
		AND EPR.Active = 1 -- dont count answered questions for deleted questions
		AND EPE.Active = 1
	GROUP BY 
		tEPE.EntityIdent

	-- GET OUR COUNTS FOR THE SEND EMAIL PROCESS
	SELECT
		@intSendRegistrationEmail = COUNT(tEPE.EntityIdent)
	FROM
		#tmpEntityProjectEntity tEPE WITH (NOLOCK)
	WHERE
		tEPE.Registered = 0
		AND PublicResource = 1
		AND EntityEmail <> ''

	SELECT
		@intSendProjectNotification = COUNT(*)
	FROM
		#tmpEntityProjectEntity WITH (NOLOCK)
	WHERE
		Registered = 1
		AND PublicResource = 1
		AND EntityEmail <> ''

	SELECT
		@intNotRegisteredByNoEmail = COUNT(*)
	FROM
		#tmpEntityProjectEntity WITH (NOLOCK)
	WHERE
		Registered = 0
		AND PublicResource = 1
		AND EntityEmail = ''
	
	SELECT
		@intRegisteredByMarkedAsNonNotify = COUNT(*)
	FROM
		#tmpEntityProjectEntity WITH (NOLOCK)
	WHERE
		Registered = 1
		AND PublicResource = 1
		AND EntityEmail = ''

	SELECT
		@intPrivateResources = COUNT(*)
	FROM
		#tmpEntityProjectEntity WITH (NOLOCK)
	WHERE
		PublicResource = 0

	SELECT
		tEPE.EntityIdent as [Ident],
		tEPE.FullName,
		tEPE.DisplayName,
		tEPE.NPI ,
		tEPE.PrimaryPhone,
		tEPE.EntityEmail as [Email],
		tEPE.ProfilePhoto,
		tEPE.Registered,
		tEPE.LastEmailNotificationSent,
		COALESCE(@bntTotalEntityProjectEntityEntityProjectRequirement,0) as [TotalEntityProjectEntityEntityProjectRequirement],
		COALESCE(tEPEAC.AnswerCount,0) as [TotalEntityProjectEntityEntityProjectAnswers] 
	FROM
		#tmpEntityProjectEntity tEPE WITH (NOLOCK)
		LEFT OUTER JOIN
		#tmpEntityProjectEntityAnswerCount tEPEAC WITH (NOLOCK)
			ON tEPEAC.EntityIdent = tEPE.EntityIdent
	GROUP BY 
		tEPE.EntityIdent,
		tEPE.NPI ,
		tEPE.FullName,
		tEPE.DisplayName,
		tEPE.PrimaryPhone,
		tEPE.EntityEmail,
		tEPE.Registered,
		tEPE.LastEmailNotificationSent,
		tEPEAC.AnswerCount,
		tEPE.ProfilePhoto
	ORDER BY
		tEPE.FullName ASC

	SELECT
		@intSendRegistrationEmail as [SendRegistrationEmail],
		@intSendProjectNotification as [SendProjectNotification],
		@intNotRegisteredByNoEmail as [NotRegisteredByNoEmail],
		@intRegisteredByMarkedAsNonNotify as [RegisteredByMarkedAsNonNotify],
		@intPrivateResources as [PrivateResources]

DROP TABLE #tmpRequirements
DROP TABLE #tmpTotalEntityProjectEntity
DROP TABLE #tmpTotalEntityProjectEntityEntityProjectAnswers
DROP TABLE #tmpTotalEntityProjectEntityEntityProjectRequirement
DROP TABLE #tmpEntityProjectEntity
DROP TABLE #tmpEntityProjectEntityAnswerCount

GO
-- EXEC uspGetEntityProjectDetailsByEntityProjectIdent 2, 42, 2, 0, 1, 1

-- EXEC uspGetEntityProjectDetailsByEntityProjectIdent 306485, 10092, 306485, 0, 1, 1
