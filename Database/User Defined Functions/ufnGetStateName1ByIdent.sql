IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetStateName1ByIdent') and xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION ufnGetStateName1ByIdent
GO

/* ufnGetStateName1ByIdent
 *
 *	Returns a string of the name of the state
 *
 */
CREATE FUNCTION ufnGetStateName1ByIdent(@bntIdent BIGINT)

	RETURNS NVARCHAR(MAX)

AS

	BEGIN
		
		DECLARE @nvrState NVARCHAR(MAX) = ''
		SELECT 
			@nvrState = S.Name1
		FROM 
			States S WITH (NOLOCK)
		WHERE 
			S.Ident = @bntIdent
			AND S.Active = 1
		

		RETURN @nvrState

	END
	
GO