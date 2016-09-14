IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspEditASUserForMustChangePasswordInterval') 
	and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspEditASUserForMustChangePasswordInterval
GO
/* uspEditASUserForMustChangePasswordInterval
 *
 *	Computes the logic for must change password becuause of defined interval....
 *
 */
CREATE PROCEDURE uspEditASUserForMustChangePasswordInterval

	@bntASUserIdent BIGINT,
	@intDaysBeforePasswordMustBeChanged INT 

AS

	DECLARE @sdtLastPasswordChange SMALLDATETIME 
	
	SELECT 
		@sdtLastPasswordChange = LastPasswordChangedDate
	FROM
		Entity WITH (NOLOCK)
	WHERE
		Ident = @bntASUserIdent

	IF  DATEDIFF(dd, @sdtLastPasswordChange, dbo.ufnGetMyDate()) >= @intDaysBeforePasswordMustBeChanged
				
		BEGIN
				
			UPDATE Entity
			SET
				MustChangePassword = 1
			WHERE
				Ident = @bntASUserIdent

			SELECT 1

		END

	ELSE

		SELECT 0
			 
GO