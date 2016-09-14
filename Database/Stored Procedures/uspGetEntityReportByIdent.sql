IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityReportByIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityReportByIdent
GO

/* uspGetEntityReportByIdent 1,306485, 1
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetEntityReportByIdent]

	@bntIdent BIGINT,
	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT

AS

	SET NOCOUNT ON

	SELECT
		Ident,
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
	FROM
		EntityReport ER (NOLOCK)
	WHERE 
		ER.Ident = @bntIdent
		AND ER.EntityIdent = @bntEntityIdent
		AND ER.Active = 1
	ORDER BY 
		ER.Name1  DESC 

GO

--EXEC uspGetEntityInteractionByIdent 306485, 306495, 1
