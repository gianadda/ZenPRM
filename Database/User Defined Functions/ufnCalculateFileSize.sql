IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnCalculateFileSize') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnCalculateFileSize
GO
/* ufnCalculateFileSize
 *
 *	Desc
 *
 */
CREATE FUNCTION ufnCalculateFileSize(@intFileSize AS BIGINT)

	RETURNS NVARCHAR(25)
	
 BEGIN

	DECLARE @decFileSizeKB AS DECIMAL(18,2)
	DECLARE @nvrFileSize AS NVARCHAR(25)
	SET @decFileSizeKB = 0.0
	SET @nvrFileSize = ''

	SET @decFileSizeKB = CAST((@intFileSize / 1024.0) AS DECIMAL(18,2))

	SELECT
		@nvrFileSize = CAST(@decFileSizeKB AS NVARCHAR(25)) + ' KB'
	WHERE 
		@decFileSizeKB < 1024

	SELECT
		@nvrFileSize = CAST(CAST((@decFileSizeKB / 1024.0) AS DECIMAL(18,2)) AS NVARCHAR(25)) + ' MB'
	WHERE 
		@decFileSizeKB >= 1024

	RETURN @nvrFileSize
	
 END

GO