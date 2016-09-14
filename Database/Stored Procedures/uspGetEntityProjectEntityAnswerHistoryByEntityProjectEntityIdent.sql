IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityProjectEntityAnswerHistoryByEntityProjectEntityIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityProjectEntityAnswerHistoryByEntityProjectEntityIdent
GO

/* uspGetEntityProjectEntityAnswerHistoryByEntityProjectEntityIdent 
 *
 *
 *
 *
*/
CREATE PROCEDURE uspGetEntityProjectEntityAnswerHistoryByEntityProjectEntityIdent

	@bntEntityProjectIdent BIGINT,
	@bntEntityIdent BIGINT,
	@bntEntityProjectRequirementIdent BIGINT,
	@bntASUserIdent BIGINT,
	@dteStartDate DATETIME,
	@dteEndDate DATETIME,
	@intPageNumber INT,
	@bntResultsShown BIGINT

AS

	SET NOCOUNT ON

	IF (@dteEndDate <> '1/1/1900')
		BEGIN
			SET @dteEndDate = DATEADD(hh, 23, @dteEndDate)
			SET @dteEndDate = DATEADD(mi, 59, @dteEndDate)
			SET @dteEndDate = DATEADD(ss, 59, @dteEndDate)
		END

	-- paged data
	SELECT
		EPE.Ident as [EntityProjectEntityIdent],
		E.Ident as [EntityIdent],
		E.FullName as [Entity],
		E.ProfilePhoto as [EntityProfilePhoto],
		EPR.Ident as [QuestionIdent],
		EPR.label as [Question],
		CASE VH.Name1
			WHEN '' THEN VH.Value1
			ELSE VH.Name1 + ': ' + VH.Value1
		END as [Answer],
		VH.AddDateTime as [AnswerDateTime],
		U.Ident as [AnswerEntityIdent],
		U.FullName as [AnswerUser],
		U.ProfilePhoto as [AnswerEntityProfilePhoto],
		VH.EntityProjectEntityAnswerIdent as [AnswerIdent]
	FROM
		EntityProject EP WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityProjectIdent = EP.Ident
		INNER JOIN
		EntityProjectEntityAnswer A WITH (NOLOCK)
			ON A.EntityProjectEntityIdent = EPE.Ident
		INNER JOIN
		EntityProjectEntityAnswerValueHistory VH WITH (NOLOCK)
			ON VH.EntityProjectEntityAnswerIdent = A.Ident
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = EPE.EntityIdent
		INNER JOIN
		Entity U WITH (NOLOCK)
			ON U.Ident = VH.AddASUserIdent
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.Ident = A.EntityProjectRequirementIdent
		INNER JOIN
		RequirementType RT WITH (NOLOCK)
			ON RT.Ident = EPR.RequirementTypeIdent
	WHERE
		EP.Ident = @bntEntityProjectIdent
		AND (EP.EntityIdent = @bntASUserIdent OR @bntASUserIdent = @bntEntityIdent) -- make sure they are trying to access the wrong project
		AND (EPE.EntityIdent = @bntEntityIdent OR @bntEntityIdent = 0)
		AND EPR.Active = 1
		AND (EPR.Ident = @bntEntityProjectRequirementIdent OR @bntEntityProjectRequirementIdent = 0)
		AND (VH.AddDateTime >= @dteStartDate OR @dteStartDate = '1/1/1900')
		AND (VH.AddDateTime <= @dteEndDate OR @dteEndDate = '1/1/1900')
		AND (VH.Name1 IN ('', 'FileName') OR RT.IsFileUpload = 0) -- if a file upload, only show the file name
	ORDER BY
		E.FullName,
		EPR.SortOrder ASC,
		VH.AddDateTime DESC
	OFFSET (@bntResultsShown * (@intPageNumber - 1)) ROWS
	FETCH NEXT @bntResultsShown ROWS ONLY;

	-- result counts
	SELECT
		COUNT(VH.Ident) as [TotalResults],
		@bntResultsShown as [ResultsShown]
	FROM
		EntityProject EP WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityProjectIdent = EP.Ident
		INNER JOIN
		EntityProjectEntityAnswer A WITH (NOLOCK)
			ON A.EntityProjectEntityIdent = EPE.Ident
		INNER JOIN
		EntityProjectEntityAnswerValueHistory VH WITH (NOLOCK)
			ON VH.EntityProjectEntityAnswerIdent = A.Ident
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.Ident = A.EntityProjectRequirementIdent
		INNER JOIN
		RequirementType RT WITH (NOLOCK)
			ON RT.Ident = EPR.RequirementTypeIdent
	WHERE
		EP.Ident = @bntEntityProjectIdent
		AND (EP.EntityIdent = @bntASUserIdent OR @bntASUserIdent = @bntEntityIdent) -- make sure they are trying to access the wrong project
		AND (EPE.EntityIdent = @bntEntityIdent OR @bntEntityIdent = 0)
		AND EPR.Active = 1
		AND (EPR.Ident = @bntEntityProjectRequirementIdent OR @bntEntityProjectRequirementIdent = 0)
		AND (VH.AddDateTime >= @dteStartDate OR @dteStartDate = '1/1/1900')
		AND (VH.AddDateTime <= @dteEndDate OR @dteEndDate = '1/1/1900')
		AND (VH.Name1 IN ('', 'FileName') OR RT.IsFileUpload = 0) -- if a file upload, only show the file name

GO