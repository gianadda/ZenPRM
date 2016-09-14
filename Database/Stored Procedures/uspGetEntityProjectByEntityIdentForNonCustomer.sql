IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityProjectByEntityIdentForNonCustomer') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityProjectByEntityIdentForNonCustomer
GO

/* uspGetEntityProjectByEntityIdentForNonCustomer 306489, 306489
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetEntityProjectByEntityIdentForNonCustomer]

	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT

AS


	SET NOCOUNT ON
	

--Time tracking
DECLARE @StartTime datetime
DECLARE @EndTime datetime
SELECT @StartTime=GETDATE() 

	/*
		1. Get list of projects to show
		2. Get total count of entities on each project
		3. Get requirements, total answers, total full submissions and total potential submissions, total partial submissions 
	*/
	
	DECLARE @bitEntityIsCustomer BIT,
			@bntCountOfEntitiesInNetwork BIGINT

	SET @bitEntityIsCustomer = 0
	SET @bntCountOfEntitiesInNetwork = 0

	
	CREATE TABLE #tmpProjects (
		Ident BIGINT,
		EntityIdent BIGINT,
		PercentComplete VARCHAR(MAX),
		TotalEntityProjectEntity BIGINT,
		TotalEntityProjectEntityEntityProjectRequirement BIGINT,
		TotalEntityProjectEntityEntityProjectAnswers BIGINT,
		ProjectType VARCHAR(MAX),
		IncludeEntireNetwork BIT
	)

	CREATE TABLE #tmpTotalEntityProjectEntity (
		Ident BIGINT,
		TotalEntityProjectEntity BIGINT
	)

	CREATE TABLE #tmpTotalEntityProjectEntityEntityProjectRequirement (
		Ident BIGINT,
		TotalEntityProjectEntityEntityProjectRequirement BIGINT
	)
	
	CREATE TABLE #tmpTotalEntityProjectEntityEntityProjectAnswers (
		Ident BIGINT,
		TotalEntityProjectEntityEntityProjectAnswers BIGINT
	)
	


	/*
	 This isn't for customers, so go get any projects that we are linked to via EPE or via networks and IncludeEntireNetwork
	*/

	-- first get any projects that the entity is linked to (if the entity is the user)
	INSERT INTO #tmpProjects (
		Ident ,
		EntityIdent,
		PercentComplete,
		TotalEntityProjectEntity ,
		TotalEntityProjectEntityEntityProjectRequirement ,
		TotalEntityProjectEntityEntityProjectAnswers ,
		ProjectType,
		IncludeEntireNetwork
	)
	SELECT -- 1. I am looking for my own projects, so bring back everything I am linked to that isnt private
		EP.Ident,
        EP.EntityIdent,
        'PercentComplete' = 0,
		'TotalEntityProjectEntity' = 1 ,
		'TotalEntityProjectEntityEntityProjectRequirement' = 0 ,
		'TotalEntityProjectEntityEntityProjectAnswers' = 0,
        'ProjectType' = CASE EP.Archived WHEN 1 THEN 'Archived' WHEN 0 THEN 'OPEN' END,
		EP.IncludeEntireNetwork
	FROM
		EntityProject EP WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityProjectIdent = EP.Ident
	WHERE
		@bntEntityIdent = @bntASUserIdent
		AND EPE.EntityIdent = @bntEntityIdent
		AND EPE.Active = 1
		AND EP.Active = 1
		AND EP.PrivateProject = 0
	UNION
	SELECT -- 2. I am looking for my own projects, so make sure we include projects that are IncludeEntireNetwork = true
		EP.Ident,
        EP.EntityIdent,
        'PercentComplete' = 0,
		'TotalEntityProjectEntity' = 1 ,
		'TotalEntityProjectEntityEntityProjectRequirement' = 0 ,
		'TotalEntityProjectEntityEntityProjectAnswers' = 0,
        'ProjectType' = CASE EP.Archived WHEN 1 THEN 'Archived' WHEN 0 THEN 'OPEN' END,
		EP.IncludeEntireNetwork
	FROM
		EntityProject EP WITH (NOLOCK)
		INNER JOIN
		EntityNetwork EN WITH (NOLOCK)
			ON EN.FromEntityIdent = EP.EntityIdent
	WHERE
		@bntEntityIdent = @bntASUserIdent
		AND EN.ToEntityIdent = @bntEntityIdent
		AND EN.Active = 1
		AND EP.Active = 1
		AND EP.IncludeEntireNetwork = 1
		AND EP.PrivateProject = 0
	UNION
	SELECT -- 3. OK, now I am the customer, so bring me back this resources linked projects
		EP.Ident,
        EP.EntityIdent,
        'PercentComplete' = 0,
		'TotalEntityProjectEntity' = 1 ,
		'TotalEntityProjectEntityEntityProjectRequirement' = 0 ,
		'TotalEntityProjectEntityEntityProjectAnswers' = 0,
        'ProjectType' = CASE EP.Archived WHEN 1 THEN 'Archived' WHEN 0 THEN 'OPEN' END,
		EP.IncludeEntireNetwork
	FROM
		EntityProject EP WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityProjectIdent = EP.Ident
	WHERE
		EPE.EntityIdent = @bntEntityIdent
		AND EPE.Active = 1
		AND EP.EntityIdent = @bntASUserIdent
		AND EP.Active = 1
	UNION
	SELECT -- 4. OK, now I am the customer, so make sure we include projects that are IncludeEntireNetwork = true
		EP.Ident,
        EP.EntityIdent,
        'PercentComplete' = 0,
		'TotalEntityProjectEntity' = 1 ,
		'TotalEntityProjectEntityEntityProjectRequirement' = 0 ,
		'TotalEntityProjectEntityEntityProjectAnswers' = 0,
        'ProjectType' = CASE EP.Archived WHEN 1 THEN 'Archived' WHEN 0 THEN 'OPEN' END,
		EP.IncludeEntireNetwork
	FROM
		EntityProject EP WITH (NOLOCK)
		INNER JOIN
		EntityNetwork EN WITH (NOLOCK)
			ON EN.FromEntityIdent = EP.EntityIdent
	WHERE
		EN.ToEntityIdent = @bntEntityIdent
		AND EN.Active = 1
		AND EP.EntityIdent = @bntASUserIdent
		AND EP.Active = 1
		AND EP.IncludeEntireNetwork = 1


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
		tP.Ident,
		TotalEntityProjectEntity = COUNT(EPE.EntityIdent)
	FROM
		#tmpProjects tP WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityProjectIdent = tP.Ident
	WHERE 
		tP.IncludeEntireNetwork = 0
		AND EPE.Active = 1
	GROUP BY 
		tP.Ident


SELECT @EndTime=GETDATE()
--This will return execution time of your query
PRINT 'Duration (post projects)' + convert(varchar,DATEDIFF(MS,@StartTime,@EndTime) ) + ' MS'


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
		tP.Ident,
		TotalEntityProjectEntityEntityProjectRequirement = COUNT(DISTINCT EPR.Ident)
	FROM
		#tmpProjects tP WITH (NOLOCK)
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.EntityProjectIdent = tP.Ident
		INNER JOIN
		RequirementType RT WITH (NOLOCK)
			ON EPR.RequirementTypeIdent = RT.Ident
	WHERE 
		EPR.Active = 1
		AND RT.Active = 1
		AND RT.RequiresAnswer = 1
	GROUP BY 
		tP.Ident


	UPDATE tP 
	SET TotalEntityProjectEntityEntityProjectRequirement = tV.TotalEntityProjectEntityEntityProjectRequirement
	FROM
		#tmpProjects tP
		INNER JOIN
		#tmpTotalEntityProjectEntityEntityProjectRequirement tV WITH (NOLOCK)
			ON tP.Ident = tV.Ident




SELECT @EndTime=GETDATE()
--This will return execution time of your query
PRINT 'Duration (post requirements)' + convert(varchar,DATEDIFF(MS,@StartTime,@EndTime) ) + ' MS'

/*
*
*  We are going to get the count of answers (by project and Entity) so we can calculate percent complete
*
*/
	INSERT INTO #tmpTotalEntityProjectEntityEntityProjectAnswers(
		Ident,
		TotalEntityProjectEntityEntityProjectAnswers
	)
	SELECT 
		tP.Ident,
		TotalEntityProjectEntityEntityProjectAnswers = COUNT(DISTINCT EPR.Ident)
	FROM
		#tmpProjects tP WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityProjectIdent = tP.Ident
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.EntityProjectIdent = tP.Ident
		INNER JOIN
		EntityProjectEntityAnswer EPEA WITH (NOLOCK)
			ON EPEA.EntityProjectEntityIdent = EPE.Ident
			AND EPEA.EntityProjectRequirementIdent = EPR.Ident
		--INNER JOIN
		--EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
		--	ON EPEAV.EntityProjectEntityAnswerIdent = EPEA.Ident
	WHERE 
        EPE.EntityIdent = @bntEntityIdent
		AND EPE.Active = 1
		AND EPEA.Active = 1
		AND EPR.Active = 1
	GROUP BY 
		tP.Ident

	UPDATE tP 
	SET TotalEntityProjectEntityEntityProjectAnswers = tV.TotalEntityProjectEntityEntityProjectAnswers
	FROM
		#tmpProjects tP
		INNER JOIN
		#tmpTotalEntityProjectEntityEntityProjectAnswers tV WITH (NOLOCK)
			ON tP.Ident = tV.Ident



SELECT @EndTime=GETDATE()
--This will return execution time of your query
PRINT 'Duration (post answers)' + convert(varchar,DATEDIFF(MS,@StartTime,@EndTime) ) + ' MS'
			
	--Calculate percent complete, we need all of the CASTs to get a rounded decimal of 2 after the .
	UPDATE tP 
	SET PercentComplete = CAST(CAST(TotalEntityProjectEntityEntityProjectAnswers AS DECIMAl(10,2)) / CAST(TotalEntityProjectEntityEntityProjectRequirement  AS DECIMAL(10,2)) * 100  as DECIMAL(10,2))

	FROM
		#tmpProjects tP
	WHERE 
		 TotalEntityProjectEntityEntityProjectRequirement  * TotalEntityProjectEntity <> 0 -- no divide by zero


	SELECT DISTINCT 
		tP.Ident ,
		tP.EntityIdent,
        'Name1' = EP.Name1,
        'EntityName' = E.FullName,
        'ProjectManager' = PM.FullName,
        'ProjectManagerIdent' = PM.Ident,
        'DueDate' = CONVERT(VARCHAR(10),EP.DueDate, 101),
        EP.PrivateProject,
        EP.ShowOnProfile,
        EP.IncludeEntireNetwork,
		tP.PercentComplete,
		TotalEntityProjectEntity ,
		TotalEntityProjectEntityEntityProjectRequirement as [TotalEntityProjectEntityEntityProjectRequirement],
		TotalEntityProjectEntityEntityProjectAnswers,
        EP.Archived,
        EP.ArchivedASUserIdent,
        EP.ArchivedDateTime,
        EP.AddASUserIdent,
        EP.AddDateTime,
        EP.EditASUserIdent,
        EP.EditDateTime,
        EP.Active,
		tP.ProjectType	
	FROM
		#tmpProjects tP WITH (NOLOCK)
		INNER JOIN
        EntityProject EP WITH (NOLOCK)
			ON EP.Ident = tP.Ident
		INNER JOIN
		Entity E WITH (NOLOCK) --This is the project owner
			ON EP.EntityIdent = E.Ident
        INNER JOIN
        Entity PM WITH (NOLOCK)
            ON EP.ProjectManagerEntityIdent = PM.Ident
	ORDER BY 
		EP.Name1

			
	DROP TABLE #tmpProjects
	DROP TABLE #tmpTotalEntityProjectEntity
	DROP TABLE #tmpTotalEntityProjectEntityEntityProjectRequirement
	DROP TABLE #tmpTotalEntityProjectEntityEntityProjectAnswers


SELECT @EndTime=GETDATE()
--This will return execution time of your query
PRINT 'Duration ' + convert(varchar,DATEDIFF(MS,@StartTime,@EndTime) ) + ' MS'


	
GO

-- EXEC uspGetEntityProjectByEntityIdentForNonCustomer 306486, 306486