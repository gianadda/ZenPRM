IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetEntityProjectRequirementAnswerByIdent') 
	AND OBJECTPROPERTY(id, N'IsTableFunction') = 1)
DROP FUNCTION ufnGetEntityProjectRequirementAnswerByIdent
GO

/* ufnGetEntityProjectRequirementAnswerByIdent
 *
 *  Gets the list of answers for a given entity Project Requirement Ident
 *
 *
*/
CREATE FUNCTION ufnGetEntityProjectRequirementAnswerByIdent(@bntEntityProjectIdent AS BIGINT, @bntEntityProjectRequirementIdent BIGINT)
RETURNS @tblResults TABLE
	(
		EntityIdent BIGINT,
		EntityProjectEntityIdent BIGINT,
		EntityProjectRequirementIdent BIGINT,
		EntityProjectEntityAnswerIdent BIGINT,
		Answered BIT,
		AnswerValue NVARCHAR(MAX)
	)
AS

	BEGIN

		INSERT INTO @tblResults(
			EntityIdent,
			EntityProjectEntityIdent,
			EntityProjectRequirementIdent,
			EntityProjectEntityAnswerIdent,
			Answered,
			AnswerValue
		)
		SELECT
			EntityIdent = EPP.EntityIdent,
			EntityProjectEntityIdent = EPP.Ident,
			EntityProjectRequirementIdent = @bntEntityProjectRequirementIdent,
			EntityProjectEntityAnswerIdent = 0,
			Answered = 0,
			AnswerValue = ''
		FROM
			dbo.ufnGetEntityProjectParticipants(0, @bntEntityProjectIdent) EPP

		-- handle all the basic data types first. we'll get the remaining ones later
		UPDATE
			tR
		SET
			EntityProjectEntityAnswerIdent = EPEA.Ident,
			Answered = 1,
			AnswerValue = CASE WHEN ISDATE(EPEAV.Value1) = 1 THEN CONVERT(VARCHAR(MAX),EPEAV.Value1, 101) ELSE CONVERT(VARCHAR(MAX),EPEAV.Value1) END
		FROM
			@tblResults tR
			INNER JOIN
			EntityProjectEntityAnswer EPEA WITH (NOLOCK)
				ON EPEA.EntityProjectEntityIdent = tR.EntityProjectEntityIdent
				AND EPEA.EntityProjectRequirementIdent = @bntEntityProjectRequirementIdent
			INNER JOIN
			EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
				ON EPEAV.EntityProjectEntityAnswerIdent = EPEA.Ident
			INNER JOIN
			EntityProjectRequirement EPR WITH (NOLOCK)
				ON EPR.Ident = @bntEntityProjectRequirementIdent
			INNER JOIN
			RequirementType RT WITH (NOLOCK)
				ON RT.Ident = EPR.RequirementTypeIdent
		WHERE
			EPEA.Active = 1
			AND EPEAV.Active = 1
			AND RT.AllowMultipleOptions = 0
			AND RT.IsFileUpload = 0

			-- only show the file name on for File Upload questions
		UPDATE
			tR
		SET
			EntityProjectEntityAnswerIdent = EPEA.Ident,
			Answered = 1,
			AnswerValue = EPEAV.Value1
		FROM
			@tblResults tR
			INNER JOIN
			EntityProjectEntityAnswer EPEA WITH (NOLOCK)
				ON EPEA.EntityProjectEntityIdent = tR.EntityProjectEntityIdent
				AND EPEA.EntityProjectRequirementIdent = @bntEntityProjectRequirementIdent
			INNER JOIN
			EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
				ON EPEAV.EntityProjectEntityAnswerIdent = EPEA.Ident
			INNER JOIN
			EntityProjectRequirement EPR WITH (NOLOCK)
				ON EPR.Ident = @bntEntityProjectRequirementIdent
			INNER JOIN
			RequirementType RT WITH (NOLOCK)
				ON RT.Ident = EPR.RequirementTypeIdent
		WHERE
			EPEA.Active = 1
			AND EPEAV.Active = 1
			AND RT.IsFileUpload = 1
			AND EPEAV.Name1 = 'FileName'

		--For option Lists & tags
		UPDATE
			tR
		SET
			EntityProjectEntityAnswerIdent = EPEA.Ident,
			Answered = 1,
			AnswerValue = STUFF((
									SELECT 
										'; ' + CASE EPEAV.Name1 WHEN '' THEN EPEAV.Value1 ELSE EPEAV.Name1 END + ''
									FROM
										@tblResults tRi
										INNER JOIN
										EntityProjectEntityAnswer EPEAi WITH (NOLOCK)
											ON EPEAi.EntityProjectEntityIdent = tR.EntityProjectEntityIdent
											AND EPEAi.EntityProjectRequirementIdent = @bntEntityProjectRequirementIdent
										INNER JOIN
										EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
											ON EPEAV.EntityProjectEntityAnswerIdent = EPEAi.Ident
										INNER JOIN
										EntityProjectRequirement EPRi WITH (NOLOCK)
											ON EPRi.Ident = @bntEntityProjectRequirementIdent
										INNER JOIN
										RequirementType RT WITH (NOLOCK)
											ON RT.Ident = EPRi.RequirementTypeIdent
									WHERE 
										tRi.EntityProjectEntityIdent = tR.EntityProjectEntityIdent
										AND RT.AllowMultipleOptions = 1
										AND EPEAi.Active = 1
										AND EPEAV.Active = 1
										AND (UPPER(EPEAV.Value1) = 'TRUE' OR EPEAV.Name1 = '')
									GROUP BY
										EPEAV.Name1,
										EPEAV.Value1
									ORDER BY
										EPEAV.Name1 ASC
								for xml path(''), type
							).value('.', 'varchar(max)'), 1, 1, '')  
			FROM
				@tblResults tR
				INNER JOIN
				EntityProjectEntityAnswer EPEA WITH (NOLOCK)
					ON EPEA.EntityProjectEntityIdent = tR.EntityProjectEntityIdent
					AND EPEA.EntityProjectRequirementIdent = @bntEntityProjectRequirementIdent
				INNER JOIN
				EntityProjectRequirement EPR WITH (NOLOCK)
					ON EPR.Ident = @bntEntityProjectRequirementIdent
				INNER JOIN
				RequirementType RT WITH (NOLOCK)
					ON RT.Ident = EPR.RequirementTypeIdent
			WHERE
				EPEA.Active = 1
				AND RT.AllowMultipleOptions = 1

		--Address stuff for Ident 12
		UPDATE
			tR
		SET
			EntityProjectEntityAnswerIdent = EPEA.Ident,
			Answered = 1,
			AnswerValue = STUFF((
									SELECT 
										'; ' + EPEAV.Name1 + ': ' + EPEAV.Value1 +''
									FROM
										@tblResults tRi
										INNER JOIN
										EntityProjectEntityAnswer EPEAi WITH (NOLOCK)
											ON EPEAi.EntityProjectEntityIdent = tR.EntityProjectEntityIdent
											AND EPEAi.EntityProjectRequirementIdent = @bntEntityProjectRequirementIdent
										INNER JOIN
										EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
											ON EPEAV.EntityProjectEntityAnswerIdent = EPEAi.Ident
										INNER JOIN
										EntityProjectRequirement EPRi WITH (NOLOCK)
											ON EPRi.Ident = @bntEntityProjectRequirementIdent
										INNER JOIN
										RequirementType RT WITH (NOLOCK)
											ON RT.Ident = EPRi.RequirementTypeIdent
									WHERE 
										tRi.EntityProjectEntityIdent = tR.EntityProjectEntityIdent
										AND EPRi.RequirementTypeIdent = 12
										AND EPEAi.Active = 1
										AND EPEAV.Active = 1
									GROUP BY
										EPEAV.Name1,
										EPEAV.Value1
									ORDER BY
										EPEAV.Name1 ASC
								for xml path(''), type
							).value('.', 'varchar(max)'), 1, 1, '')  
		FROM
			@tblResults tR
			INNER JOIN
			EntityProjectEntityAnswer EPEA WITH (NOLOCK)
				ON EPEA.EntityProjectEntityIdent = tR.EntityProjectEntityIdent
				AND EPEA.EntityProjectRequirementIdent = @bntEntityProjectRequirementIdent
			INNER JOIN
			EntityProjectRequirement EPR WITH (NOLOCK)
				ON EPR.Ident = @bntEntityProjectRequirementIdent
		WHERE
			EPR.RequirementTypeIdent = 12

		--Hours of operation Ident 18
		UPDATE
			tR
		SET
			EntityProjectEntityAnswerIdent = EPEA.Ident,
			Answered = 1,
			AnswerValue = dbo.ufnFormatHoursOfOperation(EPEA.Ident)
		FROM
			@tblResults tR
			INNER JOIN
			EntityProjectEntityAnswer EPEA WITH (NOLOCK)
				ON EPEA.EntityProjectEntityIdent = tR.EntityProjectEntityIdent
				AND EPEA.EntityProjectRequirementIdent = @bntEntityProjectRequirementIdent
			INNER JOIN
			EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
				ON EPEAV.EntityProjectEntityAnswerIdent = EPEA.Ident
			INNER JOIN
			EntityProjectRequirement EPR WITH (NOLOCK)
				ON EPR.Ident = @bntEntityProjectRequirementIdent
		WHERE
			EPR.RequirementTypeIdent = 18
			AND EPEA.Active = 1

		RETURN

	END
	
GO
