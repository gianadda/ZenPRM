IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllSystemRoles') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetAllSystemRoles
GO

/* uspGetAllSystemRoles
 *
 *	TJF - Get all System Roles for Manage User select element
 *
 */

CREATE PROCEDURE uspGetAllSystemRoles

AS
	
	SET NOCOUNT ON

	SELECT
		Ident,
		Name1,
		IsCustomer
	FROM
		SystemRole WITH (NOLOCK)
	WHERE
		Active = 1

GO