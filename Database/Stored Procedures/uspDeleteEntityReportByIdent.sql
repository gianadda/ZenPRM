IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspDeleteEntityReportByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspDeleteEntityReportByIdent
 GO
/* uspDeleteEntityReportByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspDeleteEntityReportByIdent]

	@intEntityIdent BIGINT,
	@intEntityReportIdent BIGINT,
	@intEditASUserIdent BIGINT = 0, 
	@sdtEditDateTime SMALLDATETIME = '1/1/1900'

AS

	SET NOCOUNT ON

	UPDATE EntityReport
	SET 
		EditASUserIdent = @intEditASUserIdent,
		EditDateTime = @sdtEditDateTime,
		Active = 0
	WHERE
		EntityIdent = @intEntityIdent
		AND Ident = @intEntityReportIdent
		AND Active = 1	 
		
	SELECT @intEntityReportIdent as [Ident]

GO
