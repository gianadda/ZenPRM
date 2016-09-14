
DROP TRIGGER trg_EntityFileRepositoryArchiveASUserActivityLog
GO 
CREATE TRIGGER trg_EntityFileRepositoryArchiveASUserActivityLog ON EntityFileRepositoryArchive FOR INSERT
AS

-- we need to make sure something is actually edited
-- this will be null if we have a UPDATE with a WHERE clause that doesnt trigger an update
IF EXISTS(SELECT * FROM inserted)
BEGIN

	DECLARE @intActivityTypeDeleteEntityFileRespository BIGINT
	DECLARE @intRecordIdent BIGINT
	DECLARE @intEntityIdent BIGINT
	DECLARE @intDeleteASUserIdent BIGINT
	DECLARE @intGenderIdent BIGINT
	DECLARE @intEntityFileRepositoryAnswerIdent BIGINT
	DECLARE @nvrUserFullname NVARCHAR(MAX)
	DECLARE @nvrEntityFullname NVARCHAR(MAX)
	DECLARE @nvrFilename NVARCHAR(MAX)
	DECLARE @dteGetDate DATETIME

	SET @dteGetDate = dbo.ufnGetMyDate()

	SET @intActivityTypeDeleteEntityFileRespository = dbo.ufnActivityTypeDeleteEntityFileRespository()

	SELECT 
		@intRecordIdent = Ident,
		@intEntityIdent = EntityIdent ,
		@intEntityFileRepositoryAnswerIdent = EntityFileRepositoryAnswerIdent,
		@intDeleteASUserIdent = DeleteASUserIdent
	FROM
		inserted

	SELECT
		@nvrEntityFullname = E.Fullname
	FROM
		Entity E WITH (NOLOCK)
		INNER JOIN
		inserted i WITH (NOLOCK)
			on I.EntityIdent = E.Ident

	SELECT
		@nvrFilename = [FileName]
	FROM
		EntityFileRepository WITH (NOLOCK)
	WHERE
		AnswerIdent = @intEntityFileRepositoryAnswerIdent

	-- assume user is editing, well override add in the next clause if need be
	SELECT
		@nvrUserFullname = E.Fullname,
		@intGenderIdent = E.GenderIdent
	FROM
		Entity E WITH (NOLOCK)
	WHERE
		@intDeleteASUserIdent > 0
		AND E.Ident = @intDeleteASUserIdent


	INSERT INTO ASUserActivity(
		ASUserIdent,
		ActivityTypeIdent,
		ActivityDateTime,
		ActivityDescription,
		ClientIPAddress,
		RecordIdent,
		CustomerEntityIdent,
		UpdatedEntityIdent
	)
	SELECT
		ASUserIdent = @intDeleteASUserIdent,
		ActivityTypeIdent = AT.Ident,
		ActivityDateTime = @dteGetDate,
		ActivityDescription = CASE
								--0	N/A
								--1	Male
								--2	Female
								WHEN @intDeleteASUserIdent = @intEntityIdent AND @intGenderIdent = 0 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','their'),'@@Filename',@nvrFilename)
								WHEN @intDeleteASUserIdent = @intEntityIdent AND @intGenderIdent = 1 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','his'),'@@Filename',@nvrFilename)
								WHEN @intDeleteASUserIdent = @intEntityIdent AND @intGenderIdent = 2 THEN REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity','her'),'@@Filename',@nvrFilename)
								ELSE REPLACE(REPLACE(REPLACE(AT.Desc1,'@@Name',@nvrUserFullname),'@@Entity',@nvrEntityFullname + '''s'),'@@Filename',@nvrFilename)
								END,
		ClientIPAddress = '', -- unobtainable at this point
		RecordIdent = @intRecordIdent,
		CustomerEntityIdent = 0,
		UpdatedEntityIdent = @intEntityIdent
	FROM
		ActivityType AT WITH (NOLOCK)
	WHERE
		AT.Ident = @intActivityTypeDeleteEntityFileRespository

END

GO

