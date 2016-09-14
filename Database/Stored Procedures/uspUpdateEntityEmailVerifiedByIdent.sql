IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspUpdateEntityEmailVerifiedByIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspUpdateEntityEmailVerifiedByIdent
GO
/********************************************************
 * This procedure will update an entity Email as verified														
 *
 *	uspUpdateEntityEmailVerifiedByIdent 
 *
 ********************************************************/
 
CREATE PROCEDURE uspUpdateEntityEmailVerifiedByIdent

	@intIdent BIGINT,
	@nvrMessageQueueGUID NVARCHAR(MAX)

AS
	
	UPDATE
		EE
	SET
		Verified = 1,
		VerifiedASUserIdent = EE.EntityIdent, -- assuming this is always going to be the user
		VerifiedDateTime = dbo.ufnGetMyDate(),
		Notify = 1 -- default users to notify when the verify their email
	FROM
		EntityEmail EE WITH (NOLOCK)
	WHERE
		Ident = @intIdent

	-- now that the email is verified, deactivate the link
	EXEC uspDeactivateMessageQueueGUID @nvrMessageQueueGUID

	SELECT @intIdent as [EntityEmailIdent]
	
GO