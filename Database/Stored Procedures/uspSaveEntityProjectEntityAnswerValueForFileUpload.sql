IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspSaveEntityProjectEntityAnswerValueForFileUpload') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspSaveEntityProjectEntityAnswerValueForFileUpload
 GO
/* uspSaveEntityProjectEntityAnswerValueForFileUpload
 *
 * Save the EntityProjectEntityAnswerValue records anytime a new file is uploaded
 *
 *
*/
CREATE PROCEDURE uspSaveEntityProjectEntityAnswerValueForFileUpload

	@intEntityProjectRequirementIdent BIGINT = 0, 
	@intEntityIdent BIGINT = 0, 
	@intASUserIdent BIGINT = 0,
	@vcrFileName VARCHAR(MAX) = '', 
	@vcrFileSize NVARCHAR(MAX) = '',
	@vcrMimeType NVARCHAR(MAX) = '',
	@vcrFileKey NVARCHAR(MAX) = ''
	
AS

	SET NOCOUNT ON

	/*
		1. Check and see if there is a EntityProjectEntity Record (for private profile) and if not, add it
		1a. Get the EntityProjectEntityIdent
		1b. Remove any existing EntityProjectEntityAnswer
		3. Insert new EntityProjectEntityAnswerValue with the provided values (input params)
		4. Return that Answer Ident

	*/

	DECLARE @intEntityProjectEntityAnswerIdent AS BIGINT
	DECLARE @intEntityProjectEntityIdent AS BIGINT
	DECLARE @sdtGetDate AS SMALLDATETIME

	SET @intEntityProjectEntityAnswerIdent = 0
	SET @intEntityProjectEntityIdent = 0
	SET @sdtGetDate = dbo.ufnGetMyDate()

	SELECT 
		@intEntityProjectEntityIdent = EPE.Ident
	FROM
		EntityProjectRequirement EPR WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EPR.EntityProjectIdent = EP.Ident
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityProjectIdent = EP.Ident
	WHERE 
		EPR.Ident = @intEntityProjectRequirementIdent
		AND EPE.EntityIdent = @intEntityIdent
		AND EPE.Active = 1

	INSERT INTO EntityProjectEntity (
		EntityProjectIdent,
		EntityIdent,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT 
		EntityProjectIdent = EP.Ident,
		EntityIdent = @intEntityIdent,
		AddASUserIdent = @intASUserIdent,
		AddDateTime = @sdtGetDate,
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1
	FROM
		EntityProjectRequirement EPR WITH (NOLOCK)
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EPR.EntityProjectIdent = EP.Ident
	WHERE 
		EPR.Ident = @intEntityProjectRequirementIdent
		AND @intEntityProjectEntityIdent = 0

	SELECT 
		@intEntityProjectEntityIdent = SCOPE_IDENTITY()
	WHERE 
		@intEntityProjectEntityIdent = 0

	--clear out this answer value, well add a new one so the document ident is unique
	UPDATE EntityProjectEntityAnswer
	SET 
		Active = 0,
		EditASUserIdent = @intASUserIdent,
		EditDateTime =  @sdtGetDate
	WHERE 
		@intEntityProjectEntityIdent <> 0
		AND EntityProjectRequirementIdent = @intEntityProjectRequirementIdent
		AND EntityProjectEntityIdent = @intEntityProjectEntityIdent
		AND Active = 1
		
	--Add in the new answer record
	INSERT INTO EntityProjectEntityAnswer (
		EntityProjectEntityIdent,
		EntityProjectRequirementIdent,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active,
		ToDoGenerated,
		ToDoGeneratedDateTime
	)
	SELECT 
		EntityProjectEntityIdent = @intEntityProjectEntityIdent,
		EntityProjectRequirementIdent = @intEntityProjectRequirementIdent,
		AddASUserIdent = @intASUserIdent,
		AddDateTime = @sdtGetDate, 
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900', 
		Active = 1,
		ToDoGenerated = 0,
		ToDoGeneratedDateTime = '1/1/1900'

	SET @intEntityProjectEntityAnswerIdent = SCOPE_IDENTITY()

	-- add the new file name
	INSERT INTO EntityProjectEntityAnswerValue(
		EntityProjectEntityAnswerIdent,
		Name1,
		Value1,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT
		EntityProjectEntityAnswerIdent = @intEntityProjectEntityAnswerIdent,
		Name1 = 'FileName',
		Value1 = @vcrFileName,
		AddASUserIdent = @intASUserIdent,
		AddDateTime = @sdtGetDate, 
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900', 
		Active = 1

	-- add the new file size
	INSERT INTO EntityProjectEntityAnswerValue(
		EntityProjectEntityAnswerIdent,
		Name1,
		Value1,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT
		EntityProjectEntityAnswerIdent = @intEntityProjectEntityAnswerIdent,
		Name1 = 'FileSize',
		Value1 = @vcrFileSize,
		AddASUserIdent = @intASUserIdent,
		AddDateTime = @sdtGetDate, 
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900', 
		Active = 1

	-- add the new Mime Type
	INSERT INTO EntityProjectEntityAnswerValue(
		EntityProjectEntityAnswerIdent,
		Name1,
		Value1,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT
		EntityProjectEntityAnswerIdent = @intEntityProjectEntityAnswerIdent,
		Name1 = 'MimeType',
		Value1 = @vcrMimeType,
		AddASUserIdent = @intASUserIdent,
		AddDateTime = @sdtGetDate, 
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900', 
		Active = 1

	-- add the new File Key
	INSERT INTO EntityProjectEntityAnswerValue(
		EntityProjectEntityAnswerIdent,
		Name1,
		Value1,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT
		EntityProjectEntityAnswerIdent = @intEntityProjectEntityAnswerIdent,
		Name1 = 'FileKey',
		Value1 = @vcrFileKey,
		AddASUserIdent = @intASUserIdent,
		AddDateTime = @sdtGetDate, 
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900', 
		Active = 1

	SELECT @intEntityProjectEntityAnswerIdent AS [Ident]

GO