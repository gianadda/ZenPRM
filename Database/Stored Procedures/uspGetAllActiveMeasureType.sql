IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveMeasureType') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetAllActiveMeasureType
 GO
/* uspGetAllActiveMeasureType
 *
 *
 *
 *
*/
CREATE PROCEDURE uspGetAllActiveMeasureType

AS

	SET NOCOUNT ON

	SELECT 
		Ident,
		Name1,
		Desc1,
		EntitySearchDataTypeIdent,
		HasDenominator,
		HasTargetValue,
		IsAverage,
		IsPercentage
	FROM
		MeasureType WITH (NOLOCK)
	WHERE
		Active = 1
	ORDER BY
		Name1
GO