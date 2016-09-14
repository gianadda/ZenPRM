IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspDeleteEntityDegreeXRefByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspDeleteEntityDegreeXRefByIdent
 GO
/* uspDeleteEntityDegreeXRefByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspDeleteEntityDegreeXRefByIdent]

	@intEntityIdent BIGINT,
	@intDegreeIdent BIGINT,
	@intEditASUserIdent BIGINT = 0, 
	@sdtEditDateTime SMALLDATETIME = '1/1/1900'

AS

	SET NOCOUNT ON

	UPDATE EntityDegreeXRef
	SET 
		EditASUserIdent = @intEditASUserIdent,
		EditDateTime = @sdtEditDateTime,
		Active = 0
	WHERE
		EntityIdent = @intEntityIdent
		AND DegreeIdent = @intDegreeIdent 
		AND Active = 1	 

	SELECT 
		Ident,
		EntityIdent,
		DegreeIdent,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	FROM
		EntityDegreeXRef WITH (NOLOCK)
	WHERE 
		EntityIdent = @intEntityIdent
		AND Active = 1

GO
