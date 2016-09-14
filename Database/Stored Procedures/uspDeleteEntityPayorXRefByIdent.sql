IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspDeleteEntityPayorXRefByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspDeleteEntityPayorXRefByIdent
 GO
/* uspDeleteEntityPayorXRefByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspDeleteEntityPayorXRefByIdent]

	@intEntityIdent BIGINT,
	@intPayorIdent BIGINT,
	@intEditASUserIdent BIGINT = 0, 
	@sdtEditDateTime SMALLDATETIME = '1/1/1900'

AS

	SET NOCOUNT ON

	UPDATE EntityPayorXRef
	SET 
		EditASUserIdent = @intEditASUserIdent,
		EditDateTime = @sdtEditDateTime,
		Active = 0
	WHERE
		EntityIdent = @intEntityIdent
		AND PayorIdent = @intPayorIdent 
		AND Active = 1	 

	SELECT 
		Ident,
		EntityIdent,
		PayorIdent,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	FROM
		EntityPayorXRef WITH (NOLOCK)
	WHERE 
		EntityIdent = @intEntityIdent
		AND Active = 1

GO