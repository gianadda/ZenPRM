IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspMergeResourcesProjectData') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspMergeResourcesProjectData
GO
/********************************************************													
 *
 *	uspMergeResourcesProjectData 
 *
 ********************************************************/
 
CREATE PROCEDURE uspMergeResourcesProjectData

	@bntFromEntityIdent BIGINT,
	@bntToEntityIdent BIGINT,
	@bntASUserIdent BIGINT,
	@bntEditASUserIdent BIGINT

AS

	-- cursor resources
	DECLARE @bntEntityProjectIdent BIGINT

	-- nested cursor resources
	DECLARE @bntEntityProjectRequirementIdent BIGINT,
	@nvrName1 NVARCHAR(MAX),
	@nvrValue1 NVARCHAR(MAX),
	@dteAnswerDate DATETIME


	CREATE TABLE #tmpEntityProject(
		EntityProjectIdent BIGINT
	)

	
	CREATE TABLE #tmpAnswerValue(
		EntityIdent BIGINT,
		EntityProjectRequirementIdent BIGINT,
		Name1 NVARCHAR(MAX),
		Value1 NVARCHAR(MAX),
		AnswerDate DATETIME
	)

	-- go get the project list for the merging entity
	INSERT INTO #tmpEntityProject(
		EntityProjectIdent
	)
	SELECT
		EPE.EntityProjectIdent
	FROM
		EntityProjectEntity EPE	WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = EPE.EntityProjectIdent
	WHERE
		EPE.EntityIdent = @bntFromEntityIdent
		AND EPE.Active = 1
		AND EP.Active = 1
	
	-- loop through each project
	DECLARE merge_cursor CURSOR FOR

		SELECT
			EntityProjectIdent
		FROM
			#tmpEntityProject

		OPEN merge_cursor

		FETCH NEXT FROM merge_cursor
		INTO @bntEntityProjectIdent

		WHILE @@FETCH_STATUS = 0
		BEGIN

			-- start with a fresh list
			DELETE #tmpAnswerValue

			-- get all the merging resources' answers on this project
			INSERT INTO #tmpAnswerValue(
				EntityIdent,
				EntityProjectRequirementIdent,
				Name1,
				Value1,
				AnswerDate
			)
			SELECT
				EntityIdent = EPE.EntityIdent,
				EntityProjectRequirementIdent = A.EntityProjectRequirementIdent,
				Name1 = V.Name1,
				Value1 = V.Value1,
				AnswerDate = A.AddDateTime
			FROM
				EntityProjectEntityAnswerValue V WITH (NOLOCK)
				INNER JOIN
				EntityProjectEntityAnswer A WITH (NOLOCK)
					ON A.Ident = V.EntityProjectEntityAnswerIdent
				INNER JOIN
				EntityProjectEntity EPE WITH (NOLOCK)
					ON EPE.Ident = A.EntityProjectEntityIdent
			WHERE
				EPE.EntityProjectIdent = @bntEntityProjectIdent
				AND EPE.EntityIdent = @bntFromEntityIdent
				AND EPE.Active = 1
				AND V.Active = 1
				AND A.Active = 1

			-- get all the destination resources' answers on this project
			INSERT INTO #tmpAnswerValue(
				EntityIdent,
				EntityProjectRequirementIdent,
				Name1,
				Value1,
				AnswerDate
			)
			SELECT
				EntityIdent = EPE.EntityIdent,
				EntityProjectRequirementIdent = A.EntityProjectRequirementIdent,
				Name1 = V.Name1,
				Value1 = V.Value1,
				AnswerDate = A.AddDateTime
			FROM
				EntityProjectEntityAnswerValue V WITH (NOLOCK)
				INNER JOIN
				EntityProjectEntityAnswer A WITH (NOLOCK)
					ON A.Ident = V.EntityProjectEntityAnswerIdent
				INNER JOIN
				EntityProjectEntity EPE WITH (NOLOCK)
					ON EPE.Ident = A.EntityProjectEntityIdent
			WHERE
				EPE.EntityProjectIdent = @bntEntityProjectIdent
				AND EPE.EntityIdent = @bntToEntityIdent
				AND EPE.Active = 1
				AND V.Active = 1
				AND A.Active = 1

			-- get a distinct question list for this project
			-- we'll loop through and "answer" each question for the resource
			DECLARE question_cursor CURSOR FOR

				SELECT DISTINCT
					EntityProjectRequirementIdent,
					Name1
				FROM
					#tmpAnswerValue WITH (NOLOCK)

				OPEN question_cursor

				FETCH NEXT FROM question_cursor
				INTO @bntEntityProjectRequirementIdent,@nvrName1

				WHILE @@FETCH_STATUS = 0
				BEGIN

					-- find the most recent version of this question
					SELECT
						@dteAnswerDate = MAX(AnswerDate)
					FROM
						#tmpAnswerValue WITH (NOLOCK)
					WHERE
						EntityProjectRequirementIdent = @bntEntityProjectRequirementIdent
						AND Name1 = @nvrName1

					-- and get the associated answers
					SELECT
						@nvrValue1 = Value1
					FROM
						#tmpAnswerValue WITH (NOLOCK)
					WHERE
						EntityProjectRequirementIdent = @bntEntityProjectRequirementIdent
						AND Name1 = @nvrName1
						AND AnswerDate = @dteAnswerDate

					-- select @bntEntityProjectRequirementIdent, @nvrName1, @nvrValue1

					-- we'll "save" the question for the new entity with this value
					EXEC uspSaveEntityProjectEntityAnswerValue @intEntityProjectRequirementIdent = @bntEntityProjectRequirementIdent,
																@intEntityIdent = @bntToEntityIdent,
																@vcrName1 = @nvrName1,
																@nvrValue1 = @nvrValue1,
																@intASUserIdent = @bntEditASUserIdent,
																@bitSuppressOutput = 1,
																@bitAllowOptionAdd = 0

					FETCH NEXT FROM question_cursor
					INTO @bntEntityProjectRequirementIdent,@nvrName1

				END -- end nested cursor
		
			CLOSE question_cursor
			DEALLOCATE question_cursor
			
			FETCH NEXT FROM merge_cursor
			INTO @bntEntityProjectIdent

		END -- end cursor
		
		CLOSE merge_cursor
		DEALLOCATE merge_cursor
	
	-- now that the merge is complete, make sure the entity project entity audit history is copied over as well
	INSERT INTO EntityProjectEntityAnswerValueHistory(
		EntityProjectEntityAnswerValueIdent,
		EntityProjectEntityAnswerIdent,
		Name1,
		Value1,
		Active,
		AddDateTime,
		AddASUserIdent
	)
	SELECT
		EntityProjectEntityAnswerValueIdent,
		EntityProjectEntityAnswerIdent = newA.Ident,
		Name1 = oldHis.Name1,
		Value1 = oldHis.Value1,
		Active = oldHis.Active,
		AddDateTime = oldHis.AddDateTime,
		AddASUserIdent = oldHis.AddASUserIdent
	FROM
		#tmpEntityProject tEP WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON tEP.EntityProjectIdent = EP.Ident
		INNER JOIN
		EntityProjectEntity oldEPE WITH (NOLOCK)
			ON oldEPE.EntityProjectIdent = EP.Ident
			AND oldEPE.EntityIdent = @bntFromEntityIdent
			AND oldEPE.Active = 1
		INNER JOIN
		EntityProjectEntityAnswer oldA WITH (NOLOCK)
			ON oldA.EntityProjectEntityIdent = oldEPE.Ident
			AND oldA.Active = 1
		INNER JOIN
		EntityProjectEntityAnswerValueHistory oldHis WITH (NOLOCK)
			ON oldHis.EntityProjectEntityAnswerIdent = oldA.Ident
				INNER JOIN
		EntityProjectEntityAnswerValue oldV WITH (NOLOCK)
			ON oldV.Ident = oldHis.EntityProjectEntityAnswerValueIdent
		INNER JOIN
		EntityProjectEntity newEPE WITH (NOLOCK)
			ON newEPE.EntityProjectIdent = EP.Ident
			AND newEPE.EntityIdent = @bntToEntityIdent
			AND newEPE.Active = 1
		INNER JOIN
		EntityProjectEntityAnswer newA WITH (NOLOCK)
			ON newA.EntityProjectEntityIdent = newEPE.Ident
			AND newA.EntityProjectRequirementIdent = oldA.EntityProjectRequirementIdent
			AND newA.Active = 1
		INNER JOIN
		EntityProjectEntityAnswerValue newV WITH (NOLOCK)
			ON newV.EntityProjectEntityAnswerIdent = newA.Ident
			AND newV.Name1 = oldV.Name1
			AND newV.Active = 1

	DROP TABLE #tmpEntityProject
	DROP TABLE #tmpAnswerValue

GO