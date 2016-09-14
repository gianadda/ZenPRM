IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnEntitySearchProjectSpecificDidNotAnswer') 
	AND OBJECTPROPERTY(id, N'IsTableFunction') = 1)
DROP FUNCTION ufnEntitySearchProjectSpecificDidNotAnswer
GO

/* ufnEntitySearchProjectSpecificDidNotAnswer
 *
 * Advanced Search, with filters, using cross apply to see which users didnt answer the question
 *
 *
*/
CREATE FUNCTION ufnEntitySearchProjectSpecificDidNotAnswer(@tblEntity AS [EntitySearchTable] READONLY, @tblEntityFilter AS [EntitySearchFilterTable] READONLY)
RETURNS @tblResults TABLE
	(
		EntityIdent BIGINT,
		tmpSearchFiltersIdent BIGINT,
		MatchCount INTEGER
	)
AS

	BEGIN
	
		DECLARE @bntEntityProjectRequirementIdent BIGINT,
				@bntReferenceIdent BIGINT,
				@bntIdent BIGINT

		DECLARE entity_cursor CURSOR FOR
		SELECT
			Ident,
			EntityProjectRequirementIdent,
			ReferenceIdent
		FROM
			@tblEntityFilter

		OPEN entity_cursor

		FETCH NEXT FROM entity_cursor
		INTO @bntIdent, @bntEntityProjectRequirementIdent, @bntReferenceIdent
		
		WHILE @@FETCH_STATUS = 0
		BEGIN

			 -- see if they are on the project, but have not answered.
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
				INNER JOIN
				EntityProjectRequirement EPR WITH (NOLOCK)
					ON EPR.EntityProjectIdent = EPP.EntityProjectIdent
					AND EPR.Ident = @bntEntityProjectRequirementIdent
				OUTER APPLY -- essentially, look any active answers for the question, 
			   ( 
				SELECT 
					Ident
				FROM 
					EntityProjectEntityAnswer EPEA WITH (NOLOCK)
				WHERE 
					EPEA.EntityProjectEntityIdent = EPP.Ident
					AND EPEA.EntityProjectRequirementIdent = EPR.Ident
					AND EPEA.Active = 1
			   ) A 
			WHERE
				COALESCE(A.Ident,0) = 0 -- and only return records where the outer apply returns NULL

			FETCH NEXT FROM entity_cursor
			INTO @bntIdent, @bntEntityProjectRequirementIdent, @bntReferenceIdent

		END

		CLOSE entity_cursor
		DEALLOCATE entity_cursor

		RETURN

	END
	
GO
