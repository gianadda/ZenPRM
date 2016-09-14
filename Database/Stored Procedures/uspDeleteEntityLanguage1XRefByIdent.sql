IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspDeleteEntityLanguage1XRefByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspDeleteEntityLanguage1XRefByIdent
 GO
/* uspDeleteEntityLanguage1XRefByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspDeleteEntityLanguage1XRefByIdent]

	@intEntityIdent BIGINT,
	@intLanguage1Ident BIGINT,
	@intEditASUserIdent BIGINT = 0, 
	@sdtEditDateTime SMALLDATETIME = '1/1/1900'

AS

	SET NOCOUNT ON

	UPDATE EntityLanguage1XRef
	SET 
		EditASUserIdent = @intEditASUserIdent,
		EditDateTime = @sdtEditDateTime,
		Active = 0
	WHERE
		EntityIdent = @intEntityIdent
		AND Language1Ident = @intLanguage1Ident 
		AND Active = 1	 

	SELECT 
		Ident,
		EntityIdent,
		Language1Ident,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	FROM
		EntityLanguage1XRef WITH (NOLOCK)
	WHERE 
		EntityIdent = @intEntityIdent
		AND Active = 1

GO