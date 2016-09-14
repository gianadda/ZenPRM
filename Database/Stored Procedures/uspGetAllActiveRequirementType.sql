IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveRequirementType') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetAllActiveRequirementType
GO

/* uspGetAllActiveRequirementType
 *
 *	CM - Get all Requirement Type Records
 *
 */

CREATE PROCEDURE uspGetAllActiveRequirementType

AS
	
	SET NOCOUNT ON

	SELECT
		Ident,
		Name1,
		TemplateName,
		DefaultData,
		HasOptions,
		AllowMultipleOptions,
		RequiresAnswer,
		IsFileUpload,
		EntitySearchDataTypeIdent,
		AllowEntityProjectMeasure
	FROM
		RequirementType WITH (NOLOCK)
	WHERE
		Active = 1
	ORDER BY
		Name1

GO