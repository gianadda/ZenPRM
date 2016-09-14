IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnEntitySearchProjectSpecificIsOnProject') 
	AND OBJECTPROPERTY(id, N'IsTableFunction') = 1)
DROP FUNCTION ufnEntitySearchProjectSpecificIsOnProject
GO


/* ufnEntitySearchProjectSpecificIsOnProject
 *
 * Advanced Search, with filters, to find which resources are on a specific project
 *
 *
*/
CREATE FUNCTION ufnEntitySearchProjectSpecificIsOnProject(@tblEntity AS [EntitySearchTable] READONLY, @tblEntityFilter AS [EntitySearchFilterTable] READONLY)
RETURNS @tblResults TABLE
	(
		EntityIdent BIGINT,
		tmpSearchFiltersIdent BIGINT,
		MatchCount INTEGER
	)
AS

	BEGIN

		DECLARE @bntReferenceIdent BIGINT,
				@bntIdent BIGINT

		DECLARE entity_cursor CURSOR FOR
		SELECT
			Ident,
			ReferenceIdent
		FROM
			@tblEntityFilter

		OPEN entity_cursor

		FETCH NEXT FROM entity_cursor
		INTO @bntIdent, @bntReferenceIdent

		WHILE @@FETCH_STATUS = 0
		BEGIN

			-- first insert is for when the project isnt assigned to all in network resources
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
				dbo.ufnGetEntityProjectParticipants(0, @bntReferenceIdent) EPP
					ON EPP.EntityIdent = tE.EntityIdent

			FETCH NEXT FROM entity_cursor
			INTO @bntIdent, @bntReferenceIdent

		END
		
		CLOSE entity_cursor
		DEALLOCATE entity_cursor

		RETURN

	END
	
GO
