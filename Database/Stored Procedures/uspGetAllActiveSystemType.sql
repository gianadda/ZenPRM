IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveSystemType') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetAllActiveSystemType
GO

/* uspGetAllActiveSystemType
 *
 *	NG - Get all System Type Records
 *
 */

CREATE PROCEDURE uspGetAllActiveSystemType

AS
	
	SET NOCOUNT ON

	SELECT
		Ident,
		Name1
	FROM
		SystemType WITH (NOLOCK)
	WHERE
		Active = 1
	ORDER BY
		Name1

GO

uspGetAllActiveSystemType