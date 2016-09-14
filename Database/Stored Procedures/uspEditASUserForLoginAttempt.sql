IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspEditASUserForLoginAttempt') 
	and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspEditASUserForLoginAttempt
GO
/* uspEditASUserForLoginAttempt
 *
 *	Computes the logic for login attempts, locking user for failed attempts etc....
 *
 */
CREATE PROCEDURE uspEditASUserForLoginAttempt

	@vcrUserName NVARCHAR(150),
	@bitLoginSuccess BIT,
	@bntASUserIdent BIGINT

AS

	DECLARE @sdtGetDate SMALLDATETIME,
			@vcrMaxLoginAttemptUserLockedPeriod VARCHAR(3000),
			@bntMaxLoginAttemptUserLockedPeriod BIGINT,
			@sdtCurrentLockedTime SMALLDATETIME,
			@bntFailedLoginCount BIGINT,
			@bitUserIsLocked BIT , --return from SP
			@sdtTimeUserAccountWillUnLocked SMALLDATETIME, --return from SP
			@vcrMaxLoginAttemptBeforeUserLocked VARCHAR(3000),
			@bntMaxLoginAttemptBeforeUserLocked BIGINT

	SET @sdtGetDate = dbo.ufnGetMyDate()
	SET @vcrMaxLoginAttemptUserLockedPeriod = dbo.ufnGetASApplicationVariableByName1(N'MaxLoginAttemptUserLockedPeriod')
	SET @vcrMaxLoginAttemptBeforeUserLocked = dbo.ufnGetASApplicationVariableByName1(N'MaxLoginAttemptBeforeUserLocked') 
		
	IF ISNUMERIC(@vcrMaxLoginAttemptUserLockedPeriod) = 1
		SET @bntMaxLoginAttemptUserLockedPeriod = CONVERT(INT, @vcrMaxLoginAttemptUserLockedPeriod)
	ELSE
		SET @bntMaxLoginAttemptUserLockedPeriod = 0

	IF ISNUMERIC(@vcrMaxLoginAttemptBeforeUserLocked) = 1
		SET @bntMaxLoginAttemptBeforeUserLocked = CONVERT(INT, @vcrMaxLoginAttemptBeforeUserLocked)
	ELSE
		SET @bntMaxLoginAttemptBeforeUserLocked = 0

	-- PORTING IN uspEditLoginForAttempt AFTER REMOVING DYNAMIC sql

	--Reset locktime if the time is greater than @bntMaxLoginAttemptUserLockedPeriod (minutes)
	UPDATE Entity
	SET
		LockedTime = '01/01/1900'
	WHERE
		UserName = @vcrUserName
		AND Ident > 0
		AND DATEDIFF(mi, LockedTime , @sdtGetDate) > @bntMaxLoginAttemptUserLockedPeriod

	SELECT 
		@sdtCurrentLockedTime = LockedTime
	FROM
		Entity WITH (NOLOCK)
	WHERE
		UserName = @vcrUserName
		AND Ident > 0

	--Reset failed count if last LockedTime is greater than @bntMaxLoginAttemptUserLockedPeriod (minutes)
	UPDATE Entity
	SET
		FailedLoginCount = 0
	WHERE
		UserName = @vcrUserName			
		AND Ident > 0
		AND (DATEDIFF(mi, @sdtCurrentLockedTime , @sdtGetDate) > @bntMaxLoginAttemptUserLockedPeriod
				AND @sdtCurrentLockedTime <> '01/01/1900')

	IF @bitLoginSuccess = 0

		BEGIN

		UPDATE Entity
		SET
			FailedLoginCount = FailedLoginCount + 1
		WHERE
			UserName = @vcrUserName
			AND Ident > 0

		END

	ELSE

		BEGIN

		IF @sdtCurrentLockedTime = '01/01/1900' --only reset failed count if login is successful and currently not locked

			BEGIN

			UPDATE Entity
			SET
				FailedLoginCount = 0
			WHERE
				UserName = @vcrUserName
				AND Ident = @bntASUserIdent

			SET 
				@bntFailedLoginCount = 0			

			END

		END

	SELECT 
		@bntFailedLoginCount = FailedLoginCount
	FROM
		Entity WITH (NOLOCK)
	WHERE
		UserName = @vcrUserName	
		AND Ident > 0

	--Update last login attempt
	UPDATE Entity
	SET
		LastLoginAttempted = @sdtGetDate
	WHERE
		UserName = @vcrUserName
		AND Ident > 0

	--update last successful login, if success
	IF @bitLoginSuccess = 1

	  BEGIN

	  IF @sdtCurrentLockedTime = '01/01/1900'

	   BEGIN

			UPDATE Entity
			SET
				LastSuccessfulLogin = @sdtGetDate
			WHERE
				UserName = @vcrUserName
				AND Ident = @bntASUserIdent

		END

	  ELSE

		SET @bitUserIsLocked = 1
		SET @sdtTimeUserAccountWillUnLocked = @sdtCurrentLockedTime

	  END

	ELSE --if success

	  BEGIN

		--if fail, check how many times it failed.
		IF @bntFailedLoginCount >= @bntMaxLoginAttemptBeforeUserLocked AND @bntMaxLoginAttemptBeforeUserLocked > 0

		  BEGIN

			UPDATE Entity 
			SET
				LockedTime = @sdtGetDate
			WHERE
				UserName = @vcrUserName
				AND LockedTime = '01/01/1900' --only update time if not locked

			SELECT 
				@sdtTimeUserAccountWillUnLocked = LockedTime
			FROM
				Entity WITH (NOLOCK)
			WHERE
				UserName = @vcrUserName

			SET @bitUserIsLocked = 1

		  END -- IF @bntFailedLoginCount >= @bntMaxLoginAttemptBeforeUserLocked 

	  END -- IF @bitLoginSuccess = 1
	
	SELECT 
		COALESCE(@bntFailedLoginCount, 0) AS 'FailedCount' ,
		@bntMaxLoginAttemptUserLockedPeriod AS 'UserLockedPeriodMinutes',
		COALESCE(@bitUserIsLocked, 0) AS 'UserIsLocked' ,
		@bntMaxLoginAttemptBeforeUserLocked AS 'MaxLoginAttemptBeforeUserLocked' ,
		COALESCE(DATEADD(mi, @bntMaxLoginAttemptUserLockedPeriod, @sdtTimeUserAccountWillUnLocked), '01/01/1900') AS 'TimeUserAccountWillUnLocked'

GO