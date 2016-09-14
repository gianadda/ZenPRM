IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnEntitySearchProjectSpecificAddress') 
	AND OBJECTPROPERTY(id, N'IsTableFunction') = 1)
DROP FUNCTION ufnEntitySearchProjectSpecificAddress
GO

/* ufnEntitySearchProjectSpecificAddress
 *
 * Advanced Search, with filters, to find which resources match the address criteria
 *
 *
*/
CREATE FUNCTION ufnEntitySearchProjectSpecificAddress (@tblEntity AS [EntitySearchTable] READONLY, @tblEntityFilter AS [EntitySearchFilterTable] READONLY)
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
				@nvrSearchValue NVARCHAR(MAX)

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
		
			-- first we will filter based on all the columns except state , we need a different join for that
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
				EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
					ON EPEAV.EntityProjectEntityAnswerIdent = EPEA.Ident
			WHERE
				@bntEntitySearchOperatorIdent NOT IN (48,49) -- state filters
				AND EPE.Active = 1
				AND EPEA.Active = 1
				AND EPEAV.Active = 1
				AND EPEAV.Name1 = CASE @bntEntitySearchOperatorIdent
						WHEN 43 THEN 'Address1'
						WHEN 44 THEN 'Address1'
						WHEN 45 THEN 'Address1'
						WHEN 46 THEN 'City'
						WHEN 47 THEN 'City'
						WHEN 50 THEN 'Zip'
						WHEN 51 THEN 'Zip'
					END
				AND ((EPEAV.Value1 = @nvrSearchValue AND @bntEntitySearchOperatorIdent IN (43,46,50)) -- Address, City, Zip equal to
					OR (EPEAV.Value1 <> @nvrSearchValue AND @bntEntitySearchOperatorIdent IN (44,47,51)) -- Address, City, Zip NOT equal to
					OR ((EPEAV.Value1 LIKE '%' + @nvrSearchValue + '%') AND @bntEntitySearchOperatorIdent = 45)) -- Address contains

			-- now we will filter based on all the columns for state 
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
				EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
					ON EPEAV.EntityProjectEntityAnswerIdent = EPEA.Ident
			WHERE
				@bntEntitySearchOperatorIdent IN (48,49) -- state filters
				AND EPE.Active = 1
				AND EPEA.Active = 1
				AND EPEAV.Active = 1
				AND EPEAV.Name1 = 'StateName'
				AND ((EPEAV.Value1 = @nvrSearchValue AND @bntEntitySearchOperatorIdent = 48) -- state is equal to
					OR (EPEAV.Value1 <> @nvrSearchValue AND @bntEntitySearchOperatorIdent = 49))

			FETCH NEXT FROM entity_cursor
			INTO @bntIdent, @bntEntityProjectRequirementIdent, @bntEntitySearchOperatorIdent, @bntReferenceIdent, @nvrSearchValue

		END

		CLOSE entity_cursor
		DEALLOCATE entity_cursor

		RETURN

	END
	
GO
