IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnEntitySearchProjectSpecificHoursOfOperation') 
	AND OBJECTPROPERTY(id, N'IsTableFunction') = 1)
DROP FUNCTION ufnEntitySearchProjectSpecificHoursOfOperation
GO

/* ufnEntitySearchProjectSpecificHoursOfOperation
 *
 * Advanced Search, with filters, to find which resources match the hours of operation criteria
 *
 *
*/
CREATE FUNCTION ufnEntitySearchProjectSpecificHoursOfOperation (@tblEntity AS [EntitySearchTable] READONLY, @tblEntityFilter AS [EntitySearchFilterTable] READONLY)
RETURNS @tblResults TABLE
	(
		EntityIdent BIGINT,
		tmpSearchFiltersIdent BIGINT,
		MatchCount INTEGER
	)
AS

	BEGIN

		DECLARE @bntIdent BIGINT,
				@bntEntityProjectRequirementIdent BIGINT,
				@bntEntitySearchOperatorIdent BIGINT,
				@bntReferenceIdent BIGINT,
				@nvrSearchValue NVARCHAR(MAX),
				@dteFilterDate DATE,
				@tmeFilterTime TIME,
				@intDatePart INT,
				@nvrDayOfWeek NVARCHAR(10)

		DECLARE entity_cursor CURSOR FOR
		SELECT
			Ident,
			EntityProjectRequirementIdent,
			EntitySearchOperatorIdent,
			ReferenceIdent,
			SearchValue
		FROM
			@tblEntityFilter

		OPEN entity_cursor

		FETCH NEXT FROM entity_cursor
		INTO @bntIdent, @bntEntityProjectRequirementIdent, @bntEntitySearchOperatorIdent, @bntReferenceIdent, @nvrSearchValue

		WHILE @@FETCH_STATUS = 0
		BEGIN

			IF (@nvrSearchValue = '')
				BEGIN
					SET @dteFilterDate = CAST(dbo.ufnGetMyDate() AS DATE)
					SET @tmeFilterTime = CAST(dbo.ufnGetMyDate() AS TIME)
				END
			ELSE
				BEGIN
					SET @dteFilterDate = CAST(@nvrSearchValue AS DATE)
					SET @tmeFilterTime = CAST(@nvrSearchValue AS TIME)
				END

			
			SET @intDatePart = DATEPART(dw, @dteFilterDate)

			SET @nvrDayOfWeek = CASE @intDatePart
									WHEN 1 THEN 'Sunday'
									WHEN 2 THEN 'Monday'
									WHEN 3 THEN 'Tuesday'
									WHEN 4 THEN 'Wednesday'
									WHEN 5 THEN 'Thursday'
									WHEN 6 THEN 'Friday'
									WHEN 7 THEN 'Saturday'
									ELSE 'Unknown'
								END

			-- first we will filter based on whether a location is open at a specific date/time
			INSERT INTO @tblResults(
				EntityIdent,
				tmpSearchFiltersIdent,
				MatchCount
			)
			SELECT
				tE.EntityIdent,
				@bntIdent,
				1
			FROM
				@tblEntity tE
				INNER JOIN
				EntityProject EP WITH (NOLOCK)
					ON EP.Ident = @bntReferenceIdent
				INNER JOIN
				EntityProjectRequirement EPR WITH (NOLOCK)
					ON EPR.EntityProjectIdent = EP.Ident
					AND EPR.Ident = @bntEntityProjectRequirementIdent
				INNER JOIN
				EntityProjectEntity EPE WITH (NOLOCK)
					ON EPE.EntityProjectIdent = EP.Ident
					AND EPE.EntityIdent = tE.EntityIdent
				INNER JOIN
				EntityProjectEntityAnswer EPEA WITH (NOLOCK)
					ON EPEA.EntityProjectEntityIdent = EPE.Ident
					AND EPEA.EntityProjectRequirementIdent = EPR.Ident
				INNER JOIN
				EntityProjectEntityAnswerValue EPEAVs WITH (NOLOCK)
					ON EPEAVs.EntityProjectEntityAnswerIdent = EPEA.Ident
					AND EPEAVs.Name1 = @nvrDayOfWeek + 'StartTime'
					AND EPEAVs.Active = 1
				INNER JOIN
				EntityProjectEntityAnswerValue EPEAVe WITH (NOLOCK)
					ON EPEAVe.EntityProjectEntityAnswerIdent = EPEA.Ident
					AND EPEAVe.Name1 = @nvrDayOfWeek + 'EndTime'
					AND EPEAVe.Active = 1
				LEFT OUTER JOIN
				EntityProjectEntityAnswerValue EPEAVc WITH (NOLOCK)
					ON EPEAVc.EntityProjectEntityAnswerIdent = EPEA.Ident
					AND EPEAVc.Name1 = @nvrDayOfWeek + 'Closed'
					AND EPEAVc.Active = 1
			WHERE
				@bntEntitySearchOperatorIdent = 39 -- Is Open at this Date/Time
				AND EPE.Active = 1
				AND EPEA.Active = 1
				AND (EPEAVc.Value1 IS NULL OR EPEAVc.Value1 = '' OR EPEAVc.Value1 = 'False')
				AND (EPEAVs.Value1 <> '' AND TRY_CAST(SUBSTRING(EPEAVs.Value1,11,9) AS TIME) <= @tmeFilterTime)
				AND (EPEAVe.Value1 <> '' AND TRY_CAST(SUBSTRING(EPEAVe.Value1,11,9) AS TIME) >= @tmeFilterTime)

			-- second we will filter based on whether a location is open today
			INSERT INTO @tblResults(
				EntityIdent,
				tmpSearchFiltersIdent,
				MatchCount
			)
			SELECT
				tE.EntityIdent,
				@bntIdent,
				1
			FROM
				@tblEntity tE
				INNER JOIN
				EntityProject EP WITH (NOLOCK)
					ON EP.Ident = @bntReferenceIdent
				INNER JOIN
				EntityProjectRequirement EPR WITH (NOLOCK)
					ON EPR.EntityProjectIdent = EP.Ident
					AND EPR.Ident = @bntEntityProjectRequirementIdent
				INNER JOIN
				EntityProjectEntity EPE WITH (NOLOCK)
					ON EPE.EntityProjectIdent = EP.Ident
					AND EPE.EntityIdent = tE.EntityIdent
				INNER JOIN
				EntityProjectEntityAnswer EPEA WITH (NOLOCK)
					ON EPEA.EntityProjectEntityIdent = EPE.Ident
					AND EPEA.EntityProjectRequirementIdent = EPR.Ident
				INNER JOIN
				EntityProjectEntityAnswerValue EPEAVs WITH (NOLOCK)
					ON EPEAVs.EntityProjectEntityAnswerIdent = EPEA.Ident
					AND EPEAVs.Name1 = @nvrDayOfWeek + 'StartTime'
					AND EPEAVs.Active = 1
				INNER JOIN
				EntityProjectEntityAnswerValue EPEAVe WITH (NOLOCK)
					ON EPEAVe.EntityProjectEntityAnswerIdent = EPEA.Ident
					AND EPEAVe.Name1 = @nvrDayOfWeek + 'EndTime'
					AND EPEAVe.Active = 1
				LEFT OUTER JOIN
				EntityProjectEntityAnswerValue EPEAVc WITH (NOLOCK)
					ON EPEAVc.EntityProjectEntityAnswerIdent = EPEA.Ident
					AND EPEAVc.Name1 = @nvrDayOfWeek + 'Closed'
					AND EPEAVc.Active = 1
			WHERE
				@bntEntitySearchOperatorIdent = 40 -- Is Open at this Date/Time
				AND EPE.Active = 1
				AND EPEA.Active = 1
				AND (EPEAVs.Value1 <> '')
				AND (EPEAVe.Value1 <> '')
				AND (EPEAVc.Value1 IS NULL OR EPEAVc.Value1 = '' OR EPEAVc.Value1 = 'False')
				
			FETCH NEXT FROM entity_cursor
			INTO @bntIdent, @bntEntityProjectRequirementIdent, @bntEntitySearchOperatorIdent, @bntReferenceIdent, @nvrSearchValue

		END

		CLOSE entity_cursor
		DEALLOCATE entity_cursor

		RETURN

	END
	
GO
