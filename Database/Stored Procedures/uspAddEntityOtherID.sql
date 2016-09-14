IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityOtherID') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntityOtherID
 GO
/* uspAddEntityOtherID
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspAddEntityOtherID]

	@intEntityIdent BIGINT = 0, 
	@nvrIDType NVARCHAR(MAX) = '', 
	@nvrIDNumber NVARCHAR(MAX) = '', 
	@intAddASUserIdent BIGINT = 0, 
	@bitActive BIT = False

AS

	SET NOCOUNT ON

	INSERT INTO EntityOtherID (
		EntityIdent, 
		IDType, 
		IDNumber, 
		AddASUserIdent, 
		AddDateTime, 
		EditASUserIdent, 
		EditDateTime, 
		Active
	) 
	SELECT 
		EntityIdent = @intEntityIdent, 
		IDType = @nvrIDType, 
		IDNumber = @nvrIDNumber, 
		AddASUserIdent = @intAddASUserIdent, 
		AddDateTime = dbo.ufnGetMyDate(), 
		EditASUserIdent = 0, 
		EditDateTime = '1/1/1900', 
		Active = @bitActive

	SELECT SCOPE_IDENTITY() AS [Ident]

GO