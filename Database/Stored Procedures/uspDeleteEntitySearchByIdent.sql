IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspDeleteEntitySearchByIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspDeleteEntitySearchByIdent
GO
/* uspDeleteEntitySearchByIdent
 *
 *	deletes the saved entity search
 *
 */
CREATE PROCEDURE uspDeleteEntitySearchByIdent

	@bntIdent BIGINT,
	@bntASUserIdent BIGINT,
	@bntEntityIdent BIGINT

AS

	SET NOCOUNT ON

	UPDATE
		EntitySearch
	SET
		Active = 0,
		EditASUserIdent = @bntASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()
	WHERE
		Ident = @bntIdent
		AND EntityIdent = @bntEntityIdent

	SELECT @bntIdent as [Ident] -- returns edited record or new row ident

GO