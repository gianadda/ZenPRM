IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspVerifyASUserAccessToEntityProjectRequirementIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspVerifyASUserAccessToEntityProjectRequirementIdent
GO

/* uspVerifyASUserAccessToEntityProjectRequirementIdent
 *
 * Used to add a file to a project from the users repo. Ensures the user has access to this project requirement
 *
 *
*/
CREATE PROCEDURE uspVerifyASUserAccessToEntityProjectRequirementIdent

	@bntEntityProjectRequirementIdent BIGINT,
	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT

AS

	SET NOCOUNT ON

	DECLARE @bitValid BIT

	SET @bitValid = 0

	-- check if the user can answer this requirement
	SELECT
		@bitValid = 1
	FROM
		EntityProjectRequirement EPR WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			 ON EP.Ident = EPR.EntityProjectIdent
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			 ON EPE.EntityProjectIdent = EP.Ident
	WHERE
		EPR.Active = 1
		AND EPR.Ident = @bntEntityProjectRequirementIdent
		AND EP.Active = 1
		AND EPE.Active = 1
		AND EPE.EntityIdent = @bntEntityIdent
		
	-- if not, see if they are the admin
	SELECT
		@bitValid = 1
	FROM
		EntityProjectRequirement EPR WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			 ON EP.Ident = EPR.EntityProjectIdent
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			 ON EPE.EntityProjectIdent = EP.Ident
	WHERE
		EPR.Active = 1
		AND EPR.Ident = @bntEntityProjectRequirementIdent
		AND EP.Active = 1
		AND EP.EntityIdent = @bntEntityIdent
		AND @bitValid = 0

	SELECT @bitValid as [Valid]

GO