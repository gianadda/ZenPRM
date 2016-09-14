IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveDegree') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetAllActiveDegree
GO

/* uspGetAllActiveDegree
 *
 *	NG - Get all Degree Records
 *
 */

CREATE PROCEDURE uspGetAllActiveDegree

AS
	
	SET NOCOUNT ON

	SELECT
		Ident,
		Name1
	FROM
		Degree WITH (NOLOCK)
	WHERE
		Active = 1
	ORDER BY
		Name1

GO

uspGetAllActiveDegree