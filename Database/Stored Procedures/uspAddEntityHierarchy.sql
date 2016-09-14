IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityHierarchy') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspAddEntityHierarchy
GO
/* uspAddEntityHierarchy
 *
 *	Adds an Entity Hierarchy
 *
 */
CREATE PROCEDURE uspAddEntityHierarchy

	@bntASUserIdent BIGINT,
	@bntEntityIdent BIGINT,
	@bntHierarchyTypeIdent BIGINT,
	@bntFromEntityIdent BIGINT,
	@bntToEntityIdent BIGINT

AS

	SET NOCOUNT ON

	INSERT INTO EntityHierarchy(
		EntityIdent,
		HierarchyTypeIdent,
		FromEntityIdent,
		ToEntityIdent,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT
		EntityIdent = @bntEntityIdent,
		HierarchyTypeIdent = @bntHierarchyTypeIdent,
		FromEntityIdent = @bntFromEntityIdent,
		ToEntityIdent = @bntToEntityIdent,
		AddASUserIdent = @bntASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1

	SELECT SCOPE_IDENTITY() as [Ident]

GO