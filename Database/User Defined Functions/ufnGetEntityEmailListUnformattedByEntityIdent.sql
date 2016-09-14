IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetEntityEmailListUnformattedByEntityIdent') and xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION ufnGetEntityEmailListUnformattedByEntityIdent
GO

/* ufnGetEntityEmailListUnformattedByEntityIdent
 *
 *	Returns a string of the active email addresses concatinated together separated by commas w/o HTML
 *
 */
CREATE FUNCTION ufnGetEntityEmailListUnformattedByEntityIdent(@bntEntityIdent BIGINT)

	RETURNS NVARCHAR(MAX)

AS

	BEGIN
		
		DECLARE @nvrEmailList NVARCHAR(MAX)
		SELECT 
			@nvrEmailList = COALESCE(@nvrEmailList + ', ','') + Email
		FROM 
			EntityEmail WITH (NOLOCK)
		WHERE 
			EntityIdent = @bntEntityIdent
			AND Active = 1

		SELECT 
			@nvrEmailList = COALESCE(@nvrEmailList,  '')

		RETURN RTRIM(LTRIM(@nvrEmailList))

	END
	
GO

-- SELECT dbo.ufnGetEntityEmailListUnformattedByEntityIdent(306512)