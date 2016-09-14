IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspEditEntityProjectByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspEditEntityProjectByIdent
 GO
/* uspEditEntityProjectByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE uspEditEntityProjectByIdent

	@bntIdent BIGINT,
	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT,
	@nvrName1 NVARCHAR(MAX),
	@sdtDueDate SMALLDATETIME = NULL,
	@bitPrivateProject BIT,
	@bntProjectManagerEntityIdent BIGINT,
	@bitShowOnProfile BIT,
	@bitIncludeEntireNetwork BIT,
	@bitAllowOpenRegistration BIT

AS

	SET NOCOUNT ON

	UPDATE 
		EntityProject
	SET
		Name1 = @nvrName1,
		DueDate = @sdtDueDate,
		PrivateProject = @bitPrivateProject,
		ProjectManagerEntityIdent = @bntProjectManagerEntityIdent,
		EditASUserIdent = @bntASUserIdent,
		EditDateTime = dbo.ufnGetMyDate(),
		ShowOnProfile = @bitShowOnProfile,
		IncludeEntireNetwork = @bitIncludeEntireNetwork,
		AllowOpenRegistration = @bitAllowOpenRegistration
	WHERE
		Ident = @bntIdent
		AND EntityIdent = @bntEntityIdent -- ensure the user cannot edit someone elses record

	SELECT @bntIdent as [Ident]

GO