IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnFormatHoursOfOperation') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnFormatHoursOfOperation
GO
/* ufnFormatHoursOfOperation
 *
 *	Formats the hours of operation answers into a readable string, i.e.
 *	Sunday: Closed; Monday: 10am - 5pm; Tuesday: 10am - 5pm; Wednesday: Closed; Thursday: 10am - 5pm; Friday: 9am - 12pm; Saturday: Closed
 *
 */
CREATE FUNCTION ufnFormatHoursOfOperation(@bntEntityProjectEntityAnswerIdent AS BIGINT)

	RETURNS NVARCHAR(MAX)
	
 BEGIN

	DECLARE @nvrHoursOfOperation NVARCHAR(MAX)
	DECLARE @nvrCurrentDayOfWeek NVARCHAR(20)
	DECLARE @nvrClosed NVARCHAR(MAX)
	DECLARE @nvrStartTime NVARCHAR(MAX)
	DECLARE @nvrEndTime NVARCHAR(MAX)
	DECLARE @dteHoursOfOp DATETIME
	DECLARE @intHours INT
	DECLARE @intMinutes INT

	SET @nvrHoursOfOperation = ''

	DECLARE @tblValues TABLE(
		Name1 NVARCHAR(MAX),
		Value1 NVARCHAR(MAX)
	)

	
	DECLARE @tblDaysOfWeek TABLE(
		OrderNo INT,
		Name1 NVARCHAR(20)
	)

	INSERT INTO @tblDaysOfWeek(
		OrderNo,
		Name1
	)
	SELECT
		1,
		'Sunday'
	UNION
	SELECT
		2,
		'Monday'
	UNION
	SELECT
		3,
		'Tuesday'
	UNION
	SELECT
		4,
		'Wednesday'
	UNION
	SELECT
		5,
		'Thursday'
	UNION
	SELECT
		6,
		'Friday'
	UNION
	SELECT
		7,
		'Saturday'
	 
	-- first, get a list of all the current answers for hours of op, we will work through each one individually
	INSERT INTO @tblValues(
		Name1,
		Value1
	)
	SELECT
		Name1,
		Value1
	FROM
		EntityProjectEntityAnswerValue WITH (NOLOCK)
	WHERE
		EntityProjectEntityAnswerIdent = @bntEntityProjectEntityAnswerIdent
		AND Active = 1

	DECLARE hours_cursor CURSOR FOR
	SELECT
		Name1
	FROM
		@tblDaysOfWeek
	ORDER BY
		OrderNo ASC

	OPEN hours_cursor

	FETCH NEXT FROM hours_cursor
	INTO @nvrCurrentDayOfWeek

		WHILE @@FETCH_STATUS = 0
		BEGIN

			-- start by resetting all our variables
			SET @nvrClosed = ''
			SET @nvrStartTime = ''
			SET @nvrEndTime = ''
			SET @dteHoursOfOp = NULL
			SET @intHours = 0
			SET @intMinutes = 0

			-- and getting this day of the weeks values
			SELECT
				@nvrClosed = Value1
			FROM
				@tblValues
			WHERE
				Name1 = @nvrCurrentDayOfWeek + 'Closed'

			SELECT
				@nvrStartTime = Value1
			FROM
				@tblValues
			WHERE
				Name1 = @nvrCurrentDayOfWeek + 'StartTime'

			SELECT
				@nvrEndTime = Value1
			FROM
				@tblValues
			WHERE
				Name1 = @nvrCurrentDayOfWeek + 'EndTime'

			-- if closed is set, then were good, just show closed
			IF (@nvrClosed = 'True')
				BEGIN
					SET @nvrHoursOfOperation = @nvrHoursOfOperation + @nvrCurrentDayOfWeek + ': Closed; '
				END

			-- if closed is not set, try and calculate the opening time
			IF (@nvrClosed <> 'True' AND @nvrStartTime <> '')
				BEGIN
					
					SET @dteHoursOfOp = TRY_CAST(LEFT(@nvrStartTime,16) AS DATETIME)

					-- make sure we have a date
					IF (@dteHoursOfOp IS NOT NULL)
						BEGIN

							SET @intHours = DATEPART(hh, @dteHoursOfOp)
							SET @intMinutes = DATEPART(mi, @dteHoursOfOp)

							IF (@intHours = 0)
								BEGIN
									SET @nvrStartTime = '12:' + RIGHT('0' + CAST(@intMinutes AS NVARCHAR(2)),2) + ' am - '
								END

							IF (@intHours >= 1 AND @intHours <= 11)
								BEGIN
									SET @nvrStartTime = RIGHT('0' + CAST(@intHours AS NVARCHAR(2)),2) + ':' + RIGHT('0' + CAST(@intMinutes AS NVARCHAR(2)),2) + ' am - '
								END

							IF (@intHours = 12)
								BEGIN
									SET @nvrStartTime = '12:' + RIGHT('0' + CAST(@intMinutes AS NVARCHAR(2)),2) + ' pm - '
								END

							IF (@intHours >= 13 AND @intHours <= 23)
								BEGIN
									SET @nvrStartTime = RIGHT('0' + CAST(@intHours - 12 AS NVARCHAR(2)),2) + ':' + RIGHT('0' + CAST(@intMinutes AS NVARCHAR(2)),2) + ' pm - '
								END

							SET @nvrHoursOfOperation = @nvrHoursOfOperation + @nvrCurrentDayOfWeek + ': ' + @nvrStartTime

						END
					ELSE
						BEGIN
							SET @nvrHoursOfOperation = @nvrHoursOfOperation + @nvrCurrentDayOfWeek + ': Unknown - '
						END

				END

			IF (@nvrClosed <> 'True' AND @nvrStartTime = '' AND @nvrEndTime <> '') -- if they are all blank well just display Not Answered
				BEGIN
					SET @nvrHoursOfOperation = @nvrHoursOfOperation + @nvrCurrentDayOfWeek + ': Unknown - '
				END

			-- clear the variables again and use for closing time
			SET @dteHoursOfOp = ''
			SET @intHours = 0
			SET @intMinutes = 0
	
			-- if closed is not set, try and calculate the closing time
			IF (@nvrClosed <> 'True' AND @nvrEndTime <> '')
				BEGIN
					
					SET @dteHoursOfOp = TRY_CAST(LEFT(@nvrEndTime,16) AS DATETIME)

					-- make sure we have a date
					IF (@dteHoursOfOp IS NOT NULL)
						BEGIN

							SET @intHours = DATEPART(hh, @dteHoursOfOp)
							SET @intMinutes = DATEPART(mi, @dteHoursOfOp)

							IF (@intHours = 0)
								BEGIN
									SET @nvrEndTime = '12:' + RIGHT('0' + CAST(@intMinutes AS NVARCHAR(2)),2) + ' am; '
								END

							IF (@intHours >= 1 AND @intHours <= 11)
								BEGIN
									SET @nvrEndTime = RIGHT('0' + CAST(@intHours AS NVARCHAR(2)),2) + ':' + RIGHT('0' + CAST(@intMinutes AS NVARCHAR(2)),2) + ' am; '
								END

							IF (@intHours = 12)
								BEGIN
									SET @nvrEndTime = '12:' + RIGHT('0' + CAST(@intMinutes AS NVARCHAR(2)),2) + ' pm; '
								END

							IF (@intHours >= 13 AND @intHours <= 23)
								BEGIN
									SET @nvrEndTime = RIGHT('0' + CAST(@intHours - 12 AS NVARCHAR(2)),2) + ':' + RIGHT('0' + CAST(@intMinutes AS NVARCHAR(2)),2) + ' pm; '
								END

							SET @nvrHoursOfOperation = @nvrHoursOfOperation + @nvrEndTime

						END
					ELSE
						BEGIN
							SET @nvrHoursOfOperation = @nvrHoursOfOperation + 'Unknown; '
						END

				END

			IF (@nvrClosed <> 'True' AND @nvrEndTime = '' AND @nvrStartTime <> '') -- if they are all blank well just display Not Answered
				BEGIN
					SET @nvrHoursOfOperation = @nvrHoursOfOperation + 'Unknown; '
				END
		
			FETCH NEXT FROM hours_cursor
			INTO @nvrCurrentDayOfWeek

		END
		
	CLOSE hours_cursor
	DEALLOCATE hours_cursor

	IF (@nvrHoursOfOperation = '')
		BEGIN
			SET @nvrHoursOfOperation = 'Not Answered'
		END
	ELSE
		BEGIN
			SET @nvrHoursOfOperation = LTRIM(RTRIM(@nvrHoursOfOperation))
			SET @nvrHoursOfOperation = LEFT(@nvrHoursOfOperation, (LEN(@nvrHoursOfOperation) - 1))
		END

	RETURN @nvrHoursOfOperation

 END

GO
