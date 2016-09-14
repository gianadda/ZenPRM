IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveHierarchyType') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetAllActiveHierarchyType
GO

/* uspGetAllActiveHierarchyType
 *
 *	
 *
 */

CREATE PROCEDURE uspGetAllActiveHierarchyType

AS
	
	SET NOCOUNT ON

	SELECT
		Ident,
		Name1,
		ReverseName1,
		FromEntityIsPerson,
		ToEntityIsPerson
	FROM
		HierarchyType WITH (NOLOCK)
	WHERE
		Active = 1
	ORDER BY
		Name1

GO
