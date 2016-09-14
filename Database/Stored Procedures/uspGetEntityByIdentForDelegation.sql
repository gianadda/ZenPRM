IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityByIdentForDelegation') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityByIdentForDelegation
GO

/* uspGetEntityByIdentForDelegation
 *
 *	AA - Gets a subset of the Entity Profile used for the delegation process
 *
 */

CREATE PROCEDURE uspGetEntityByIdentForDelegation

	@bntIdent BIGINT

AS
	
	SET NOCOUNT ON

	SELECT
		E.Ident,
		E.FullName,
		E.FirstName,
		E.LastName,
		E.Username,
		E.SystemRoleIdent,
		SR.Name1 As 'SystemRole',
		E.IsLocked,
		E.MustChangePassword,
		E.LastSuccessfulLogin,
		E.Customer
	FROM
		Entity E WITH (NOLOCK)
		INNER JOIN 
		SystemRole SR WITH (NOLOCK)
			ON SR.Ident = E.SystemRoleIdent
	WHERE 
		E.Active = 1
		and E.Ident = @bntIdent 
	ORDER BY 
		LastName, FirstName

GO