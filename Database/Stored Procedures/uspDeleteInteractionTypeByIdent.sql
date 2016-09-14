IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspDeleteInteractionTypeByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspDeleteInteractionTypeByIdent
 GO
/* uspDeleteInteractionTypeByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspDeleteInteractionTypeByIdent]

	@intIdent BIGINT

AS

	SET NOCOUNT ON

	UPDATE InteractionType
	SET 
		Active = 0
	WHERE
		Ident = @intIdent
GO