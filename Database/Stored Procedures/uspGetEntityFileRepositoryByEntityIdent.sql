IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityFileRepositoryByEntityIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityFileRepositoryByEntityIdent
GO

/* uspGetEntityFileRepositoryByEntityIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE uspGetEntityFileRepositoryByEntityIdent

	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT

AS

	SET NOCOUNT ON

	DECLARE @nvrDefaultIcon NVARCHAR(250)

	SET @nvrDefaultIcon = 'fa fa-file-o'

	CREATE TABLE #tmpFiles(
		EntityIdent BIGINT,
		AnswerIdent BIGINT,
		ProjectIdent BIGINT,
		ProjectName NVARCHAR(MAX),
		[FileName] NVARCHAR(MAX),
		FileSize NVARCHAR(100),
		MimeType NVARCHAR(250),
		IconClass NVARCHAR(100),
		AddDateTime NVARCHAR(50),
		Deleted BIT
	)

	INSERT INTO #tmpFiles(
		EntityIdent,
		AnswerIdent,
		ProjectIdent,
		ProjectName,
		[FileName],
		FileSize,
		MimeType,
		IconClass,
		AddDateTime,
		Deleted
	)
	SELECT
		EFP.EntityIdent,
		EFP.AnswerIdent,
		EFP.ProjectIdent,
		EFP.ProjectName,
		EFP.[FileName],
		dbo.ufnCalculateFileSize(EFP.FileSize),
		EFP.MimeType,
		@nvrDefaultIcon,
		CONVERT(NVARCHAR(50),EFP.AddDateTime,100),
		0
	FROM
		EntityFileRepository EFP WITH (NOLOCK)
	WHERE
		EFP.EntityIdent = @bntEntityIdent 
		AND EFP.EntityIdent = @bntASUserIdent -- ensure the user has access to this file
		AND EFP.PrivateProject = 0 -- make sure the user can see the file
	-- determine if the record was deleted. Since this is a view
	-- and we dont want to delete the actual answer, we need a logging
	-- table that shows which records have been deleted by the user
	UNION
	SELECT
		EFP.EntityIdent,
		EFP.AnswerIdent,
		EFP.ProjectIdent,
		EFP.ProjectName,
		EFP.[FileName],
		dbo.ufnCalculateFileSize(EFP.FileSize),
		EFP.MimeType,
		@nvrDefaultIcon,
		CONVERT(NVARCHAR(50),EFP.AddDateTime,100),
		0
	FROM
		EntityFileRepository EFP WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntityAnswer A WITH (NOLOCK)
			ON A.Ident = EFP.AnswerIdent
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.Ident = A.EntityProjectEntityIdent
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = EPE.EntityProjectIdent
	WHERE
		EFP.EntityIdent = @bntEntityIdent 
		AND EP.EntityIdent = @bntASUserIdent -- ensure the user has access to this file

	-- override the default icon if the mime type has one listed
	UPDATE
		tF
	SET
		IconClass = MT.IconClass
	FROM
		#tmpFiles tF WITH (NOLOCK)
		INNER JOIN
		MimeType MT WITH (NOLOCK)
			ON MT.Name1 = tF.MimeType

	-- mark the file as deleted if necessary
	UPDATE
		tF
	SET
		Deleted = 1
	FROM
		#tmpFiles tF WITH (NOLOCK)
		INNER JOIN
		EntityFileRepositoryArchive EFRA WITH (NOLOCK)
			ON EFRA.EntityFileRepositoryAnswerIdent = tF.AnswerIdent

	SELECT
		EntityIdent,
		AnswerIdent,
		ProjectIdent,
		ProjectName,
		[FileName],
		FileSize,
		MimeType,
		IconClass,
		AddDateTime
	FROM
		#tmpFiles WITH (NOLOCK)
	WHERE
		Deleted = 0
	ORDER BY
		ProjectName ASC,
		[FileName] ASC

	DROP TABLE #tmpFiles

GO