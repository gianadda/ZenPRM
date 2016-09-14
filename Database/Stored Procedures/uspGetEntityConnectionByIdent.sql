IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityConnectionByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetEntityConnectionByIdent
 GO
/* uspGetEntityConnectionByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetEntityConnectionByIdent]

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
		Ident = @intIdent
GO