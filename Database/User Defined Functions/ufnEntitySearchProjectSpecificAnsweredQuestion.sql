IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnEntitySearchProjectSpecificAnsweredQuestion') 
	AND OBJECTPROPERTY(id, N'IsTableFunction') = 1)
DROP FUNCTION ufnEntitySearchProjectSpecificAnsweredQuestion
GO

/* ufnEntitySearchProjectSpecificAnsweredQuestion
 *
 * Advanced Search, with filters, to find which resources answered question
 *
 *
*/
CREATE FUNCTION ufnEntitySearchProjectSpecificAnsweredQuestion(@tblEntity AS [EntitySearchTable] READONLY, @tblEntityFilter AS [EntitySearchFilterTable] READONLY)
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
				@bntReferenceIdent BIGINT
				
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
				EPE.Active = 1
				AND EPEA.Active = 1
				AND EPEAV.Active = 1
			GROUP BY
				tE.EntityIdent,
				EP.Name1,
				EPR.Label

			FETCH NEXT FROM entity_cursor
			INTO @bntIdent, @bntEntityProjectRequirementIdent, @bntReferenceIdent

		END
		
		CLOSE entity_cursor
		DEALLOCATE entity_cursor

		RETURN

	END
	
GO
