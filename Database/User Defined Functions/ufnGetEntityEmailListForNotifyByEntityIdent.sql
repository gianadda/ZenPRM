IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetEntityEmailListForNotifyByEntityIdent') and xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION ufnGetEntityEmailListForNotifyByEntityIdent
GO

/* ufnGetEntityEmailListUnformattedByEntityIdent
 *
 *	Returns a string of the active email addresses that are marked as notify concatinated together separated by commas w/o HTML
 *
 */
CREATE FUNCTION ufnGetEntityEmailListForNotifyByEntityIdent(@bntEntityIdent BIGINT, @nvrUsername NVARCHAR(75))

	RETURNS NVARCHAR(MAX)

AS

	BEGIN
		
		DECLARE @nvrEmailList NVARCHAR(MAX)
		SELECT 
			@nvrEmailList = COALESCE(@nvrEmailList + ', ','') + EE.Email
		FROM 
			EntityEmail EE WITH (NOLOCK)
		WHERE 
			EntityIdent = @bntEntityIdent
			AND (Notify = 1 OR @nvrUsername = '') -- if they are not registered (username = ''), then return all emails because well send them the register email
			AND Active = 1

		SELECT 
			@nvrEmailList = COALESCE(@nvrEmailList,  '')

		RETURN RTRIM(LTRIM(@nvrEmailList))

	END
	
GO

-- SELECT dbo.ufnGetEntityEmailListUnformattedByEntityIdent(306512)