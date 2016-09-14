IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetMimeTypeByExtension') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetMimeTypeByExtension
 GO
/* uspGetMimeTypeByExtension '.zip'
 *
 *
 *
 *
*/
CREATE PROCEDURE uspGetMimeTypeByExtension

	@nvrExtension NVARCHAR(5)

AS

	SET NOCOUNT ON
	
	DECLARE @nvrMimeType NVARCHAR(250)

	SELECT TOP 1
		@nvrMimeType = Name1
	FROM
		MimeType WITH (NOLOCK)
	WHERE
		Active = 1
		AND Extension = @nvrExtension

	SELECT COALESCE(@nvrMimeType, 'application/octet-stream') as [MimeType]

GO