IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityGUID') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntityGUID
 GO
/* uspAddEntityGUID
 *
 *
 *
 *
*/
CREATE PROCEDURE uspAddEntityGUID

	@intEntityIdent BIGINT,
	@intEntityGUIDTypeIdent BIGINT

AS

	SET NOCOUNT ON

	INSERT INTO EntityGUID(
		EntityIdent,
		EntityGUIDTypeIdent,
		EntityGUID,
		AddDateTime,
		EditDateTime,
		Active
	)
	SELECT
		EntityIdent = @intEntityIdent,
		EntityGUIDTypeIdent = @intEntityGUIDTypeIdent,
		EntityGUID = NEWID(),
		AddDateTime = dbo.ufnGetMyDate(),
		EditDateTime = '1/1/1900',
		Active = 1

	SELECT SCOPE_IDENTITY() AS [Ident]

GO