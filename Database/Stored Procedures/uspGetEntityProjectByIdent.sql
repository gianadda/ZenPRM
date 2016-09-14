IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityProjectByIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityProjectByIdent
GO

/* uspGetEntityProjectByIdent
 *
 * get a single project record (for export) based on ident. also, ensure entity has access to this project
 *
 *
*/
CREATE PROCEDURE uspGetEntityProjectByIdent

	@bntEntityProjectIdent BIGINT,
	@bntASUserIdent BIGINT

AS

	SET NOCOUNT ON

	DECLARE @bntTotalEntityProjectEntity BIGINT
	DECLARE @bntTotalEntityProjectFiles BIGINT
	
	/*
	*  We are going to get all of the Entities that are linked to the project for the stats calculations
	*/
	SELECT 
		@bntTotalEntityProjectEntity = COUNT(DISTINCT E.Ident)
	FROM
        EntityProject EP WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityProjectIdent = EP.Ident
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON EPE.EntityIdent = E.Ident
	WHERE 
		EP.EntityIdent = @bntASUserIdent
		AND EP.Ident = @bntEntityProjectIdent
		AND EPE.Active = 1
		AND E.Active = 1

	/*
	*  We are going to get all of the files  that are linked to the project for the stats calculations
	*/
	SELECT 
		@bntTotalEntityProjectFiles = COUNT(DISTINCT EFR.AnswerIdent)
	FROM
		EntityFileRepository EFR WITH (NOLOCK)
	WHERE 
		EFR.ProjectIdent = @bntEntityProjectIdent
		AND EFR.Active = 1

	--Select back all results
    SELECT DISTINCT
        EP.Ident,
        EP.EntityIdent,
        EP.Name1,
		COALESCE(@bntTotalEntityProjectEntity, 0)  as [TotalEntityProjectEntity],
		COALESCE(@bntTotalEntityProjectFiles, 0) as [TotalEntityProjectFiles]
    FROM
        EntityProject EP WITH (NOLOCK)
    WHERE 
        EP.EntityIdent = @bntASUserIdent
		AND EP.Ident = @bntEntityProjectIdent
		AND EP.Active = 1
   

GO