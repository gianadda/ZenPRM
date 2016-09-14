IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspDeleteEntityInteractionByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspDeleteEntityInteractionByIdent
 GO
/* uspDeleteEntityInteractionByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspDeleteEntityInteractionByIdent]

	@intEntityIdent BIGINT,
	@intEntityInteractionIdent BIGINT,
	@intEditASUserIdent BIGINT = 0, 
	@sdtEditDateTime SMALLDATETIME = '1/1/1900'

AS

	SET NOCOUNT ON

	UPDATE EntityInteraction
	SET 
		EditASUserIdent = @intEditASUserIdent,
		EditDateTime = @sdtEditDateTime,
		Active = 0
	WHERE
		FromEntityIdent = @intEntityIdent
		AND Ident = @intEntityInteractionIdent
		AND Active = 1	 
		
	SELECT @intEntityInteractionIdent as [Ident]

GO
