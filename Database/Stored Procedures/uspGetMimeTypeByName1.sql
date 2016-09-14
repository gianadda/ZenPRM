IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetMimeTypeByName1') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetMimeTypeByName1
 GO
/* uspGetMimeTypeByName1 'image/gif'
 *
 *
 *
 *
*/
CREATE PROCEDURE uspGetMimeTypeByName1

	@nvrName1 NVARCHAR(250)

AS

	SET NOCOUNT ON
	
	SELECT
		Ident
	FROM
		MimeType WITH (NOLOCK)
	WHERE
		Active = 1
		AND Name1 = @nvrName1

GO