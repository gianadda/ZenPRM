IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnConvertBitToYesNo') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnConvertBitToYesNo
GO
/* ufnConvertBitToYesNo
 *
 *	Converts a bit value to Yes or No text
 *
 */
CREATE FUNCTION ufnConvertBitToYesNo(@bitValue AS BIT)

	RETURNS NVARCHAR(3)
	
 BEGIN

	DECLARE @nvrReturnValue NVARCHAR(3)

	SET @nvrReturnValue = 'No'

	IF (@bitValue = 1)
		BEGIN
			SET @nvrReturnValue = 'Yes'
		END

	RETURN @nvrReturnValue

 END

GO