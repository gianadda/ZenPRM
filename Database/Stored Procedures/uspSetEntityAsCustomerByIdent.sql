IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspSetEntityAsCustomerByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspSetEntityAsCustomerByIdent
 GO
/* 
 *
 * uspSetEntityAsCustomerByIdent
 *
 *
*/
CREATE PROCEDURE uspSetEntityAsCustomerByIdent

	@intIdent BIGINT, 
	@bntSystemRoleIdent BIGINT,
	@bntEditASUserIdent BIGINT

AS

	SET NOCOUNT ON

	DECLARE @bitIsCustomer BIT
	DECLARE @intProjectCount BIGINT

	SET @intProjectCount = 0
	SET @bitIsCustomer = 0

	SELECT
		@bitIsCustomer = IsCustomer
	FROM
		SystemRole WITH (NOLOCK)
	WHERE
		Ident = @bntSystemRoleIdent

	UPDATE Entity
	SET 
		Customer = @bitIsCustomer,
		SystemRoleIdent = @bntSystemRoleIdent,
		EditDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = @bntEditASUserIdent
	WHERE
		Ident = @intIdent

	SELECT
		@intProjectCount = COUNT(EP.Ident)
	FROM
		EntityProject EP WITH (NOLOCK)
	WHERE
		EP.EntityIdent = @intIdent
		AND EP.Active = 1

	IF (@bitIsCustomer = 1 AND @intProjectCount = 0) -- if the entity doesn't have any projects setup, lets pull in the ZenPRM Templates
		BEGIN
			EXEC uspSetupEntityCustomerTemplates @intIdent, @bntEditASUserIdent
		END

	IF (@bitIsCustomer = 0 AND @intProjectCount > 0) -- if the entity was a customer, and there are lingering projects, we should deactivate them
		BEGIN
			
			UPDATE
				EntityProject
			SET
				Active = 0,
				EditDateTime = dbo.ufnGetMyDate(),
				EditASUserIdent = @bntEditASUserIdent
			WHERE
				EntityIdent = @intIdent
				AND Active = 1
				
		END
		
	SELECT @intIdent as [Ident]
GO