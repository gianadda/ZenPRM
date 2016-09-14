IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspEditEntityOtherIDByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspEditEntityOtherIDByIdent
 GO
/* uspEditEntityOtherIDByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspEditEntityOtherIDByIdent]

	@intIdent BIGINT, 
	@intEntityIdent BIGINT, 
	@nvrIDType NVARCHAR(MAX), 
	@nvrIDNumber NVARCHAR(MAX), 
	@intEditASUserIdent BIGINT, 
	@bitActive BIT

AS

	SET NOCOUNT ON

	UPDATE EntityOtherID
	SET 
		EntityIdent = @intEntityIdent, 
		IDType = @nvrIDType, 
		IDNumber = @nvrIDNumber, 
		EditASUserIdent = @intEditASUserIdent, 
		EditDateTime = dbo.ufnGetMyDate(), 
		Active = @bitActive
	WHERE
		Ident = @intIdent

	SELECT @intIdent as [Ident]

GO