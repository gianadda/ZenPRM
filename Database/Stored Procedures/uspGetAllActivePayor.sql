IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActivePayor') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetAllActivePayor
 GO
/* uspGetAllActivePayor
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetAllActivePayor]

AS

	SET NOCOUNT ON

	SELECT 
		Ident, 
		Name1
	FROM
		Payor WITH (NOLOCK)
	WHERE
		Active = 1
	ORDER BY 
		Name1
GO