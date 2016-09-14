IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspCheckASUserSystemRole') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspCheckASUserSystemRole
GO
/********************************************************												
 *
 *	uspCheckASUserSystemRole 
 *
 *	- Determine if ASUser is in Role
 *
 ********************************************************/
 
CREATE PROCEDURE uspCheckASUserSystemRole

	@bntASUserIdent BIGINT,
	@bntSystemRoleIdent BIGINT

AS
	
	SELECT
		Ident
	FROM
		ASUser WITH (NOLOCK)
	WHERE
		Ident = @bntASUserIdent
		AND Active = 1
		AND SystemRoleIdent = @bntSystemRoleIdent

GO