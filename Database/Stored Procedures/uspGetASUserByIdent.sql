IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetASUserByIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetASUserByIdent
GO

/* uspGetASUserByIdent
 *
 *	AA - This will retrieve an ASUser by ident
 *
 */

CREATE PROCEDURE uspGetASUserByIdent

	@bntIdent BIGINT

AS
	
	SET NOCOUNT ON

	SELECT
		U.Ident,
		U.FullName,
		U.FirstName,
		U.LastName,
		U.Username,
		U.Password1,
		U.PasswordSalt,
		U.Email,
		U.SystemRoleIdent,
		SR.Name1 As 'SystemRole',
		U.IsLocked,
		U.MustChangePassword,
		U.LastSuccessfulLogin
	FROM
		ASUser U WITH (NOLOCK)
		INNER JOIN 
		SystemRole SR WITH (NOLOCK)
			ON SR.Ident = U.SystemRoleIdent
	WHERE 
		U.Active = 1
		and U.Ident = @bntIdent 
	ORDER BY 
		LastName, FirstName

GO