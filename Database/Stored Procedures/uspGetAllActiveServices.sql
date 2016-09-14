IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveServices') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetAllActiveServices
 GO
/* uspGetAllActiveServices
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetAllActiveServices]

AS

	SET NOCOUNT ON

	SELECT 
		Ident, 
		Name1
	FROM
		Services1 WITH (NOLOCK)
	WHERE
		Active = 1
	ORDER BY 
		Name1
GO