IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspDeleteEntitySpecialityXRefByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspDeleteEntitySpecialityXRefByIdent
 GO
/* uspDeleteEntitySpecialityXRefByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspDeleteEntitySpecialityXRefByIdent]

	@intEntityIdent BIGINT,
	@intSpecialityIdent BIGINT,
	@intEditASUserIdent BIGINT = 0, 
	@sdtEditDateTime SMALLDATETIME = '1/1/1900'

AS

	SET NOCOUNT ON

	UPDATE EntitySpecialityXRef
	SET 
		EditASUserIdent = @intEditASUserIdent,
		EditDateTime = @sdtEditDateTime,
		Active = 0
	WHERE
		EntityIdent = @intEntityIdent
		AND SpecialityIdent = @intSpecialityIdent 
		AND Active = 1	 


	SELECT 
		Ident,
		EntityIdent,
		SpecialityIdent,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	FROM
		EntitySpecialityXRef WITH (NOLOCK)
	WHERE 
		EntityIdent = @intEntityIdent
		AND Active = 1

GO
