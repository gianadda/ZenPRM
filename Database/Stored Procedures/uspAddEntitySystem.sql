IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntitySystem') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntitySystem
 GO
/* uspAddEntitySystem
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspAddEntitySystem]

	@intEntityIdent BIGINT = 0, 
	@intSystemTypeIdent BIGINT, 
	@nvrName1 NVARCHAR(MAX) = '', 
	@sdtInstalationDate SMALLDATETIME = NULL, 
	@sdtGoLiveDate SMALLDATETIME = NULL, 
	@sdtDecomissionDate SMALLDATETIME = NULL, 
	@intAddASUserIdent BIGINT = 0, 
	@bitActive BIT = False

AS

	SET NOCOUNT ON

	INSERT INTO EntitySystem (
		EntityIdent, 
		SystemTypeIdent,
		Name1, 
		InstalationDate, 
		GoLiveDate, 
		DecomissionDate, 
		AddASUserIdent, 
		AddDateTime, 
		EditASUserIdent, 
		EditDateTime, 
		Active
	) 
	SELECT 
		EntityIdent = @intEntityIdent, 
		SystemTypeIdent = @intSystemTypeIdent,
		Name1 = @nvrName1, 
		InstalationDate = @sdtInstalationDate, 
		GoLiveDate = @sdtGoLiveDate, 
		DecomissionDate = @sdtDecomissionDate, 
		AddASUserIdent = @intAddASUserIdent, 
		AddDateTime = dbo.ufnGetMyDate(), 
		EditASUserIdent = 0, 
		EditDateTime = '1/1/1900', 
		Active = @bitActive

	SELECT SCOPE_IDENTITY() AS [Ident]


GO