IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddASUserActivityForCompletedRequirements') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspAddASUserActivityForCompletedRequirements
GO

/* uspAddASUserActivityForCompletedRequirements
 *
 *	- adds a log entry for users who have completed entity requirements
 *
 */

CREATE PROCEDURE uspAddASUserActivityForCompletedRequirements

	@bntASUserIdent BIGINT,
	@bntEntityIdent BIGINT,
	@nvrClientIPAddress NVARCHAR(50),
	@nvrNumberOfRequirements NVARCHAR(25),
	@bntEntityProjectRequirementIdent BIGINT

AS
	
	SET NOCOUNT ON

	DECLARE @intActivityTypeCompletedRequirementIdent BIGINT,
			@nvrASUserFullname NVARCHAR(MAX),
			@nvrEntityFullname NVARCHAR(MAX),
			@bntCustomerEntityIdent BIGINT,
			@bntUpdatedEntityIdent BIGINT,
			@nvrEntityProjectName1 NVARCHAR(MAX),
			@bntEntityProjectEntityIdent BIGINT

	SET @intActivityTypeCompletedRequirementIdent = dbo.ufnActivityTypeCompletedRequirement()

	SELECT
		@nvrASUserFullname = U.Fullname
	FROM
		ASUser U WITH (NOLOCK)
	WHERE
		U.Ident = @bntASUserIdent

	SELECT
		@nvrEntityFullname = E.FullName
	FROM
		Entity E WITH (NOLOCK)
	WHERE
		E.Ident = @bntEntityIdent

	SELECT
		@nvrEntityProjectName1 = EP.Name1,
		@bntCustomerEntityIdent = EP.EntityIdent,
		@bntEntityProjectEntityIdent = EPE.Ident,
		@bntUpdatedEntityIdent = EPE.EntityIdent
	FROM
		EntityProjectRequirement EPR WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EPR.EntityProjectIdent = EP.Ident
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityProjectIdent = EP.Ident
	WHERE 
		EPR.Ident = @bntEntityProjectRequirementIdent
		AND EPE.EntityIdent = @bntEntityIdent
		AND EPE.Active = 1
	

	INSERT INTO ASUserActivity(
		ASUserIdent,
		ActivityTypeIdent,
		ActivityDateTime,
		ActivityDescription,
		ClientIPAddress,
		RecordIdent,
		CustomerEntityIdent,
		UpdatedEntityIdent
	)
	SELECT
		ASUserIdent = @bntASUserIdent,
		ActivityTypeIdent = AT.Ident,
		ActivityDateTime = dbo.ufnGetMyDate(),
		ActivityDescription = CASE
								WHEN @bntASUserIdent = @bntEntityIdent THEN REPLACE(REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrASUserFullname),'@@Number',@nvrNumberOfRequirements),'@@ProjectName',@nvrEntityProjectName1),' @@OnBehalfOfEntity','')
									ELSE REPLACE(REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrASUserFullname),'@@Number',@nvrNumberOfRequirements),'@@ProjectName',@nvrEntityProjectName1),' @@OnBehalfOfEntity', ' for ' + @nvrEntityFullname)
								END,
		ClientIPAddress = @nvrClientIPAddress,
		RecordIdent = @bntEntityProjectEntityIdent,
		CustomerEntityIdent = @bntCustomerEntityIdent,
		UpdatedEntityIdent = @bntUpdatedEntityIdent
	FROM
		ActivityType AT WITH (NOLOCK)
	WHERE
		AT.Ident = @intActivityTypeCompletedRequirementIdent

	SELECT SCOPE_IDENTITY() AS [Ident]

GO