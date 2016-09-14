IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetGenderIdentByName') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetGenderIdentByName
GO

/* uspGetGenderIdentByName
 *
 *	
 *
 */

CREATE PROCEDURE uspGetGenderIdentByName

	@nvrName1 NVARCHAR(75)

AS
	
	SET NOCOUNT ON

	DECLARE @intIdent BIGINT

	-- first, see if it matches on name
	SELECT
		@intIdent = Ident
	FROM
		Gender WITH (NOLOCK)
	WHERE
		Name1 = @nvrName1
		AND Active = 1

	-- if it doesnt, try to see if its a one letter representation
	SELECT
		@intIdent = Ident
	FROM
		Gender WITH (NOLOCK)
	WHERE
		LEFT(Name1,1) = @nvrName1
		AND Active = 1

	SELECT COALESCE(@intIdent,0) as [Ident]

GO