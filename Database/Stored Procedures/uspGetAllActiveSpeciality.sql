IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveSpeciality') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetAllActiveSpeciality
GO

/* uspGetAllActiveSpeciality
 *
 *	NG - Get all Speciality Records
 *
 */

CREATE PROCEDURE uspGetAllActiveSpeciality

AS
	
	SET NOCOUNT ON

	SELECT
		Ident,
		Name1
	FROM
		Speciality WITH (NOLOCK)
	WHERE
		Active = 1
	ORDER BY
		Name1

GO

uspGetAllActiveSpeciality