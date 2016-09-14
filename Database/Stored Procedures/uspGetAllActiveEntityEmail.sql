IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveEntityEmail') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetAllActiveEntityEmail
 GO
/* uspGetAllActiveEntityEmail
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetAllActiveEntityEmail]

	@intIdent BIGINT

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
		Active = 1
	ORDER BY 
		Email
GO