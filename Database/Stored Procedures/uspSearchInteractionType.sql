IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspSearchInteractionType') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspSearchInteractionType
 GO
/* uspSearchInteractionType
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspSearchInteractionType]

--Add any params here!

AS

	SET NOCOUNT ON

	SELECT 
		Ident, 
		Name1, 
		AddASUserIdent, 
		AddDateTime, 
		EditASUserIdent, 
		EditDateTime, 
		Active
	FROM
		InteractionType WITH (NOLOCK)
	--WHERE
		--Active = 1
		--Add your where clause here!
GO