IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspEditEntityConnectionByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspEditEntityConnectionByIdent
 GO
/* uspEditEntityConnectionByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspEditEntityConnectionByIdent]

	@intIdent BIGINT, 
	@intConnectionTypeIdent BIGINT, 
	@intFromEntityIdent BIGINT, 
	@intToEntityIdent BIGINT, 
	@intAddASUserIdent BIGINT, 
	@sdtAddDateTime SMALLDATETIME, 
	@intEditASUserIdent BIGINT, 
	@sdtEditDateTime SMALLDATETIME, 
	@bitActive BIT

AS

	SET NOCOUNT ON

	UPDATE EntityConnection
	SET 
		ConnectionTypeIdent = @intConnectionTypeIdent, 
		FromEntityIdent = @intFromEntityIdent, 
		ToEntityIdent = @intToEntityIdent, 
		AddASUserIdent = @intAddASUserIdent, 
		AddDateTime = @sdtAddDateTime, 
		EditASUserIdent = @intEditASUserIdent, 
		EditDateTime = @sdtEditDateTime, 
		Active = @bitActive
	WHERE
		Ident = @intIdent
		
	SELECT @intIdent as [Ident]
GO