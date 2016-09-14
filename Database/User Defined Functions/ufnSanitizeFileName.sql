IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnSanitizeFileName') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnSanitizeFileName
GO
/*

	Remove illegal characters from filenames 
	
*/

CREATE FUNCTION ufnSanitizeFileName(@nvrFileName NVARCHAR(MAX))

	RETURNS NVARCHAR(MAX)

AS

	BEGIN
		
		SET @nvrFileName = REPLACE(@nvrFileName,'\','_')
		SET @nvrFileName = REPLACE(@nvrFileName,'/','_')
		SET @nvrFileName = REPLACE(@nvrFileName,':','_')
		SET @nvrFileName = REPLACE(@nvrFileName,'*','_')
		SET @nvrFileName = REPLACE(@nvrFileName,'?','_')
		SET @nvrFileName = REPLACE(@nvrFileName,'"','')
		SET @nvrFileName = REPLACE(@nvrFileName,'<','_')
		SET @nvrFileName = REPLACE(@nvrFileName,'>','_')
		SET @nvrFileName = REPLACE(@nvrFileName,'|','_')

		RETURN @nvrFileName

	END

GO