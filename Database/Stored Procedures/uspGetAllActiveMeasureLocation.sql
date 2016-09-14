IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveMeasureLocation') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetAllActiveMeasureLocation
 GO
/* uspGetAllActiveMeasureLocation
 *
 *
 *
 *
*/
CREATE PROCEDURE uspGetAllActiveMeasureLocation

AS

	SET NOCOUNT ON

	SELECT 
		Ident, 
		Name1
	FROM
		MeasureLocation WITH (NOLOCK)
	WHERE
		Active = 1
	ORDER BY
		Name1 ASC
GO