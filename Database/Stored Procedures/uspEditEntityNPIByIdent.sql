IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspEditEntityNPIByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspEditEntityNPIByIdent
 GO
/* 
 *
 * uspEditEntityNPIByIdent
 *
 *
*/
CREATE PROCEDURE uspEditEntityNPIByIdent

	@intIdent BIGINT, 
	@vcrNPI VARCHAR(MAX),
	@bntEditASUserIdent BIGINT

AS

	SET NOCOUNT ON

	UPDATE Entity
	SET 
		NPI = @vcrNPI,
		EditDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = @bntEditASUserIdent
	WHERE
		Ident = @intIdent
		AND NPI = '' -- dont allow a user to edit an NPI if the resource already has one

	SELECT
		[Ident]
	FROM
		Entity WITH (NOLOCK)
	WHERE
		Ident = @intIdent
		AND NPI = @vcrNPI

GO