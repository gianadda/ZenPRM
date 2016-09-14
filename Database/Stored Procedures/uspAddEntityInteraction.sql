IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityInteraction') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntityInteraction
 GO
/* uspAddEntityInteraction
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspAddEntityInteraction]

	@intFromEntityIdent BIGINT = 0, 
	@intToEntityIdent BIGINT = 0, 
	@nvrInteractionText NVARCHAR(MAX) , 
	@nvrInteractionTypeIdents NVARCHAR(MAX) , 
	@bitImportant BIT,
	@intAddASUserIdent BIGINT = 0, 
	@bitActive BIT = False

AS

	SET NOCOUNT ON

	DECLARE @intIdent BIGINT
	SET @intIdent = 0

	INSERT INTO EntityInteraction (
		FromEntityIdent,
		ToEntityIdent,
		InteractionText,
		Important,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	) 
	SELECT 
		FromEntityIdent = @intFromEntityIdent, 
		ToEntityIdent = @intToEntityIdent, 
		InteractionText = @nvrInteractionText, 
		Important = @bitImportant, 
		AddASUserIdent = @intAddASUserIdent, 
		AddDateTime = dbo.ufnGetMyDate(), 
		EditASUserIdent = 0, 
		EditDateTime = '1/1/1900', 
		Active = @bitActive

	SET @intIdent = SCOPE_IDENTITY()

	SELECT @intIdent as [Ident]

GO