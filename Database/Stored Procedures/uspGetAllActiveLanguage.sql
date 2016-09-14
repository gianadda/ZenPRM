IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveLanguage') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetAllActiveLanguage
 GO
/* uspGetAllActiveLanguage
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetAllActiveLanguage]

AS

	SET NOCOUNT ON

	SELECT 
		Ident, 
		Name1
	FROM
		Language1 WITH (NOLOCK)
	WHERE
		Active = 1
	ORDER BY 
		Name1
GO