IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspDeleteEntityProjectHierarchyByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspDeleteEntityProjectHierarchyByIdent
 GO
/* uspDeleteEntityProjectHierarchyByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE uspDeleteEntityProjectHierarchyByIdent

	@bntIdent BIGINT,
	@bntEntityIdent BIGINT,
	@bntEditASUserIdent BIGINT

AS

	SET NOCOUNT ON
	
	UPDATE EntityHierarchy
	SET 
		Active = 0,
		EditASUserIdent = @bntEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()
	WHERE
		Ident = @bntIdent
		AND EntityIdent = @bntEntityIdent -- ensure that the user has access to this record
		
GO