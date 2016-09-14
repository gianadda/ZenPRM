IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnEntitySearchHierarchySpecific') 
	AND OBJECTPROPERTY(id, N'IsTableFunction') = 1)
DROP FUNCTION ufnEntitySearchHierarchySpecific
GO


/* ufnEntitySearchHierarchySpecific
 *
 * Advanced Search, with filters, to find which resources are within an EntityHierarchy
 *
 *
*/
CREATE FUNCTION ufnEntitySearchHierarchySpecific(@bntEntityIdent BIGINT, @tblEntity AS [EntitySearchTable] READONLY, @tblEntityFilter AS [EntitySearchFilterTable] READONLY)
RETURNS @tblResults TABLE
	(
		EntityIdent BIGINT,
		tmpSearchFiltersIdent BIGINT,
		MatchCount INTEGER
	)
AS

	BEGIN

		DECLARE @bntReferenceIdent BIGINT,
				@bntIdent BIGINT,
				@nvrSearchValue NVARCHAR(MAX)

		DECLARE @tblOrganizations TABLE (
			EntityIdent BIGINT
		)

		DECLARE entity_cursor CURSOR FOR
		SELECT
			Ident,
			ReferenceIdent,
			SearchValue
		FROM
			@tblEntityFilter

		OPEN entity_cursor

		FETCH NEXT FROM entity_cursor
		INTO @bntIdent, @bntReferenceIdent,@nvrSearchValue

		WHILE @@FETCH_STATUS = 0
		BEGIN

			DELETE FROM @tblOrganizations
			
			INSERT INTO @tblOrganizations(
				EntityIdent
			)
			SELECT	
				TRY_CAST([Value] AS BIGINT)
			FROM
				dbo.ufnSplitString(@nvrSearchValue,N'|')
			WHERE
				[Value] <> ''
				AND TRY_CAST([Value] AS BIGINT) IS NOT NULL

			-- we need to check the entity hierarchy based on :
			-- 1. Ensuring the record belongs to the customer (EH.EntityIdent = @bntEntityIdent)
			-- 2. We are filtering by the searched orgs (INNER JOIN TO @tblOrganizations)
			-- 3. We are filting against our current entity set (JOIN @tblEntity to ToEntityIdent)
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
				EntityHierarchy EH WITH (NOLOCK)
					ON EH.ToEntityIdent = tE.EntityIdent
				INNER JOIN
				@tblOrganizations tblO
					ON tblO.EntityIdent = EH.FromEntityIdent
			WHERE
				EH.EntityIdent = @bntEntityIdent
				AND EH.HierarchyTypeIdent = @bntReferenceIdent
				AND EH.Active = 1
			GROUP BY
				tE.EntityIdent

			FETCH NEXT FROM entity_cursor
			INTO @bntIdent, @bntReferenceIdent,@nvrSearchValue

		END
		
		CLOSE entity_cursor
		DEALLOCATE entity_cursor

		RETURN

	END
	
GO
