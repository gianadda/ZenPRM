IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspDeleteEntityProjectRequirementByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspDeleteEntityProjectRequirementByIdent
 GO
/* uspDeleteEntityProjectRequirementByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE uspDeleteEntityProjectRequirementByIdent

	@bntIdent BIGINT,
	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT

AS

	SET NOCOUNT ON

	UPDATE EPR
	SET
		EditASUserIdent = @bntASUserIdent,
		EditDateTime = dbo.ufnGetMyDate(),
		Active = 0
	FROM
		EntityProjectRequirement EPR WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = EPR.EntityProjectIdent
	WHERE
		EPR.Ident = @bntIdent
		AND EP.EntityIdent = @bntEntityIdent -- security to ensure that the user has access to this record

	SELECT @bntIdent AS [Ident]

GO