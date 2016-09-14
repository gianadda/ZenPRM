IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspArchiveEntityProjectByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspArchiveEntityProjectByIdent
 GO
/* uspArchiveEntityProjectByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspArchiveEntityProjectByIdent]

	@intIdent BIGINT,
	@intEditASUserIdent BIGINT = 0

AS

	SET NOCOUNT ON
	
	UPDATE EntityProject
	SET 
		EditASUserIdent = @intEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate(),
		Archived = 1
	WHERE
		Ident = @intIdent
		
	SELECT @intIdent as [Ident]

GO