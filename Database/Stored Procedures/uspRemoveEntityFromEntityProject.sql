IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspRemoveEntityFromEntityProject') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspRemoveEntityFromEntityProject
 GO
/* uspRemoveEntityFromEntityProject 506, 230745, 4, 506
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspRemoveEntityFromEntityProject]

	@intFromEntityIdent BIGINT = 0, 
	@intToEntityIdent BIGINT = 0, 
	@intEntityProjectIdent BIGINT = 0, 
	@intAddASUserIdent BIGINT = 0

AS

	SET NOCOUNT ON


	UPDATE EPE
	SET 
		Active = 0,
		EditASUserIdent = @intAddASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()
	FROM
		EntityProject EP WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntity EPE
			ON EP.Ident = EPE.EntityProjectIdent
	WHERE
		EP.Ident = @intEntityProjectIdent
		AND EP.EntityIdent = @intFromEntityIdent
		AND EPE.EntityIdent = @intToEntityIdent
		AND EPE.Active = 1
		
	SELECT SCOPE_IDENTITY() as [Ident]

GO