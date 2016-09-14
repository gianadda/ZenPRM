--IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnReplaceSchemaDataWithData') 
--	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
--DROP FUNCTION ufnReplaceSchemaDataWithData
--GO
--/*

	
	
--*/

--CREATE FUNCTION ufnReplaceSchemaDataWithData(@sql NVARCHAR(max) , @tablename NVARCHAR(max) )

--	RETURNS NVARCHAR(MAX)

--AS

--BEGIN 
--		DECLARE @retval    NVARCHAR(MAX)
--		DECLARE @ParmDefinition nvarchar(500);
--		SET @ParmDefinition = N'@retvalOUT int OUTPUT';

--		select @sql = '	REPLACE(
--				' + @sql +', 
--				''@@' + c.name + ''', 
--				' + c.name + ')
--			'
--		from sys.columns c
--		inner join sys.tables t on c.object_id = t.object_id
--		where t.name = @tablename

--		SET @sql =  N'SELECT @retvalOUT = ' +  @sql + ' FROM ' + @tablename + ' WITH (NOLOCK) WHERE Ident = ' + CONVERT(NVARCHAR(MAX),1)
--		--PRINT @sql
--		EXEC sp_executesql @sql, @ParmDefinition, @retvalOUT=@retval OUTPUT;
--		return (@retval)

--	END
--GO



IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGeneratePOSTDataByEntityProjectIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGeneratePOSTDataByEntityProjectIdent
 GO
/* uspGeneratePOSTDataByEntityProjectIdent
 *
 * 
 *
 *
*/
CREATE PROCEDURE uspGeneratePOSTDataByEntityProjectIdent

	@intEntityProjectIdent BIGINT

AS

	DECLARE @ncrJSON								NVARCHAR(MAX)
	DECLARE @ncrTableName							NVARCHAR(MAX)
	DECLARE @intEntityProjectRequirementIdent		INT
	DECLARE @retval									NVARCHAR(MAX)
	DECLARE @sql									NVARCHAR(MAX)
	DECLARE @ParmDefinition							NVARCHAR(MAX)
	
	SET @ncrJSON = N'{'
	SET @ncrTableName = 'Entity'

	DECLARE @curGenerateJSON CURSOR
	SET @curGenerateJSON = CURSOR FOR
	SELECT TOP 1 EPR.Ident
	FROM EntityProjectRequirement EPR WITH (NOLOCK)
	WHERE EPR.EntityProjectIdent = @intEntityProjectIdent
	OPEN @curGenerateJSON
	FETCH NEXT
	FROM @curGenerateJSON INTO @intEntityProjectRequirementIdent
	WHILE @@FETCH_STATUS = 0
	BEGIN

	PRINT @intEntityProjectRequirementIdent
	SELECT 
		@sql = '''' + ECIM.DataSchema + ''''
	FROM
		EntityCustomImportMap ECIM WITH (NOLOCK)
		inner join
		EntityProjectRequirement EPR WITH (NOLOCK)
			on ecim.EntityProjectRequirementIdent = EPR.Ident
	WHERE 
		EPR.Ident = @intEntityProjectRequirementIdent



	SET @ParmDefinition = N'@retvalOUT int OUTPUT';

	select @sql = '	REPLACE(
			' + @sql +', 
			''@@' + c.name + ''', 
			' + c.name + ')
		'
	from sys.columns c
	inner join sys.tables t on c.object_id = t.object_id
	where t.name = @ncrTableName

	SET @sql =  N'SELECT @retvalOUT = ' +  @sql + ' FROM ' + @ncrTableName + ' WITH (NOLOCK) WHERE Ident = ' + CONVERT(NVARCHAR(MAX),1)
	PRINT @sql
	EXEC sp_executesql @sql, @ParmDefinition, @retvalOUT=@retval OUTPUT;
	


	SELECT
		@ncrJSON = @ncrJSON + '"' + CONVERT(NVARCHAR(MAX), EPR.Ident) + '":' + @retval
	FROM
		EntityCustomImportMap ECIM WITH (NOLOCK)
		inner join
		EntityProjectRequirement EPR WITH (NOLOCK)
			on ecim.EntityProjectRequirementIdent = EPR.Ident
	WHERE 
		EPR.Ident = @intEntityProjectRequirementIdent
	

--	PRINT @ncrJSON

	FETCH NEXT
	FROM @curGenerateJSON INTO @intEntityProjectRequirementIdent
	END
	CLOSE @curGenerateJSON
	DEALLOCATE @curGenerateJSON

	
	SET @ncrJSON = @ncrJSON + '}'

	SELECT @ncrJSON
	

GO