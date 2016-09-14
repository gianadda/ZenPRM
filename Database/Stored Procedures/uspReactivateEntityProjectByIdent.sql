IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspReactivateEntityProjectByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspReactivateEntityProjectByIdent
 GO
/* uspReactivateEntityProjectByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspReactivateEntityProjectByIdent]

	@intIdent BIGINT,
	@intEditASUserIdent BIGINT = 0

AS

	SET NOCOUNT ON
	
	UPDATE EntityProject
	SET 
		EditASUserIdent = @intEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate(),
		Archived = 0
	WHERE
		Ident = @intIdent
		
	SELECT @intIdent as [Ident]
GO