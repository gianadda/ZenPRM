IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspEditEntityInteractionByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspEditEntityInteractionByIdent
 GO
/* uspEditEntityInteractionByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE uspEditEntityInteractionByIdent

	@bntIdent BIGINT,
	@intFromEntityIdent BIGINT, 
	@nvrInteractionText NVARCHAR(MAX), 
	@intEditASUserIdent BIGINT = 0

AS

	SET NOCOUNT ON

	UPDATE EntityInteraction
	SET
		InteractionText = @nvrInteractionText, 
		EditASUserIdent = @intEditASUserIdent, 
		EditDateTime = dbo.ufnGetMyDate()
	WHERE
		Ident = @bntIdent
		AND FromEntityIdent = @intFromEntityIdent -- make sure this customer has access to this record

	SELECT
		Ident
	FROM
		EntityInteraction WITH (NOLOCK)
	WHERE
		Ident = @bntIdent
		AND FromEntityIdent = @intFromEntityIdent -- make sure this customer has access to this record		

GO