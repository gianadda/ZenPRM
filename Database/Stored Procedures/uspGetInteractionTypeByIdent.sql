IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetInteractionTypeByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetInteractionTypeByIdent
 GO
/* uspGetInteractionTypeByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetInteractionTypeByIdent]

	@intIdent BIGINT

AS

	SET NOCOUNT ON

	SELECT 
		Ident, 
		Name1, 
		AddASUserIdent, 
		AddDateTime, 
		EditASUserIdent, 
		EditDateTime, 
		Active
	FROM
		InteractionType WITH (NOLOCK)
	WHERE
		Ident = @intIdent
GO