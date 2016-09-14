IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetRequirementTypeIdentByEntityProjectRequirementIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetRequirementTypeIdentByEntityProjectRequirementIdent
 GO
/* uspGetRequirementTypeIdentByEntityProjectRequirementIdent 1866
 *
 *
 *
 *
*/
CREATE PROCEDURE uspGetRequirementTypeIdentByEntityProjectRequirementIdent

	@bntEntityProjectRequirementIdent BIGINT

AS

	SET NOCOUNT ON
	
	SELECT
		RequirementTypeIdent
	FROM
		EntityProjectRequirement WITH (NOLOCK)
	WHERE
		Ident = @bntEntityProjectRequirementIdent

GO