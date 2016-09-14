IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspVerifyEntityProjectEntityForOpenRegistration') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspVerifyEntityProjectEntityForOpenRegistration
 GO
/* uspVerifyEntityProjectEntityForOpenRegistration
 *
 * For Open Registration
 * 1. Ensures that the resource is in the customers network
 * 2. Ensures that the resource is on the project
*/
CREATE PROCEDURE uspVerifyEntityProjectEntityForOpenRegistration

	@intASUserIdent BIGINT, 
	@intEntityProjectIdent BIGINT

AS

	SET NOCOUNT ON

	DECLARE @intEntityIdent BIGINT

	SELECT 
		@intEntityIdent = EP.EntityIdent
	FROM
		EntityProject EP WITH (NOLOCK)
	WHERE 
		EP.Ident = @intEntityProjectIdent

	-- we need to attach the resource to the customers network (this SP will check unique)
	EXEC uspAddEntityToNetwork  @intFromEntityIdent = @intEntityIdent,
								@intToEntityIdent = @intASUserIdent,
								@intAddASUserIdent = @intASUserIdent,
								@bitActive = 1,
								@bitSuppressOutput = 1

	-- next ensure that they are added to the project 
	EXEC uspAddEntityToEntityProject  @intFromEntityIdent = @intEntityIdent,
										@intToEntityIdent = @intASUserIdent,
										@intEntityProjectIdent = @intEntityProjectIdent,
										@intAddASUserIdent = @intASUserIdent

GO

