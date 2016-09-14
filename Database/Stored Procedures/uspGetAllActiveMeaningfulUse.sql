IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveMeaningfulUse') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetAllActiveMeaningfulUse
 GO
/* uspGetAllActiveMeaningfulUse
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetAllActiveMeaningfulUse]

AS

	SET NOCOUNT ON

	SELECT 
		Ident, 
		Name1
	FROM
		MeaningfulUse WITH (NOLOCK)
	WHERE
		Active = 1
	ORDER BY 
		Name1
GO