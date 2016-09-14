IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspMergeResources') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspMergeResources
GO
/********************************************************													
 *
 *	uspMergeResources 
 *
 ********************************************************/
 
CREATE PROCEDURE uspMergeResources

	@bntFromEntityIdent BIGINT,
	@bntToEntityIdent BIGINT,
	@bntASUserIdent BIGINT,
	@bntEditASUserIdent BIGINT

AS

	-- 1. Move data from the private profile to the public profile
	EXEC uspMergeResourcesProfileData @bntFromEntityIdent = @bntFromEntityIdent,
										@bntToEntityIdent = @bntToEntityIdent,
										@bntASUserIdent = @bntASUserIdent,
										@bntEditASUserIdent = @bntEditASUserIdent

	-- 2. Move any child data elements for this resource to the new profile
	EXEC uspMergeResourcesChildData @bntFromEntityIdent = @bntFromEntityIdent,
										@bntToEntityIdent = @bntToEntityIdent,
										@bntASUserIdent = @bntASUserIdent,
										@bntEditASUserIdent = @bntEditASUserIdent

	-- 3. Move the audit history to the new resource
	EXEC uspMergeResourcesAuditHistory @bntFromEntityIdent = @bntFromEntityIdent,
										@bntToEntityIdent = @bntToEntityIdent,
										@bntASUserIdent = @bntASUserIdent,
										@bntEditASUserIdent = @bntEditASUserIdent
	
	-- 4. Merge the project data
	EXEC uspMergeResourcesProjectData @bntFromEntityIdent = @bntFromEntityIdent,
										@bntToEntityIdent = @bntToEntityIdent,
										@bntASUserIdent = @bntASUserIdent,
										@bntEditASUserIdent = @bntEditASUserIdent

	-- 5. Make sure the network is setup appropriate after the entityType change			
	EXEC uspAddEntityToNetwork @intFromEntityIdent = @bntASUserIdent,
							@intToEntityIdent = @bntToEntityIdent,
							@intAddASUserIdent = @bntEditASUserIdent,
							@bitActive = 1,
							@bitSuppressOutput = 1

GO