IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspEditEntityReportByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspEditEntityReportByIdent
 GO
/* uspEditEntityReportByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE uspEditEntityReportByIdent

	@bntIdent BIGINT,
	@intEntityIdent BIGINT,
	@nvrName1 NVARCHAR(MAX), 
	@nvrDesc1 NVARCHAR(MAX), 
	@nvrTemplateHTML NVARCHAR(MAX), 
	@bitPrivateReport BIT,
	@intEditASUserIdent BIGINT = 0

AS

	SET NOCOUNT ON

	UPDATE EntityReport
	SET
		Name1 = @nvrName1, 
		Desc1 = @nvrDesc1, 
		TemplateHTML = @nvrTemplateHTML, 
		PrivateReport = @bitPrivateReport, 
		EditASUserIdent = @intEditASUserIdent, 
		EditDateTime = dbo.ufnGetMyDate()
	WHERE
		Ident = @bntIdent
		AND EntityIdent = @intEntityIdent -- make sure this customer has access to this record		

	SELECT
		Ident
	FROM
		EntityReport WITH (NOLOCK)
	WHERE
		Ident = @bntIdent
		AND EntityIdent = @intEntityIdent -- make sure this customer has access to this record		

GO