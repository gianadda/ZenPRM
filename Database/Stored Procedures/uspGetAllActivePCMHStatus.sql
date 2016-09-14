IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActivePCMHStatus') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetAllActivePCMHStatus
 GO
/* uspGetAllActivePCMHStatus
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetAllActivePCMHStatus]

AS

	SET NOCOUNT ON

	SELECT 
		Ident, 
		Name1
	FROM
		PCMHStatus WITH (NOLOCK)
	WHERE
		Active = 1
	ORDER BY 
		Name1
GO