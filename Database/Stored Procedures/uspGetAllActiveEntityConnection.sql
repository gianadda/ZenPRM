IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveEntityConnection') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetAllActiveEntityConnection
 GO
/* uspGetAllActiveEntityConnection
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetAllActiveEntityConnection]

	@intIdent BIGINT

AS

	SET NOCOUNT ON

	SELECT 
		Ident, 
		ConnectionTypeIdent, 
		FromEntityIdent, 
		ToEntityIdent, 
		AddASUserIdent, 
		AddDateTime, 
		EditASUserIdent, 
		EditDateTime, 
		Active
	FROM
		EntityConnection WITH (NOLOCK)
	WHERE
		Active = 1
GO