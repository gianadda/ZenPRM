IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityFileRepositoryArchive') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntityFileRepositoryArchive
 GO
/* uspAddEntityFileRepositoryArchive
 *
 *
 *
 *
*/
CREATE PROCEDURE uspAddEntityFileRepositoryArchive

	@bntEntityIdent BIGINT,
	@bntAnswerIdent BIGINT,
	@bntASUserIdent BIGINT

AS

	SET NOCOUNT ON

	INSERT INTO EntityFileRepositoryArchive(
		EntityIdent,
		EntityFileRepositoryAnswerIdent,
		DeleteASUserIdent,
		DeleteDateTime
	)
	SELECT
		EntityIdent = EPE.EntityIdent,
		EntityFileRepositoryAnswerIdent = EPEA.Ident,
		DeleteASUserIdent = @bntASUserIdent,
		DeleteDateTime = dbo.ufnGetMyDate()
	FROM
		EntityProjectEntityAnswer EPEA WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.Ident = EPEA.EntityProjectEntityIdent
	WHERE
		EPEA.Ident = @bntAnswerIdent
		AND EPE.EntityIdent = @bntEntityIdent
	UNION ALL
	SELECT
		EntityIdent = EPE.EntityIdent,
		EntityFileRepositoryAnswerIdent = EPEA.Ident,
		DeleteASUserIdent = @bntASUserIdent,
		DeleteDateTime = dbo.ufnGetMyDate()
	FROM
		EntityProjectEntityAnswer EPEA WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.Ident = EPEA.EntityProjectEntityIdent
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = EPE.EntityProjectIdent
	WHERE
		EPEA.Ident = @bntAnswerIdent
		AND EP.EntityIdent = @bntEntityIdent

	SELECT COALESCE(SCOPE_IDENTITY(),0) as [Ident]

GO