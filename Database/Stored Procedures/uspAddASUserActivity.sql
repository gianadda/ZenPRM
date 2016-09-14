IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddASUserActivity') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspAddASUserActivity
GO

/* uspAddASUserActivity
 *
 *	
 *
 */

CREATE PROCEDURE uspAddASUserActivity

	@bntASUserIdent BIGINT,
	@bntActivityTypeIdent BIGINT,
	@nvrActivityDescription NVARCHAR(MAX),
	@nvrClientIPAddress NVARCHAR(50),
	@bntRecordIdent BIGINT,
	@bntCustomerEntityIdent BIGINT

AS
	
	SET NOCOUNT ON

	INSERT INTO ASUserActivity(
		ASUserIdent,
		ActivityTypeIdent,
		ActivityDateTime,
		ActivityDescription,
		ClientIPAddress,
		RecordIdent,
		CustomerEntityIdent,
		UpdatedEntityIdent
	)
	SELECT
		ASUserIdent = @bntASUserIdent,
		ActivityTypeIdent = @bntActivityTypeIdent,
		ActivityDateTime = dbo.ufnGetMyDate(),
		ActivityDescription = @nvrActivityDescription,
		ClientIPAddress = @nvrClientIPAddress,
		RecordIdent = @bntRecordIdent,
		CustomerEntityIdent = @bntCustomerEntityIdent,
		UpdatedEntityIdent = 0 -- this is only used for logins / logouts, so this value will never be set

	SELECT SCOPE_IDENTITY() AS [Ident]

GO