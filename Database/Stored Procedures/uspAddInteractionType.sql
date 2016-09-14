IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddInteractionType') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddInteractionType
 GO
/* uspAddInteractionType
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspAddInteractionType]

	@nvrName1 NVARCHAR(MAX) = '', 
	@intAddASUserIdent BIGINT = 0, 
	@sdtAddDateTime SMALLDATETIME = '1/1/1900', 
	@intEditASUserIdent BIGINT = 0, 
	@sdtEditDateTime SMALLDATETIME = '1/1/1900', 
	@bitActive BIT = False

AS

	SET NOCOUNT ON

	INSERT INTO InteractionType (
		Name1, 
		AddASUserIdent, 
		AddDateTime, 
		EditASUserIdent, 
		EditDateTime, 
		Active
	) 
	SELECT 
		Name1 = @nvrName1, 
		AddASUserIdent = @intAddASUserIdent, 
		AddDateTime = @sdtAddDateTime, 
		EditASUserIdent = @intEditASUserIdent, 
		EditDateTime = @sdtEditDateTime, 
		Active = @bitActive

	SELECT SCOPE_IDENTITY() as [Ident]

GO