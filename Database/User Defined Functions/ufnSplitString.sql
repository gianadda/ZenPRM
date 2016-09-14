IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnSplitString') 
	AND OBJECTPROPERTY(id, N'IsTableFunction') = 1)
DROP FUNCTION ufnSplitString
GO

CREATE FUNCTION ufnSplitString (

	@strOrigString		NVARCHAR (MAX),
	@strDelimiter 		NVARCHAR (10)

) 

RETURNS 
	@tblValueTable table ([Value] nvarchar(4000))
BEGIN

	DECLARE @strNextString 		nvarchar(4000)
	DECLARE @intPos 		int
	DECLARE @intNextPos 		int
	DECLARE @strCommaCheck 		nvarchar(1)
 
	--Initialize
	set @strNextString = ''
	set @strCommaCheck = right(@strOrigString,1) 
 
	--Insert delimited so we know at least one exists
	IF LEN(LTRIM(RTRIM(@strOrigString))) > 0 and @strCommaCheck <> @strDelimiter

	  BEGIN
		SET @strOrigString = @strOrigString + @strDelimiter
	  END
 
	--Get position of first Comma
	SET @intPos = charindex(@strDelimiter,@strOrigString)
	SET @intNextPos = 1

	--Loop while there is still a comma in the String of levels
	WHILE (@intPos <>  0)  
	  BEGIN
		SET @strNextString = substring(@strOrigString,1,@intPos - 1)

		INSERT INTO
			@tblValueTable 
			(Value)
		SELECT
			Value = @strNextString


		SET @strOrigString = SUBSTRING(@strOrigString, @intPos + 1, LEN(@strOrigString))

		SET @intNextPos = @intPos
		
		SET @intPos  = CHARINDEX(@strDelimiter, @strOrigString)
	  END

	RETURN
END
