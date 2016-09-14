IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnEntitySearchProjectSpecificOptionList') 
	AND OBJECTPROPERTY(id, N'IsTableFunction') = 1)
DROP FUNCTION ufnEntitySearchProjectSpecificOptionList
GO

/* ufnEntitySearchProjectSpecificOptionList
 *
 * Advanced Search, with filters, to find which resources selected an option included in the option list
 *
 *
*/
CREATE FUNCTION ufnEntitySearchProjectSpecificOptionList(@tblEntity AS [EntitySearchTable] READONLY, @tblEntityFilter AS [EntitySearchFilterTable] READONLY)
RETURNS @tblResults TABLE
	(
		EntityIdent BIGINT,
		tmpSearchFiltersIdent BIGINT,
		MatchCount INTEGER
	)
AS

	BEGIN

		DECLARE @bntEntityProjectRequirementIdent BIGINT,
				@bntEntitySearchOperatorIdent BIGINT,
				@bntReferenceIdent BIGINT,
				@nvrSearchValue NVARCHAR(MAX),
				@bntIdent BIGINT,
				@bntOptionsCount BIGINT

		DECLARE @tblOptions TABLE (
			OptionValue NVARCHAR(MAX)
		)

		DECLARE @tblMatchedEntity TABLE(
			EntityIdent BIGINT,
			RequirementIdent BIGINT
		)
		
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

			DELETE FROM @tblOptions
			DELETE FROM @tblMatchedEntity
			
			INSERT INTO @tblOptions(
				OptionValue
			)
			SELECT	
				[Value]
			FROM
				dbo.ufnSplitString(@nvrSearchValue,N'|')

			SET @bntOptionsCount = 0

			SELECT
				@bntOptionsCount = COUNT(*)
			FROM
				@tblOptions

			INSERT INTO @tblMatchedEntity(
				EntityIdent,
				RequirementIdent
			)
			SELECT
				tE.EntityIdent,
				EPR.Ident
			FROM
				@tblOptions tmpO,
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
				EPE.Active = 1
				AND EPEA.Active = 1
				AND EPEAV.Active = 1
				AND ((EPEAV.Name1 = tmpO.OptionValue AND UPPER(EPEAV.Value1) = 'TRUE') -- tags & multi-selects
						OR (EPEAV.Name1 = '' AND EPEAV.Value1 = tmpO.OptionValue))  -- single choice

			-- heres the first check, return any records that match on ONE OF the selected values
			INSERT INTO @tblResults(
				EntityIdent,
				tmpSearchFiltersIdent,
				MatchCount
			)
			SELECT
				tME.EntityIdent,
				@bntIdent,
				1
			FROM
				@tblMatchedEntity tME
			WHERE
				@bntEntitySearchOperatorIdent = 26 -- Selected One of the Values
			GROUP BY
				tME.EntityIdent,
				tME.RequirementIdent

			-- heres the second check, return any records that match on ALL OF the selected values
			INSERT INTO @tblResults(
				EntityIdent,
				tmpSearchFiltersIdent,
				MatchCount
			)
			SELECT
				tME.EntityIdent,
				@bntIdent,
				1
			FROM
				@tblMatchedEntity tME
			WHERE
				@bntEntitySearchOperatorIdent = 27 -- Selected All of the Values
			GROUP BY
				tME.EntityIdent,
				tME.RequirementIdent
			HAVING
				COUNT(tME.RequirementIdent) >= @bntOptionsCount -- user might only be checking a subset of options

			-- heres the third check, return any records that match on NONE OF the selected values
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
				OUTER APPLY 
			   ( 
				SELECT 
					tME.EntityIdent
				FROM 
					@tblMatchedEntity tME
				WHERE 
					tME.EntityIdent = tE.EntityIdent
			   ) A 
			WHERE
				@bntEntitySearchOperatorIdent = 28 -- Selected None of the Values
				AND EPE.Active = 1
				AND EPEA.Active = 1
				AND COALESCE(A.EntityIdent,0) = 0 -- return those entities that did not match on the 
				
			GROUP BY
				tE.EntityIdent
				
			FETCH NEXT FROM entity_cursor
			INTO @bntIdent, @bntEntityProjectRequirementIdent, @bntEntitySearchOperatorIdent, @bntReferenceIdent, @nvrSearchValue

		END

		CLOSE entity_cursor
		DEALLOCATE entity_cursor

		RETURN 

	END
	
GO
