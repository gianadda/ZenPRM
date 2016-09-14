IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspDeleteEntityToDoCategoryByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspDeleteEntityToDoCategoryByIdent
 GO
/* uspDeleteEntityToDoCategoryByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspDeleteEntityToDoCategoryByIdent]

	@intIdent BIGINT,
	@intEditASUserIdent BIGINT = 0, 
	@sdtEditDateTime SMALLDATETIME = '1/1/1900'

AS

	SET NOCOUNT ON

	UPDATE EntityToDoCategory
	SET 
		EditASUserIdent = @intEditASUserIdent,
		EditDateTime = @sdtEditDateTime,
		Active = 0
	WHERE
		Ident = @intIdent

	SELECT @intIdent as [Ident]


GO