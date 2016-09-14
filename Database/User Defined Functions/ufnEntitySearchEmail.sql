IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnEntitySearchEmail') 
	AND OBJECTPROPERTY(id, N'IsTableFunction') = 1)
DROP FUNCTION ufnEntitySearchEmail
GO

/* ufnEntitySearchEmail
 *
 * Entity Search, with filters, to find which resources match the email search criteria
 *
 *
*/
CREATE FUNCTION ufnEntitySearchEmail(@tblEntity AS [EntitySearchTable] READONLY, @tblEntityFilter AS [EntitySearchFilterTable] READONLY)
RETURNS @tblResults TABLE
	(
		EntityIdent BIGINT,
		tmpSearchFiltersIdent BIGINT,
		MatchCount INTEGER
	)
AS

	BEGIN
	
		DECLARE @bntEntitySearchOperatorIdent BIGINT,
				@nvrSearchValue NVARCHAR(MAX),
				@intSearchLength INT,
				@bntIdent BIGINT
				
		DECLARE entity_cursor CURSOR FOR
		SELECT
			Ident,
			EntitySearchOperatorIdent,
			LTRIM(RTRIM(SearchValue))
		FROM
			@tblEntityFilter

		OPEN entity_cursor

		FETCH NEXT FROM entity_cursor
		INTO @bntIdent, @bntEntitySearchOperatorIdent, @nvrSearchValue

		WHILE @@FETCH_STATUS = 0
		BEGIN

			SET @intSearchLength = LEN(@nvrSearchValue)
		
			-- Is Exactly
			INSERT INTO @tblResults(
				EntityIdent,
				tmpSearchFiltersIdent,
				MatchCount
			)
			SELECT DISTINCT
				tE.EntityIdent,
				@bntIdent,
				1
			FROM
				@tblEntity tE
				INNER JOIN
				EntityEmail EE WITH (NOLOCK)
					ON EE.EntityIdent = tE.EntityIdent
			WHERE
				@bntEntitySearchOperatorIdent = 56 -- Is Exactly
				AND EE.Active = 1
				AND EE.Email = @nvrSearchValue
			
			-- Contains
			INSERT INTO @tblResults(
				EntityIdent,
				tmpSearchFiltersIdent,
				MatchCount
			)
			SELECT DISTINCT
				tE.EntityIdent,
				@bntIdent,
				1
			FROM
				@tblEntity tE
				INNER JOIN
				EntityEmail EE WITH (NOLOCK)
					ON EE.EntityIdent = tE.EntityIdent
			WHERE
				@bntEntitySearchOperatorIdent = 57 -- Contains
				AND EE.Active = 1
				AND EE.Email LIKE '%' + @nvrSearchValue + '%'

			-- Does Not Contain
			INSERT INTO @tblResults(
				EntityIdent,
				tmpSearchFiltersIdent,
				MatchCount
			)
			SELECT DISTINCT
				tE.EntityIdent,
				@bntIdent,
				1
			FROM
				@tblEntity tE
				INNER JOIN
				EntityEmail EE WITH (NOLOCK)
					ON EE.EntityIdent = tE.EntityIdent
			WHERE
				@bntEntitySearchOperatorIdent = 58 -- Does Not Contain
				AND EE.Active = 1
				AND EE.Email NOT LIKE '%' + @nvrSearchValue + '%'

			-- Starts With
			INSERT INTO @tblResults(
				EntityIdent,
				tmpSearchFiltersIdent,
				MatchCount
			)
			SELECT DISTINCT
				tE.EntityIdent,
				@bntIdent,
				1
			FROM
				@tblEntity tE
				INNER JOIN
				EntityEmail EE WITH (NOLOCK)
					ON EE.EntityIdent = tE.EntityIdent
			WHERE
				@bntEntitySearchOperatorIdent = 59 -- Starts With
				AND EE.Active = 1
				AND LEFT(EE.Email,@intSearchLength) = @nvrSearchValue
			
			-- Ends With
			INSERT INTO @tblResults(
				EntityIdent,
				tmpSearchFiltersIdent,
				MatchCount
			)
			SELECT DISTINCT
				tE.EntityIdent,
				@bntIdent,
				1
			FROM
				@tblEntity tE
				INNER JOIN
				EntityEmail EE WITH (NOLOCK)
					ON EE.EntityIdent = tE.EntityIdent
			WHERE
				@bntEntitySearchOperatorIdent = 60 -- Ends With
				AND EE.Active = 1
				AND RIGHT(EE.Email,@intSearchLength) = @nvrSearchValue
			
			-- No Email on File
			INSERT INTO @tblResults(
				EntityIdent,
				tmpSearchFiltersIdent,
				MatchCount
			)
			SELECT DISTINCT
				tE.EntityIdent,
				@bntIdent,
				1
			FROM
				@tblEntity tE
				LEFT OUTER JOIN
				EntityEmail EE WITH (NOLOCK)
					ON EE.EntityIdent = tE.EntityIdent
					AND EE.Active = 1
			WHERE
				@bntEntitySearchOperatorIdent = 61 -- No Email on File
				AND EE.Ident IS NULL
	
			-- Has Email on File
			INSERT INTO @tblResults(
				EntityIdent,
				tmpSearchFiltersIdent,
				MatchCount
			)
			SELECT DISTINCT
				tE.EntityIdent,
				@bntIdent,
				1
			FROM
				@tblEntity tE
				INNER JOIN
				EntityEmail EE WITH (NOLOCK)
					ON EE.EntityIdent = tE.EntityIdent
			WHERE
				@bntEntitySearchOperatorIdent = 62 -- Has Email on File
				AND EE.Active = 1

			-- Has Opted-Out of Emails
			INSERT INTO @tblResults(
				EntityIdent,
				tmpSearchFiltersIdent,
				MatchCount
			)
			SELECT DISTINCT
				tE.EntityIdent,
				@bntIdent,
				1
			FROM
				@tblEntity tE
				INNER JOIN
				EntityEmail EE WITH (NOLOCK)
					ON EE.EntityIdent = tE.EntityIdent
			WHERE
				@bntEntitySearchOperatorIdent = 63 -- Has Opted-Out of Emails
				AND EE.Active = 1
				AND EE.Verified = 1 
				AND EE.Notify = 0
					

			FETCH NEXT FROM entity_cursor
			INTO @bntIdent, @bntEntitySearchOperatorIdent, @nvrSearchValue

		END
		
		CLOSE entity_cursor
		DEALLOCATE entity_cursor

		RETURN

	END
	
GO
