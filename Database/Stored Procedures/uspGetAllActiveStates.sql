IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveStates') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetAllActiveStates
GO

/* uspGetAllActiveStates
 *
 *	NG - Get all States Records
 *
 */

CREATE PROCEDURE uspGetAllActiveStates

AS
	
	SET NOCOUNT ON

	SELECT
		Ident,
		Name1
	FROM
		States WITH (NOLOCK)
	WHERE
		Active = 1
	ORDER BY
		Name1

GO

uspGetAllActiveStates