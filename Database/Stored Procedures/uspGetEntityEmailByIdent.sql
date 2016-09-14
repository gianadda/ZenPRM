IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityEmailByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetEntityEmailByIdent
 GO
/* uspGetEntityEmailByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetEntityEmailByIdent]

	@intIdent BIGINT,
	@intEntityIdent BIGINT

AS

	SET NOCOUNT ON

	SELECT 
		Ident, 
		EntityIdent, 
		Email, 
		Notify, 
		Verified, 
		VerifiedASUserIdent, 
		VerifiedDateTime, 
		AddASUserIdent, 
		AddDateTime, 
		EditASUserIdent, 
		EditDateTime, 
		Active
	FROM
		EntityEmail WITH (NOLOCK)
	WHERE
		Ident = @intIdent
		AND EntityIdent = @intEntityIdent
GO