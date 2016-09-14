IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveGender') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetAllActiveGender
GO

/* uspGetAllActiveGender
 *
 *	NG - Get all Gender Records
 *
 */

CREATE PROCEDURE uspGetAllActiveGender

AS
	
	SET NOCOUNT ON

	SELECT
		Ident,
		Name1
	FROM
		Gender WITH (NOLOCK)
	WHERE
		Active = 1
	ORDER BY 
		Name1

GO

uspGetAllActiveGender