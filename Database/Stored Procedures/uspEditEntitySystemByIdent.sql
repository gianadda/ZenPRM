IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspEditEntitySystemByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspEditEntitySystemByIdent
 GO
/* uspEditEntitySystemByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspEditEntitySystemByIdent]

	@intIdent BIGINT, 
	@intEntityIdent BIGINT, 
	@intSystemTypeIdent BIGINT, 
	@nvrName1 NVARCHAR(MAX), 
	@sdtInstalationDate SMALLDATETIME = NULL, 
	@sdtGoLiveDate SMALLDATETIME = NULL, 
	@sdtDecomissionDate SMALLDATETIME = NULL, 
	@intEditASUserIdent BIGINT, 
	@bitActive BIT

AS

	SET NOCOUNT ON

	UPDATE EntitySystem
	SET 
		EntityIdent = @intEntityIdent, 
		SystemTypeIdent = @intSystemTypeIdent,
		Name1 = @nvrName1, 
		InstalationDate = @sdtInstalationDate, 
		GoLiveDate = @sdtGoLiveDate, 
		DecomissionDate = @sdtDecomissionDate, 
		EditASUserIdent = @intEditASUserIdent, 
		EditDateTime = dbo.ufnGetMyDate(), 
		Active = @bitActive
	WHERE
		Ident = @intIdent

	SELECT @intIdent as [Ident]

GO