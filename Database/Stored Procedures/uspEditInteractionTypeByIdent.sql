IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspEditInteractionTypeByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspEditInteractionTypeByIdent
 GO
/* uspEditInteractionTypeByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspEditInteractionTypeByIdent]

	@intIdent BIGINT, 
	@nvrName1 NVARCHAR(MAX), 
	@intAddASUserIdent BIGINT, 
	@sdtAddDateTime SMALLDATETIME, 
	@intEditASUserIdent BIGINT, 
	@sdtEditDateTime SMALLDATETIME, 
	@bitActive BIT

AS

	SET NOCOUNT ON

	UPDATE InteractionType
	SET 
		Name1 = @nvrName1, 
		AddASUserIdent = @intAddASUserIdent, 
		AddDateTime = @sdtAddDateTime, 
		EditASUserIdent = @intEditASUserIdent, 
		EditDateTime = @sdtEditDateTime, 
		Active = @bitActive
	WHERE
		Ident = @intIdent
GO