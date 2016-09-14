IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspRemoveEntityFromNetwork') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspRemoveEntityFromNetwork
 GO
/* uspRemoveEntityFromNetwork 2,	16, 9
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspRemoveEntityFromNetwork]

	@intFromEntityIdent BIGINT, 
	@intToEntityIdent BIGINT,
	@intEditASUserIdent BIGINT

AS

	SET NOCOUNT ON

	DECLARE @bitFromEntityIsACustomer AS BIT,
			@intNumberOfProjects AS INT
	
	SET @bitFromEntityIsACustomer = 0
	SET @intNumberOfProjects = 0
	
	CREATE TABLE #tmpRecordsToBeDeActivated (
		EntityConnectionIdent BIGINT
	)

	SELECT 
		@bitFromEntityIsACustomer = 1
	FROM
		Entity E WITH (NOLOCK)
	WHERE 
		E.Ident = @intFromEntityIdent
		AND E.Customer = 1
		AND E.Active = 1

	SELECT 
		@intNumberOfProjects = COUNT(DISTINCT EP.Ident)
	FROM
		EntityProject EP WITH (NOLOCK) 
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EP.Ident = EPE.EntityProjectIdent
	WHERE 
		EPE.EntityIdent = @intToEntityIdent
		AND EP.EntityIdent = @intFromEntityIdent
		AND EPE.Active = 1
		AND EP.Active = 1
		AND EP.Archived = 0
		AND EP.PrivateProject = 0


	INSERT INTO  #tmpRecordsToBeDeActivated (
		EntityConnectionIdent
	)
	SELECT 
		EC.Ident
	FROM
		EntityConnection EC WITH (NOLOCK)
		INNER JOIN
		ConnectionType CT WITH (NOLOCK)
			ON EC.ConnectionTypeIdent = CT.Ident
	WHERE 
		EC.FromEntityIdent = @intFromEntityIdent
		AND EC.ToEntityIdent = @intToEntityIdent
		AND CT.IncludeInNetwork = 1
		AND @intNumberOfProjects = 0
		AND EC.Active = 1

	UPDATE EC
	SET Active = 0,
		EditASUserIdent = @intEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()
	FROM
		EntityConnection EC
		INNER JOIN
		#tmpRecordsToBeDeActivated tRDA WITH (NOLOCK)
			ON EC.Ident = tRDA.EntityConnectionIdent

	SELECT 
		EC.Ident
	FROM
		EntityConnection EC
		INNER JOIN
		#tmpRecordsToBeDeActivated tRDA WITH (NOLOCK)
			ON EC.Ident = tRDA.EntityConnectionIdent

	SELECT @intNumberOfProjects as [ProjectsFound]

	DROP TABLE #tmpRecordsToBeDeActivated

GO

-- uspRemoveEntityFromNetwork 506, 226845, 506