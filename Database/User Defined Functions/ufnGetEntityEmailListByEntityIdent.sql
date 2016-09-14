IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetEntityEmailListByEntityIdent') and xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION ufnGetEntityEmailListByEntityIdent
GO

/* ufnGetEntityEmailListByEntityIdent
 *
 *	Returns a string of the active email addresses concatinated together separated by commas
 *
 */
CREATE FUNCTION ufnGetEntityEmailListByEntityIdent(@bntEntityIdent BIGINT)

	RETURNS NVARCHAR(MAX)

AS

	BEGIN
		
		DECLARE @nvrEmailList NVARCHAR(MAX)
		SELECT 
			@nvrEmailList = CASE Notify 
								WHEN 1 THEN 
									COALESCE(@nvrEmailList + ', ','') + '<a href="mailto:' + Email + '">' + Email + '*</a>'
								ELSE
									COALESCE(@nvrEmailList + ', ','') + '<a href="mailto:' + Email + '">' + Email + '</a>'
								END 
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

SELECT dbo.ufnGetEntityEmailListByEntityIdent(1)