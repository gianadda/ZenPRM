IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetEntityDelegateEmailListByEntityIdent') and xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION ufnGetEntityDelegateEmailListByEntityIdent
GO

/* ufnGetEntityDelegateEmailListByEntityIdent
 *
 *	Returns a string of the active email addresses for an entity's delegate concatinated together separated by semi-colon
 *
 */
CREATE FUNCTION ufnGetEntityDelegateEmailListByEntityIdent(@bntEntityIdent BIGINT)

	RETURNS NVARCHAR(MAX)

AS

	BEGIN
		
		DECLARE @nvrEmailList NVARCHAR(MAX)

		SELECT 
			@nvrEmailList = COALESCE(@nvrEmailList + ';','') + EE.Email
		FROM 
			EntityDelegate ED WITH (NOLOCK)
			INNER JOIN
			Entity toE WITH (NOLOCK)
				ON ED.ToEntityIdent = toE.Ident
			INNER JOIN
			EntityEmail EE WITH (NOLOCK)
				ON EE.EntityIdent = toE.Ident
		WHERE 
			ED.Active = 1
			AND ED.FromEntityIdent = @bntEntityIdent
			AND EE.Active = 1
			AND EE.Notify = 1

		SELECT 
			@nvrEmailList = COALESCE(@nvrEmailList,  '')

		RETURN RTRIM(LTRIM(@nvrEmailList))

	END
	
GO
