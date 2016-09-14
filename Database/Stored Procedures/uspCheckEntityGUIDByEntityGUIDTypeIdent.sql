IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspCheckEntityGUIDByEntityGUIDTypeIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspCheckEntityGUIDByEntityGUIDTypeIdent
GO
/********************************************************
 * This procedure will check an incoming GUID to whether
 *  the entity has access/permission to this GUID
 *
 *	uspCheckEntityGUIDByEntityGUIDTypeIdent 
 *
 ********************************************************/
 
CREATE PROCEDURE uspCheckEntityGUIDByEntityGUIDTypeIdent

	@vcrGuid VARCHAR(MAX),
	@intEntityGUIDTypeIdent BIGINT

AS
	
	SELECT
		EntityIdent
	FROM
		EntityGUID WITH (NOLOCK)
	WHERE
		Active = 1
		AND EntityGUID = @vcrGuid
		AND EntityGUIDTypeIdent = @intEntityGUIDTypeIdent

GO