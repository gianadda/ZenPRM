IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityReport') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntityReport
 GO
/* uspAddEntityReport
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspAddEntityReport]

	@intEntityIdent BIGINT,
	@intReportTypeIdent BIGINT,
	@nvrName1 NVARCHAR(MAX), 
	@nvrDesc1 NVARCHAR(MAX), 
	@nvrTemplateHTML NVARCHAR(MAX),
	@bitPrivateReport BIT,
	@intAddASUserIdent BIGINT = 0, 
	@bitActive BIT = False

AS

	SET NOCOUNT ON

	DECLARE @intIdent BIGINT
	SET @intIdent = 0

	INSERT INTO EntityReport (
		EntityIdent,
		ReportTypeIdent,
		Name1,
		Desc1,
		TemplateHTML,
		PrivateReport,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	) 
	SELECT 
		EntityIdent = @intEntityIdent,
		ReportTypeIdent = @intReportTypeIdent,
		Name1 = @nvrName1,
		Desc1 = @nvrDesc1,
		TemplateHTML = @nvrTemplateHTML,
		PrivateReport = @bitPrivateReport,
		AddASUserIdent = @intAddASUserIdent, 
		AddDateTime = dbo.ufnGetMyDate(), 
		EditASUserIdent = 0, 
		EditDateTime = '1/1/1900', 
		Active = @bitActive

	SET @intIdent = SCOPE_IDENTITY()

	SELECT @intIdent as [Ident]

GO


uspAddEntityReport

	@intEntityIdent = 306485,
	@intReportTypeIdent = 1,
	@nvrName1 = 'nick', 
	@nvrDesc1 = 'Nick', 
	@nvrTemplateHTML = '<h1>NICKY</h1>',
	@bitPrivateReport = 1,
	@intAddASUserIdent = 0, 
	@bitActive = False