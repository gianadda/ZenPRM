IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspReindexTablesByFragmentation') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspReindexTablesByFragmentation
GO

/* uspReindexTablesByFragmentation 30, 50
 *
 *	
 *
 */

CREATE PROCEDURE uspReindexTablesByFragmentation

	@nvrServerName NVARCHAR(200),
	@decFragmentationLevel DECIMAL(7,4),
	@bntPageCount BIGINT

AS
	
	SET NOCOUNT ON

	DECLARE @nvrMessage NVARCHAR(MAX)
	DECLARE @intTableCount INT

	SET @nvrMessage = ''

	CREATE TABLE #tmpIndexes(
		TableName NVARCHAR(MAX),
		IndexName NVARCHAR(MAX),
		Fragmentation DECIMAL(7,4),
		Page_Count BIGINT
	)

	INSERT INTO #tmpIndexes(
		TableName,
		IndexName,
		Fragmentation,
		Page_Count
	)
	SELECT
		dbtables.[name],
		dbindexes.[name],
		indexstats.avg_fragmentation_in_percent,
		indexstats.page_count
	FROM 
		sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
		INNER JOIN 
		sys.tables dbtables 
			on dbtables.[object_id] = indexstats.[object_id]
		INNER JOIN 
		sys.schemas dbschemas 
			on dbtables.[schema_id] = dbschemas.[schema_id]
		INNER JOIN 
		sys.indexes AS dbindexes 
			ON dbindexes.[object_id] = indexstats.[object_id]
			AND indexstats.index_id = dbindexes.index_id
	WHERE 
		indexstats.database_id = DB_ID()
		AND dbindexes.[name] IS NOT NULL
		AND indexstats.avg_fragmentation_in_percent >= @decFragmentationLevel
		AND indexstats.page_count >= @bntPageCount

	SELECT
		@intTableCount = COUNT(*)
	FROM
		#tmpIndexes WITH (NOLOCK)

	DECLARE @nvrTableName NVARCHAR(MAX)
	DECLARE @nvrIndexName NVARCHAR(MAX)
	DECLARE @decFragmentation DECIMAL(7,4)
	DECLARE @intPageCount BIGINT
	DECLARE @nvrSQL NVARCHAR(MAX)

	-- loop through each entity
	DECLARE index_cursor CURSOR FOR

	SELECT 	
		TableName,
		IndexName,
		Fragmentation,
		Page_Count
	FROM 
		#tmpIndexes 

	OPEN index_cursor

	FETCH NEXT FROM index_cursor
	INTO @nvrTableName, @nvrIndexName, @decFragmentation, @intPageCount

	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @nvrSQL = 'ALTER INDEX ' + @nvrIndexName + ' ON ' + @nvrTableName + ' REBUILD'

		PRINT @nvrSQL

		EXEC sp_executesql @nvrSQL

		SET @nvrMessage = @nvrMessage + 'Rebuilt ' + @nvrIndexName + ' ON ' + @nvrTableName + ', FragLevel: ' + CAST(@decFragmentation AS NVARCHAR(10)) + ', PageCount: ' + CAST(@intPageCount AS NVARCHAR(10)) + ' | '

		FETCH NEXT FROM index_cursor
		INTO @nvrTableName, @nvrIndexName, @decFragmentation, @intPageCount

	END
		
	CLOSE index_cursor
	DEALLOCATE index_cursor

	EXEC uspAddASApplicationServiceAudit @nvrServerName, 'Reindexing', @intTableCount, @nvrMessage

	DROP TABLE #tmpIndexes

GO