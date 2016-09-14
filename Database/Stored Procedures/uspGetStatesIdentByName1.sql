IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetStatesIdentByName1') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetStatesIdentByName1
GO

/* uspGetStatesIdentByName1
 *
 *	NG - Get all States Records
 *
 */

CREATE PROCEDURE uspGetStatesIdentByName1

	@nvrName1 NVARCHAR(75)

AS
	
	SET NOCOUNT ON

	DECLARE @intIdent BIGINT

	-- first, see if it matches on name
	SELECT
		@intIdent = Ident
	FROM
		States WITH (NOLOCK)
	WHERE
		Name1 = @nvrName1
		AND Active = 1

	-- if it doesnt, try name
	SELECT
		@intIdent = Ident
	FROM
		States WITH (NOLOCK)
	WHERE
		@intIdent IS NULL
		AND Desc1 = @nvrName1
		AND Active = 1

	SELECT COALESCE(@intIdent,0) as [Ident]

GO