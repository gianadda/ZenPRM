IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspDeleteEntityServices1XRefByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspDeleteEntityServices1XRefByIdent
 GO
/* uspDeleteEntityServices1XRefByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspDeleteEntityServices1XRefByIdent]

	@intEntityIdent BIGINT,
	@intServices1Ident BIGINT,
	@intEditASUserIdent BIGINT = 0, 
	@sdtEditDateTime SMALLDATETIME = '1/1/1900'

AS

	SET NOCOUNT ON

	UPDATE EntityServices1XRef
	SET 
		EditASUserIdent = @intEditASUserIdent,
		EditDateTime = @sdtEditDateTime,
		Active = 0
	WHERE
		EntityIdent = @intEntityIdent
		AND Services1Ident = @intServices1Ident
		AND Active = 1	 

	SELECT 
		Ident,
		EntityIdent,
		Services1Ident,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	FROM
		EntityServices1XRef WITH (NOLOCK)
	WHERE 
		EntityIdent = @intEntityIdent
		AND Active = 1

GO