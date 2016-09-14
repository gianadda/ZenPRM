IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetASApplicationVariableByName1') and xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION ufnGetASApplicationVariableByName1
GO

/* ufnGetASApplicationVariableByName1
 *
 *	Returns value that is in ASASApplicationVariable for Name1 fields
 *
 */
CREATE FUNCTION ufnGetASApplicationVariableByName1(@nvrName1 NVARCHAR(150))

	RETURNS NVARCHAR(MAX)

AS

	BEGIN

		DECLARE @nvrValue1 NVARCHAR(MAX)

		SELECT 
			@nvrValue1 = AAVA.Value1
		FROM
			ASApplicationVariable AAVA WITH (NOLOCK)
		WHERE
			AAVA.Name1 = @nvrName1
			AND AAVA.Active = 1
		
	   	RETURN COALESCE(@nvrValue1,'')

	END
	
GO
