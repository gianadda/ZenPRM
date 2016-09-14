IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityProjectByEntityIdentForCustomer') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityProjectByEntityIdentForCustomer
GO

/* uspGetEntityProjectByEntityIdentForCustomer 306485, 306487
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetEntityProjectByEntityIdentForCustomer]

	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT

AS


	SET NOCOUNT ON
	
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
	
	--Verify it's a customer
	SELECT
		@bitEntityIsCustomer = E.Customer
	FROM
		Entity E WITH (NOLOCK)
	WHERE 
		E.Ident = @bntEntityIdent
		
	SELECT 
		@bntCountOfEntitiesInNetwork = COUNT(EN.ToEntityIdent)
	FROM
		EntityNetwork EN WITH (NOLOCK) -- Don't need to verify active on the entity as the view already takes care of that
	WHERE
		EN.FromEntityIdent = @bntEntityIdent

/*
 If the entity is a customer, go get all of the active projects that they own.
*/
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
    SELECT DISTINCT
        EP.Ident,
        EP.EntityIdent,
        'PercentComplete' = 0,
		'TotalEntityProjectEntity' = 0 ,
		'TotalEntityProjectEntityEntityProjectRequirement' = 0 ,
		'TotalEntityProjectEntityEntityProjectAnswers' = 0,
        'ProjectType' = CASE EP.Archived WHEN 1 THEN 'Archived' WHEN 0 THEN 'OPEN' END,
		EP.IncludeEntireNetwork
    FROM
        EntityProject EP WITH (NOLOCK)
    WHERE 
        EP.EntityIdent = @bntEntityIdent
		AND @bitEntityIsCustomer = 1
		AND EP.Active = 1

		

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
		TotalEntityProjectEntity = COUNT(DISTINCT EPP.EntityIdent)
	FROM
		#tmpProjects tP WITH (NOLOCK)
		INNER JOIN
		dbo.ufnGetEntityProjectParticipants(@bntEntityIdent, 0) EPP
			ON tP.Ident = EPP.EntityProjectIdent
	GROUP BY
		tP.Ident


	--Go update the total and the full denominator
	UPDATE tP 
	SET TotalEntityProjectEntity = tV.TotalEntityProjectEntity
	FROM
		#tmpProjects tP
		INNER JOIN
		#tmpTotalEntityProjectEntity tV WITH (NOLOCK)
			ON tP.Ident = tV.Ident


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
		TotalEntityProjectEntityEntityProjectAnswers = COUNT(DISTINCT EPEA.Ident)
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
			AND EPEA.EntityProjecTRequirementIdent = EPR.Ident
		--INNER JOIN
		--EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
		--	ON EPEAV.EntityProjectEntityAnswerIdent = EPEA.Ident
	WHERE 
		EPE.Active = 1
		AND EPR.Active = 1
		AND EPEA.Active = 1
	GROUP BY 
		tP.Ident

	UPDATE tP 
	SET TotalEntityProjectEntityEntityProjectAnswers = tV.TotalEntityProjectEntityEntityProjectAnswers
	FROM
		#tmpProjects tP
		INNER JOIN
		#tmpTotalEntityProjectEntityEntityProjectAnswers tV WITH (NOLOCK)
			ON tP.Ident = tV.Ident




	--Calculate percent complete, we need all of the CASTs to get a rounded decimal of 2 after the .
	UPDATE tP 
	SET PercentComplete = CAST(CAST(TotalEntityProjectEntityEntityProjectAnswers AS DECIMAl(10,2)) / CAST(TotalEntityProjectEntityEntityProjectRequirement * TotalEntityProjectEntity AS DECIMAL(10,2)) * 100  as DECIMAL(10,2))
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
		TotalEntityProjectEntityEntityProjectRequirement * TotalEntityProjectEntity as [TotalEntityProjectEntityEntityProjectRequirement],
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




GO

--EXEC uspGetEntityProjectByEntityIdentForCustomer 306485, 306485