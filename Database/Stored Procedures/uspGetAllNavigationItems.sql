DROP PROCEDURE uspGetAllNavigationItems
GO 
/* uspGetAllNavigationItems
 *
 *	AA - Get all navigation items by the users role
 *
 */

CREATE PROCEDURE [dbo].[uspGetAllNavigationItems]
	
	@bntSystemRoleIdent	BIGINT

AS
	
	SET NOCOUNT ON

	--Nodes that are the top level node
	SELECT
		N.Ident, 
		ParentIdent, 
		DisplayName, 
		Sref,
		IconClasses,
		ClassName, 
		Sequence
	FROM 
		Navigation N WITH (NOLOCK)
		INNER JOIN 
		NavigationPermission NP WITH (NOLOCK)
			ON NP.NavigationIdent = N.Ident
	WHERE N.Active = 1
		AND NP.Active = 1
		AND NP.SystemRoleIdent = @bntSystemRoleIdent
		AND ParentIdent = 0 
	ORDER BY	
		Sequence 

	--Nodes that have have childeren and are not the top level node
	SELECT
		 N.Ident, 
		 ParentIdent, 
		 DisplayName, 
		 Sref,
		 IconClasses,
		 ClassName, 
		 Sequence
	FROM 
		Navigation N WITH (NOLOCK)
		INNER JOIN 
		NavigationPermission NP WITH (NOLOCK)
			ON NP.NavigationIdent = N.Ident
	WHERE N.Active = 1
		AND NP.Active = 1
		AND NP.SystemRoleIdent = @bntSystemRoleIdent
		AND ParentIdent <> 0
	ORDER BY 
		Sequence, 
		ParentIdent, 
		DisplayName
		

GO


uspGetAllNavigationItems 2