IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspConvertSQLTableToCRUDStoredProcedures') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspConvertSQLTableToCRUDStoredProcedures
GO

/* uspConvertSQLTableToCRUDStoredProcedures
 *
 *	
 *	
 *
 */

CREATE PROCEDURE uspConvertSQLTableToCRUDStoredProcedures

	@nvrTableName NVARCHAR(500)

AS
	
	SET NOCOUNT ON
	

	DECLARE @nvrLinebreak NVARCHAR(10)
	DECLARE @nvrTab NVARCHAR(10)

	DECLARE @nvrInsertSPParamDeclaration NVARCHAR(MAX) -- All columns minus Ident, include default values 
	DECLARE @nvrUpdateSPParamDeclaration NVARCHAR(MAX) -- All columns without the defaults
	DECLARE @nvrDeleteAndGetByIdentSPParamDeclaration NVARCHAR(MAX) -- Ident

	DECLARE @nvrColumnName NVARCHAR(256)
	DECLARE @nvrDataType NVARCHAR(256)
	DECLARE @tntDataPrecision TINYINT
	DECLARE @tntDataScale TINYINT
	DECLARE @nvrDataTypeDefaultValue NVARCHAR(256)
	DECLARE @nvrVariableName NVARCHAR(100)
	
	DECLARE @strDefaultDate NVARCHAR(100)
	DECLARE @strDefaultAddEditUserIdent NVARCHAR(100)
	
	DECLARE @nvrColumnListForInsert NVARCHAR(MAX)
	DECLARE @nvrColumnListForSelectWithIdent NVARCHAR(MAX)
	DECLARE @nvrColumnListForSelect NVARCHAR(MAX)
	DECLARE @nvrColumnListForUpdate NVARCHAR(MAX)


	DECLARE @nvrInsertOutput NVARCHAR(MAX)
	DECLARE @nvrUpdateOutput NVARCHAR(MAX)
	DECLARE @nvrDeleteOutput NVARCHAR(MAX)
	DECLARE @nvrGetByIdentOutput NVARCHAR(MAX)
	DECLARE @nvrGetAllActiveOutput NVARCHAR(MAX)
	DECLARE @nvrSearchOutput NVARCHAR(MAX)
	
	SET @nvrLinebreak = CHAR(13)+CHAR(10)
	SET @nvrTab = CHAR(9)

	SET @nvrInsertSPParamDeclaration = ''
	SET @nvrUpdateSPParamDeclaration = ''
	SET @nvrDeleteAndGetByIdentSPParamDeclaration = ''
	SET @nvrColumnListForInsert = ''
	SET @nvrColumnListForSelectWithIdent = ''
	SET @nvrColumnListForSelect = ''
	SET @nvrColumnListForUpdate = ''
	
	SET @nvrInsertOutput = ''
	SET @nvrUpdateOutput = ''
	SET @nvrDeleteOutput = ''
	SET @nvrGetByIdentOutput = ''
	SET @nvrGetAllActiveOutput = ''
	SET @nvrSearchOutput = ''
	

	SET @strDefaultDate = '''1/1/1900'''
	SET @strDefaultAddEditUserIdent = '1'
	
	CREATE TABLE #tmpColumns(
		Ident BIGINT IDENTITY(1,1),
		ColumnName NVARCHAR(256),
		DataType NVARCHAR(256),
		DataPrecision TINYINT,
		DataScale TINYINT
	)

	INSERT INTO #tmpColumns(
		ColumnName,
		DataType,
		DataPrecision,
		DataScale
	)
	SELECT
		c.name,
		ty.name,
		c.precision,
		c.scale
	FROM
		sys.columns c WITH (NOLOCK)
		INNER JOIN
		sys.tables t WITH (NOLOCK)
			on t.object_id = c.object_id
		INNER JOIN
		sys.types ty WITH (NOLOCK)
			on ty.system_type_id = c.system_type_id
	WHERE
		t.name = @nvrTableName
		AND ty.name <> 'sysname'
	ORDER BY
		column_id ASC


	DECLARE table_cursor CURSOR FOR 
	SELECT
		ColumnName,
		DataType,
		DataPrecision,
		DataScale
	FROM
		#tmpColumns WITH (NOLOCK)
	ORDER BY
		Ident ASC

	OPEN table_cursor
	
	FETCH NEXT FROM table_cursor 
	INTO @nvrColumnName, @nvrDataType, @tntDataPrecision, @tntDataScale

	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @nvrDataTypeDefaultValue = ''
		SET @nvrDataTypeDefaultValue = CASE @nvrDataType
											WHEN 'bigint' THEN '0'
											WHEN 'binary' THEN ''''''
											WHEN 'bit' THEN 'False'
											WHEN 'char' THEN ''''''
											WHEN 'date' THEN '''1/1/1900'''
											WHEN 'datetime' THEN '''1/1/1900'''
											WHEN 'datetime2' THEN '''1/1/1900'''
											WHEN 'decimal' THEN '0.00'
											WHEN 'float' THEN '0.00'
											WHEN 'image' THEN ''
											WHEN 'int' THEN '0'
											WHEN 'money' THEN '0.00'
											WHEN 'nchar' THEN ''''''
											WHEN 'ntext' THEN ''''''
											WHEN 'numeric' THEN '0'
											WHEN 'nvarchar' THEN ''''''
											WHEN 'smalldatetime' THEN '''1/1/1900'''
											WHEN 'smallint' THEN '0'
											WHEN 'smallmoney' THEN '0.00'
											WHEN 'text' THEN ''''''
											WHEN 'time' THEN '''1/1/1900'''
											WHEN 'timestamp' THEN '''1/1/1900'''
											WHEN 'tinyint' THEN '0'
											WHEN 'uniqueidentifier' THEN ''''''
											WHEN 'varbinary' THEN ''''''
											WHEN 'varchar' THEN ''''''
											WHEN 'xml' THEN ''
											ELSE ''
										END 

		SET @nvrVariableName = ''
		SET @nvrVariableName = CASE @nvrDataType
									WHEN 'bigint' THEN 'int'
									WHEN 'binary' THEN 'str'
									WHEN 'bit' THEN 'bit'
									WHEN 'char' THEN 'chr'
									WHEN 'date' THEN 'dt'
									WHEN 'datetime' THEN 'dt'
									WHEN 'datetime2' THEN 'dt'
									WHEN 'datetimeoffset' THEN 'dt'
									WHEN 'decimal' THEN 'dec'
									WHEN 'float' THEN 'dec'
									WHEN 'image' THEN 'img'
									WHEN 'int' THEN 'int'
									WHEN 'money' THEN 'mny'
									WHEN 'nchar' THEN 'cnr'
									WHEN 'ntext' THEN 'ntx'
									WHEN 'numeric' THEN 'int'
									WHEN 'nvarchar' THEN 'nvr'
									WHEN 'smalldatetime' THEN 'sdt'
									WHEN 'smallint' THEN 'snt'
									WHEN 'smallmoney' THEN 'mny'
									WHEN 'text' THEN 'txt'
									WHEN 'time' THEN 'tme'
									WHEN 'timestamp' THEN 'dt'
									WHEN 'tinyint' THEN 'tnt'
									WHEN 'varbinary' THEN 'vbi'
									WHEN 'varchar' THEN 'vcr'
									WHEN 'xml' THEN 'xml'
									ELSE ''
								END  + @nvrColumnName

		--Add Precision and scale where necessary
		SET @nvrDataType = CASE @nvrDataType
									WHEN 'char' THEN @nvrDataType
									WHEN 'decimal' THEN @nvrDataType
									WHEN 'float' THEN @nvrDataType
									WHEN 'nchar' THEN @nvrDataType
									WHEN 'ntext' THEN @nvrDataType
									WHEN 'nvarchar' THEN 
														CASE @tntDataScale 
															WHEN 0 THEN @nvrDataType + '(MAX)'
															ELSE @nvrDataType + '(' + CONVERT(NVARCHAR(100),(@tntDataPrecision/2)) + ')'
														END
									WHEN 'varbinary' THEN @nvrDataType
									WHEN 'varchar' THEN 
														CASE @tntDataScale 
															WHEN 0 THEN @nvrDataType + '(MAX)'
															ELSE @nvrDataType + '(' + CONVERT(NVARCHAR(100),(@tntDataPrecision)) + ')'
														END
									ELSE @nvrDataType
								END 

		--Only add Ident for the Delete and Get by Ident SPs		
		IF @nvrColumnName = 'Ident' 
		BEGIN
			SET @nvrDeleteAndGetByIdentSPParamDeclaration = @nvrDeleteAndGetByIdentSPParamDeclaration + @nvrTab + '@' + @nvrVariableName + ' ' + UPPER(@nvrDataType) + @nvrLinebreak
		END
		
		--Dont include Ident in on the process for Inserts or updates
		IF @nvrColumnName <> 'Ident' 
		BEGIN
		
			SET @nvrInsertSPParamDeclaration = @nvrInsertSPParamDeclaration + @nvrTab + '@' + @nvrVariableName + ' ' + UPPER(@nvrDataType) + ' = '

			--For inserts, we want to add a default value
			SET @nvrInsertSPParamDeclaration = @nvrInsertSPParamDeclaration + @nvrDataTypeDefaultValue
			-- Add the Line breaks
			SET @nvrInsertSPParamDeclaration = @nvrInsertSPParamDeclaration + ', ' + @nvrLinebreak
		 
			--Create the 
			SET @nvrColumnListForInsert = @nvrColumnListForInsert + @nvrTab + @nvrTab + @nvrColumnName + ', ' + @nvrLinebreak
			SET @nvrColumnListForSelect = @nvrColumnListForSelect + @nvrTab + @nvrTab + @nvrColumnName + ' = ' + '@' + @nvrVariableName + ', ' + @nvrLinebreak
			
			SET @nvrColumnListForUpdate = @nvrColumnListForUpdate + @nvrTab + @nvrTab + @nvrColumnName + ' = ' + '@' + @nvrVariableName + ', ' + @nvrLinebreak

		END
		
		SET @nvrColumnListForSelectWithIdent = @nvrColumnListForSelectWithIdent + @nvrTab + @nvrTab + @nvrColumnName + ', ' + @nvrLinebreak

		--Include all columns for Updates
		SET @nvrUpdateSPParamDeclaration = @nvrUpdateSPParamDeclaration + @nvrTab + '@' + @nvrVariableName + ' ' + UPPER(@nvrDataType)

		SET @nvrUpdateSPParamDeclaration = @nvrUpdateSPParamDeclaration + ', ' + @nvrLinebreak



		FETCH NEXT FROM table_cursor 
		INTO @nvrColumnName, @nvrDataType, @tntDataPrecision, @tntDataScale
	END 
	CLOSE table_cursor;
	DEALLOCATE table_cursor;

	--Remove Final comma from Params: NOTE the removal of 4 char, there is a space and Lb and stuff
	SET @nvrInsertSPParamDeclaration = LEFT(LTRIM(RTRIM(@nvrInsertSPParamDeclaration)), LEN(@nvrInsertSPParamDeclaration) - 4)
	SET @nvrUpdateSPParamDeclaration = LEFT(LTRIM(RTRIM(@nvrUpdateSPParamDeclaration)), LEN(@nvrUpdateSPParamDeclaration) - 4)
	SET @nvrColumnListForInsert = LEFT(LTRIM(RTRIM(@nvrColumnListForInsert)), LEN(@nvrColumnListForInsert) - 4)
	SET @nvrColumnListForSelect = LEFT(LTRIM(RTRIM(@nvrColumnListForSelect)), LEN(@nvrColumnListForSelect) - 4)
	SET @nvrColumnListForSelectWithIdent = LEFT(LTRIM(RTRIM(@nvrColumnListForSelectWithIdent)), LEN(@nvrColumnListForSelectWithIdent) - 4)
	SET @nvrColumnListForUpdate = LEFT(LTRIM(RTRIM(@nvrColumnListForUpdate)), LEN(@nvrColumnListForUpdate) - 4)

	
	--Create the INSERT SP:
	SET @nvrInsertOutput += 'IF EXISTS (select * from dbo.sysobjects where id = object_id(N''uspAdd' + @nvrTableName + ''') AND OBJECTPROPERTY(id, N''IsProcedure'') = 1) '  + @nvrLinebreak + '  DROP PROCEDURE uspAdd' + @nvrTableName + @nvrLinebreak + ' GO' + @nvrLinebreak
	SET @nvrInsertOutput += '/* uspAdd' + @nvrTableName + @nvrLinebreak + ' *' + @nvrLinebreak + ' *' + @nvrLinebreak + ' *' + @nvrLinebreak + ' *' + @nvrLinebreak + '*/' + @nvrLinebreak
	SET @nvrInsertOutput += 'CREATE PROCEDURE [dbo].[uspAdd' + @nvrTableName + ']' + @nvrLinebreak  + @nvrLinebreak
	SET @nvrInsertOutput += @nvrInsertSPParamDeclaration + @nvrLinebreak  + @nvrLinebreak
	SET @nvrInsertOutput += 'AS' + @nvrLinebreak + @nvrLinebreak
	SET @nvrInsertOutput += @nvrTab + 'SET NOCOUNT ON' + @nvrLinebreak + @nvrLinebreak
	SET @nvrInsertOutput += @nvrTab + 'INSERT INTO ' + @nvrTableName + ' (' + @nvrLinebreak
	SET @nvrInsertOutput += @nvrColumnListForInsert + @nvrLinebreak
	SET @nvrInsertOutput += @nvrTab +  ') ' + @nvrLinebreak + @nvrTab +  'SELECT ' + @nvrLinebreak
	SET @nvrInsertOutput += @nvrColumnListForSelect + @nvrLinebreak + @nvrLinebreak 
	SET @nvrInsertOutput += @nvrTab + 'SELECT ''Ident'' = SCOPE_IDENTITY()' + @nvrLinebreak + @nvrLinebreak 
	SET @nvrInsertOutput += 'GO'		

	
	--Create the UPDATE SP:
	SET @nvrUpdateOutput += 'IF EXISTS (select * from dbo.sysobjects where id = object_id(N''uspEdit' + @nvrTableName + 'ByIdent'') AND OBJECTPROPERTY(id, N''IsProcedure'') = 1) '  + @nvrLinebreak + '  DROP PROCEDURE uspEdit' + @nvrTableName + 'ByIdent' + @nvrLinebreak + ' GO' + @nvrLinebreak
	SET @nvrUpdateOutput += '/* uspEdit' + @nvrTableName + 'ByIdent' + @nvrLinebreak + ' *' + @nvrLinebreak + ' *' + @nvrLinebreak + ' *' + @nvrLinebreak + ' *' + @nvrLinebreak + '*/' + @nvrLinebreak
	SET @nvrUpdateOutput += 'CREATE PROCEDURE [dbo].[uspEdit' + @nvrTableName + 'ByIdent]' + @nvrLinebreak  + @nvrLinebreak
	SET @nvrUpdateOutput += @nvrUpdateSPParamDeclaration + @nvrLinebreak  + @nvrLinebreak
	SET @nvrUpdateOutput += 'AS' + @nvrLinebreak + @nvrLinebreak
	SET @nvrUpdateOutput += @nvrTab + 'SET NOCOUNT ON' + @nvrLinebreak + @nvrLinebreak
	SET @nvrUpdateOutput += @nvrTab + 'UPDATE ' + @nvrTableName + @nvrLinebreak
	SET @nvrUpdateOutput += @nvrTab + 'SET ' + @nvrLinebreak
	SET @nvrUpdateOutput += @nvrColumnListForUpdate + @nvrLinebreak
	SET @nvrUpdateOutput += @nvrTab + 'WHERE' + @nvrLinebreak
	SET @nvrUpdateOutput += @nvrTab + @nvrTab + 'Ident = @intIdent' + @nvrLinebreak
	SET @nvrUpdateOutput += 'GO'		

	--Create the DELETE SP:
	SET @nvrDeleteOutput += 'IF EXISTS (select * from dbo.sysobjects where id = object_id(N''uspDelete' + @nvrTableName + 'ByIdent'') AND OBJECTPROPERTY(id, N''IsProcedure'') = 1) '  + @nvrLinebreak + '  DROP PROCEDURE uspDelete' + @nvrTableName + 'ByIdent' + @nvrLinebreak + ' GO' + @nvrLinebreak
	SET @nvrDeleteOutput += '/* uspDelete' + @nvrTableName + 'ByIdent' + @nvrLinebreak + ' *' + @nvrLinebreak + ' *' + @nvrLinebreak + ' *' + @nvrLinebreak + ' *' + @nvrLinebreak + '*/' + @nvrLinebreak
	SET @nvrDeleteOutput += 'CREATE PROCEDURE [dbo].[uspDelete' + @nvrTableName + 'ByIdent]' + @nvrLinebreak  + @nvrLinebreak
	SET @nvrDeleteOutput += @nvrDeleteAndGetByIdentSPParamDeclaration + @nvrLinebreak 
	SET @nvrDeleteOutput += 'AS' + @nvrLinebreak + @nvrLinebreak
	SET @nvrDeleteOutput += @nvrTab + 'SET NOCOUNT ON' + @nvrLinebreak + @nvrLinebreak
	SET @nvrDeleteOutput += @nvrTab + 'UPDATE ' + @nvrTableName + @nvrLinebreak
	SET @nvrDeleteOutput += @nvrTab + 'SET ' + @nvrLinebreak
	SET @nvrDeleteOutput += @nvrTab + @nvrTab + 'Active = 0' + @nvrLinebreak
	SET @nvrDeleteOutput += @nvrTab + 'WHERE' + @nvrLinebreak
	SET @nvrDeleteOutput += @nvrTab + @nvrTab + 'Ident = @intIdent' + @nvrLinebreak
	SET @nvrDeleteOutput += 'GO'	
	
	--Create the GETBYIdent SP:
	SET @nvrGetByIdentOutput += 'IF EXISTS (select * from dbo.sysobjects where id = object_id(N''uspGet' + @nvrTableName + 'ByIdent'') AND OBJECTPROPERTY(id, N''IsProcedure'') = 1) '  + @nvrLinebreak + '  DROP PROCEDURE uspGet' + @nvrTableName + 'ByIdent' + @nvrLinebreak + ' GO' + @nvrLinebreak
	SET @nvrGetByIdentOutput += '/* uspGet' + @nvrTableName + 'ByIdent' + @nvrLinebreak + ' *' + @nvrLinebreak + ' *' + @nvrLinebreak + ' *' + @nvrLinebreak + ' *' + @nvrLinebreak + '*/' + @nvrLinebreak
	SET @nvrGetByIdentOutput += 'CREATE PROCEDURE [dbo].[uspGet' + @nvrTableName + 'ByIdent]' + @nvrLinebreak  + @nvrLinebreak
	SET @nvrGetByIdentOutput += @nvrDeleteAndGetByIdentSPParamDeclaration + @nvrLinebreak 
	SET @nvrGetByIdentOutput += 'AS' + @nvrLinebreak + @nvrLinebreak
	SET @nvrGetByIdentOutput += @nvrTab + 'SET NOCOUNT ON' + @nvrLinebreak + @nvrLinebreak
	SET @nvrGetByIdentOutput += @nvrTab + 'SELECT ' +  @nvrLinebreak
	SET @nvrGetByIdentOutput += @nvrColumnListForSelectWithIdent + @nvrLinebreak
	SET @nvrGetByIdentOutput += @nvrTab + 'FROM' + @nvrLinebreak
	SET @nvrGetByIdentOutput += @nvrTab + @nvrTab + @nvrTableName + ' WITH (NOLOCK)' + @nvrLinebreak
	SET @nvrGetByIdentOutput += @nvrTab + 'WHERE' + @nvrLinebreak
	SET @nvrGetByIdentOutput += @nvrTab + @nvrTab + 'Ident = @intIdent' + @nvrLinebreak
	SET @nvrGetByIdentOutput += 'GO'	

	
	--Create the GETAllActive SP:
	SET @nvrGetAllActiveOutput += 'IF EXISTS (select * from dbo.sysobjects where id = object_id(N''uspGetAllActive' + @nvrTableName + ''') AND OBJECTPROPERTY(id, N''IsProcedure'') = 1) '  + @nvrLinebreak + '  DROP PROCEDURE uspGetAllActive' + @nvrTableName + @nvrLinebreak + ' GO' + @nvrLinebreak
	SET @nvrGetAllActiveOutput += '/* uspGetAllActive' + @nvrTableName + @nvrLinebreak + ' *' + @nvrLinebreak + ' *' + @nvrLinebreak + ' *' + @nvrLinebreak + ' *' + @nvrLinebreak + '*/' + @nvrLinebreak
	SET @nvrGetAllActiveOutput += 'CREATE PROCEDURE [dbo].[uspGetAllActive' + @nvrTableName + ']' + @nvrLinebreak  + @nvrLinebreak
	SET @nvrGetAllActiveOutput += @nvrDeleteAndGetByIdentSPParamDeclaration + @nvrLinebreak 
	SET @nvrGetAllActiveOutput += 'AS' + @nvrLinebreak + @nvrLinebreak
	SET @nvrGetAllActiveOutput += @nvrTab + 'SET NOCOUNT ON' + @nvrLinebreak + @nvrLinebreak
	SET @nvrGetAllActiveOutput += @nvrTab + 'SELECT ' +  @nvrLinebreak
	SET @nvrGetAllActiveOutput += @nvrColumnListForSelectWithIdent + @nvrLinebreak
	SET @nvrGetAllActiveOutput += @nvrTab + 'FROM' + @nvrLinebreak
	SET @nvrGetAllActiveOutput += @nvrTab + @nvrTab + @nvrTableName + ' WITH (NOLOCK)' + @nvrLinebreak
	SET @nvrGetAllActiveOutput += @nvrTab + 'WHERE' + @nvrLinebreak
	SET @nvrGetAllActiveOutput += @nvrTab + @nvrTab + 'Active = 1' + @nvrLinebreak
	SET @nvrGetAllActiveOutput += 'GO'	

	--Create the @nvrSearchOutput SP:
	SET @nvrSearchOutput += 'IF EXISTS (select * from dbo.sysobjects where id = object_id(N''uspSearch' + @nvrTableName + ''') AND OBJECTPROPERTY(id, N''IsProcedure'') = 1) '  + @nvrLinebreak + '  DROP PROCEDURE uspSearch' + @nvrTableName + @nvrLinebreak + ' GO' + @nvrLinebreak
	SET @nvrSearchOutput += '/* uspSearch' + @nvrTableName + @nvrLinebreak + ' *' + @nvrLinebreak + ' *' + @nvrLinebreak + ' *' + @nvrLinebreak + ' *' + @nvrLinebreak + '*/' + @nvrLinebreak
	SET @nvrSearchOutput += 'CREATE PROCEDURE [dbo].[uspSearch' + @nvrTableName + ']' + @nvrLinebreak  + @nvrLinebreak
	SET @nvrSearchOutput += '--Add any params here!' + @nvrLinebreak  + @nvrLinebreak 
	SET @nvrSearchOutput += 'AS' + @nvrLinebreak + @nvrLinebreak
	SET @nvrSearchOutput += @nvrTab + 'SET NOCOUNT ON' + @nvrLinebreak + @nvrLinebreak
	SET @nvrSearchOutput += @nvrTab + 'SELECT ' +  @nvrLinebreak
	SET @nvrSearchOutput += @nvrColumnListForSelectWithIdent + @nvrLinebreak
	SET @nvrSearchOutput += @nvrTab + 'FROM' + @nvrLinebreak
	SET @nvrSearchOutput += @nvrTab + @nvrTab + @nvrTableName + ' WITH (NOLOCK)' + @nvrLinebreak
	SET @nvrSearchOutput += @nvrTab + '--WHERE' + @nvrLinebreak
	SET @nvrSearchOutput += @nvrTab + @nvrTab + '--Active = 1' + @nvrLinebreak
	SET @nvrSearchOutput += @nvrTab + @nvrTab + '--Add your where clause here!' + @nvrLinebreak
	SET @nvrSearchOutput += 'GO'	
	
	
	
	SELECT @nvrInsertOutput as [INSERTED]
	SELECT @nvrUpdateOutput as [UPDATE]
	SELECT @nvrDeleteOutput as [DELETE]
	SELECT @nvrGetByIdentOutput as [GETBYIdent]
	SELECT @nvrGetAllActiveOutput as [GETAllActive]
	SELECT @nvrSearchOutput as [SEARCH]
		

	DROP TABLE #tmpColumns

GO