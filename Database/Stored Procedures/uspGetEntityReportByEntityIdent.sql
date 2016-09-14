IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityReportByEntityIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityReportByEntityIdent
GO

/* uspGetEntityReportByEntityIdent 306485, 306487
 *
 *
 *
 *
*/
CREATE PROCEDURE uspGetEntityReportByEntityIdent

	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT

AS

	SET NOCOUNT ON

	SELECT 
		ER.Ident,
		ER.EntityIdent,
		ER.ReportTypeIdent,
		'ReportType' = RT.Name1,
		ER.Name1,
		ER.Desc1,
		ER.TemplateHTML,
		ER.PrivateReport,
		ER.Active
	FROM 
		EntityReport ER (NOLOCK)
		INNER JOIN
		ReportType RT (NOLOCK)
			ON ER.ReportTypeIdent = RT.Ident
	WHERE 
		ER.EntityIdent = @bntEntityIdent
		AND ER.Active = 1

GO