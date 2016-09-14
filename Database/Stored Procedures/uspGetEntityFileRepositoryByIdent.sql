IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityFileRepositoryByIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityFileRepositoryByIdent
GO

/* uspGetEntityFileRepositoryByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE uspGetEntityFileRepositoryByIdent

	@bntAnswerIdent BIGINT,
	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT

AS

	SET NOCOUNT ON
	
	SELECT
		EPR.EntityIdent,
		EPR.AnswerIdent,
		EPR.ProjectIdent,
		EPR.ProjectName,
		EPR.[FileName],
		EPR.MimeType,
		EPR.FileKey,
		dbo.ufnCalculateFileSize(EPR.FileSize) as [FileSize],
		CONVERT(NVARCHAR(50),EPR.AddDateTime,100) as [AddDateTime]
	FROM
		EntityFileRepository EPR WITH (NOLOCK)
	WHERE
		EPR.AnswerIdent = @bntAnswerIdent
		AND EPR.EntityIdent = @bntEntityIdent 
		AND EPR.EntityIdent = @bntASUserIdent -- ensure the user has access to this file
	UNION -- or ensuer that the user is the customer
	SELECT
		EPR.EntityIdent,
		EPR.AnswerIdent,
		EPR.ProjectIdent,
		EPR.ProjectName,
		EPR.[FileName],
		EPR.MimeType,
		EPR.FileKey,
		dbo.ufnCalculateFileSize(EPR.FileSize) as [FileSize],
		CONVERT(NVARCHAR(50),EPR.AddDateTime,100) as [AddDateTime]
	FROM
		EntityFileRepository EPR WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntityAnswer A WITH (NOLOCK)
			ON A.Ident = EPR.AnswerIdent
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.Ident = A.EntityProjectEntityIdent
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = EPE.EntityProjectIdent
	WHERE
		EPR.AnswerIdent = @bntAnswerIdent
		AND EPR.EntityIdent = @bntEntityIdent 
		AND EP.EntityIdent = @bntASUserIdent -- ensure the user has access to this file

GO