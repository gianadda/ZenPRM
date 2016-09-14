IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspConvertSQLTableToWebAPIModel') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspConvertSQLTableToWebAPIModel
GO

/* uspConvertSQLTableToWebAPIModel
 *
 *	
 *	
 *
 */

CREATE PROCEDURE uspConvertSQLTableToWebAPIModel

	@nvrTableName NVARCHAR(500)

AS
	
	SET NOCOUNT ON
	
	DECLARE @nvrOutput NVARCHAR(MAX)
	DECLARE @nvrLinebreak NVARCHAR(10)
	DECLARE @nvrObjectDeclaration NVARCHAR(MAX)
	DECLARE @nvrProperties NVARCHAR(MAX)
	DECLARE @nvrControllerForEachLoop NVARCHAR(MAX)
	DECLARE @nvrColumnName NVARCHAR(256)
	DECLARE @nvrDataType NVARCHAR(256)
	DECLARE @nvrTab NVARCHAR(10)
	DECLARE @nvrVariableName NVARCHAR(100)
	DECLARE @nvrObjectType NVARCHAR(100)

	SET @nvrLinebreak = CHAR(13)+CHAR(10)
	SET @nvrTab = CHAR(9)
	SET @nvrObjectDeclaration = ''
	SET @nvrProperties = ''
	SET @nvrControllerForEachLoop = ''

	CREATE TABLE #tmpColumns(
		Ident BIGINT IDENTITY(1,1),
		ColumnName NVARCHAR(256),
		DataType NVARCHAR(256)
	)

	INSERT INTO #tmpColumns(
		ColumnName,
		DataType
	)
	SELECT
		c.name,
		ty.name
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
		DataType
	FROM
		#tmpColumns WITH (NOLOCK)
	ORDER BY
		Ident ASC

	OPEN table_cursor
	
	FETCH NEXT FROM table_cursor 
	INTO @nvrColumnName, @nvrDataType

	WHILE @@FETCH_STATUS = 0
	BEGIN


		SET @nvrVariableName = ''
		SET @nvrVariableName = CASE @nvrDataType
									WHEN 'bigint' THEN 'int'
									WHEN 'binary' THEN 'str'
									WHEN 'bit' THEN 'bol'
									WHEN 'char' THEN 'str'
									WHEN 'date' THEN 'dte'
									WHEN 'datetime' THEN 'dte'
									WHEN 'datetime2' THEN 'dte'
									WHEN 'datetimeoffset' THEN 'dte'
									WHEN 'decimal' THEN 'dec'
									WHEN 'float' THEN 'dec'
									WHEN 'image' THEN 'img'
									WHEN 'int' THEN 'int'
									WHEN 'money' THEN 'dec'
									WHEN 'nchar' THEN 'str'
									WHEN 'ntext' THEN 'str'
									WHEN 'numeric' THEN 'int'
									WHEN 'nvarchar' THEN 'str'
									WHEN 'smalldatetime' THEN 'dte'
									WHEN 'smallint' THEN 'int'
									WHEN 'smallmoney' THEN 'dec'
									WHEN 'text' THEN 'str'
									WHEN 'time' THEN 'dte'
									WHEN 'timestamp' THEN 'dte'
									WHEN 'tinyint' THEN 'int'
									WHEN 'varbinary' THEN 'str'
									WHEN 'varchar' THEN 'str'
									WHEN 'xml' THEN 'xml'
									ELSE ''
								END  + @nvrColumnName

		SET @nvrObjectType = ''
		SET @nvrObjectType = CASE @nvrDataType
									WHEN 'bigint' THEN 'Int64'
									WHEN 'binary' THEN 'String'
									WHEN 'bit' THEN 'Boolean'
									WHEN 'char' THEN 'String'
									WHEN 'date' THEN 'Date'
									WHEN 'datetime' THEN 'DateTime'
									WHEN 'datetime2' THEN 'DateTime'
									WHEN 'decimal' THEN 'Decimal'
									WHEN 'float' THEN 'Decimal'
									WHEN 'image' THEN 'Image'
									WHEN 'int' THEN 'Integer'
									WHEN 'money' THEN 'Decimal'
									WHEN 'nchar' THEN 'String'
									WHEN 'ntext' THEN 'String'
									WHEN 'numeric' THEN 'Integer'
									WHEN 'nvarchar' THEN 'String'
									WHEN 'smalldatetime' THEN 'DateTime'
									WHEN 'smallint' THEN 'Integer'
									WHEN 'smallmoney' THEN 'Decimal'
									WHEN 'text' THEN 'String'
									WHEN 'time' THEN 'DateTime'
									WHEN 'timestamp' THEN 'DateTime'
									WHEN 'tinyint' THEN 'Integer'
									WHEN 'varbinary' THEN 'String'
									WHEN 'varchar' THEN 'String'
									WHEN 'xml' THEN 'XML'
									ELSE ''
								END 

		-- SETUP THE OBJECT DECLARATION (i.e. Private intIdent as Int64 = 0)
		SET @nvrObjectDeclaration = @nvrObjectDeclaration + @nvrTab + 'Private ' + @nvrVariableName + ' As ' + @nvrObjectType + ' = '
		
		-- Set the Default Value
		SET @nvrObjectDeclaration = @nvrObjectDeclaration + CASE @nvrDataType
																WHEN 'bigint' THEN '0'
																WHEN 'binary' THEN '""'
																WHEN 'bit' THEN 'False'
																WHEN 'char' THEN '""'
																WHEN 'date' THEN '"1/1/1900"'
																WHEN 'datetime' THEN '"1/1/1900"'
																WHEN 'datetime2' THEN '"1/1/1900"'
																WHEN 'decimal' THEN '0.00'
																WHEN 'float' THEN '0.00'
																WHEN 'image' THEN 'Nothing'
																WHEN 'int' THEN '0'
																WHEN 'money' THEN '0.00'
																WHEN 'nchar' THEN '""'
																WHEN 'ntext' THEN '""'
																WHEN 'numeric' THEN '0'
																WHEN 'nvarchar' THEN '""'
																WHEN 'smalldatetime' THEN '"1/1/1900"'
																WHEN 'smallint' THEN '0'
																WHEN 'smallmoney' THEN '0.00'
																WHEN 'text' THEN '""'
																WHEN 'time' THEN '"1/1/1900"'
																WHEN 'timestamp' THEN '"1/1/1900"'
																WHEN 'tinyint' THEN '0'
																WHEN 'uniqueidentifier' THEN '""'
																WHEN 'varbinary' THEN '""'
																WHEN 'varchar' THEN '""'
																WHEN 'xml' THEN 'Nothing'
																ELSE ''
															END 
		 
		 -- Add the Line break
		 SET @nvrObjectDeclaration = @nvrObjectDeclaration + @nvrLinebreak

		 /**************
		 SETUP THE PROPERTIES (i.e.
			
			Public Property Ident() As Int64
				Get
					Return intIdent
				End Get
				Set(value As Int64)
					intIdent = value
				End Set
			End Property

		*****************/

		 SET @nvrProperties = @nvrProperties + 'Public Property ' + @nvrColumnName + '() As ' + @nvrObjectType + @nvrLinebreak
		 SET @nvrProperties = @nvrProperties + @nvrTab + 'Get' + @nvrLinebreak
		 SET @nvrProperties = @nvrProperties + @nvrTab + @nvrTab + 'Return ' + @nvrVariableName + @nvrLinebreak
		 SET @nvrProperties = @nvrProperties + @nvrTab + 'End Get' + @nvrLinebreak
		 SET @nvrProperties = @nvrProperties + @nvrTab + 'Set(value As ' + @nvrObjectType + ')' + @nvrLinebreak
		 SET @nvrProperties = @nvrProperties + @nvrTab + @nvrTab + @nvrVariableName + ' = value' + @nvrLinebreak
		 SET @nvrProperties = @nvrProperties + @nvrTab + 'End Set' + @nvrLinebreak
		 SET @nvrProperties = @nvrProperties + 'End Property' + @nvrLinebreak + @nvrLinebreak

		 /**************
			SETUP THE FOR EACH LOOP IN THE GET ALL CONTROLLER

				 For Each drRow In dsResults.Tables(0).Rows

                        records.Add(
                            New ASUser() With {
                                .XXX = drRow.Item("XXX"),
                                .X2 = drRow.Item("X2")
                            }
                        )
                    Next


		***************/

		SET @nvrControllerForEachLoop = @nvrControllerForEachLoop + @nvrTab + @nvrTab + @nvrTab + '.' + @nvrColumnName + ' = drRow.Item("' + @nvrColumnName + '"),' + @nvrLinebreak

		FETCH NEXT FROM table_cursor 
		INTO @nvrColumnName, @nvrDataType
	END 
	CLOSE table_cursor;
	DEALLOCATE table_cursor;

	SET @nvrOutput = 'Public Class ' + @nvrTableName + @nvrLinebreak + @nvrLinebreak
	SET @nvrOutput = @nvrOutput + @nvrObjectDeclaration + @nvrLinebreak
	SET @nvrOutput = @nvrOutput + @nvrProperties + @nvrLinebreak
	SET @nvrOutput = @nvrOutput + 'End Class'

	SET @nvrControllerForEachLoop = SUBSTRING(@nvrControllerForEachLoop, 1, (LEN(@nvrControllerForEachLoop) - 3))
	SET @nvrControllerForEachLoop = 'For Each drRow In dsResults.Tables(0).Rows' + @nvrLinebreak + @nvrLinebreak + @nvrTab + 'records.Add(' + @nvrLinebreak +
									@nvrTab + @nvrTab + 'New ' + @nvrTableName + '() With {' + @nvrLinebreak + @nvrControllerForEachLoop + @nvrLinebreak + @nvrTab + @nvrTab + '}' + @nvrLinebreak +
									@nvrTab + ')' + @nvrLinebreak + @nvrLinebreak + 'Next'

	SELECT @nvrOutput as [Model]
	SELECT @nvrControllerForEachLoop as [Controller]
	SELECT * FROM #tmpColumns

	DROP TABLE #tmpColumns

GO
