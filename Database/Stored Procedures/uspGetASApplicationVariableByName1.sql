IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetASApplicationVariableByName1') 
	and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetASApplicationVariableByName1
Go
/* uspGetASApplicationVariableByName1
 *
 *	Returns value of app variable by name of variable
 *
 */
CREATE PROCEDURE uspGetASApplicationVariableByName1

	@nvrName1 NVARCHAR(150)

AS

	SET NOCOUNT ON

	SELECT 
		AAV.Value1
	FROM
		ASApplicationVariable AAV WITH (NOLOCK)
	WHERE
		AAV.Name1 = @nvrName1
		AND AAV.Active = 1

GO
