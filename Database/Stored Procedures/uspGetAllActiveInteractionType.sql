IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveInteractionType') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetAllActiveInteractionType
 GO
/* uspGetAllActiveInteractionType
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetAllActiveInteractionType]

AS

	SET NOCOUNT ON

	SELECT 
		Ident, 
		Name1, 
		Icon,
		Class
	FROM
		InteractionType WITH (NOLOCK)
	WHERE
		Active = 1
	ORDER BY 
		Name1
		
GO