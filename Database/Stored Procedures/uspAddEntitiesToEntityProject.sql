IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntitiesToEntityProject') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntitiesToEntityProject
 GO
/* uspAddEntitiesToEntityProject 
 *
 * Pass in a pipe separated list to add entities to a project
 *
 *
*/
CREATE PROCEDURE uspAddEntitiesToEntityProject

	@bntASUserIdent BIGINT,
	@bntAddEntityProjectIdent BIGINT,
	@nvrEntityIdents NVARCHAR(MAX)

AS

	SET NOCOUNT ON

	CREATE TABLE #tmpEntity(
		EntityIdent BIGINT
	)

	INSERT INTO #tmpEntity(
		EntityIdent
	)
	SELECT	
		[Value]
	FROM
		dbo.ufnSplitString(@nvrEntityIdents,N'|')

	MERGE 
		EntityProjectEntity AS [target]
	USING 
		#tmpEntity AS [source] 
			ON 
			([target].EntityProjectIdent = @bntAddEntityProjectIdent
				AND [target].EntityIdent = [source].EntityIdent)
    	WHEN MATCHED THEN 
		UPDATE SET 
				Active = 1,
				EditDateTime = dbo.ufnGetMyDate(),
				EditASUserIdent = @bntASUserIdent
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (
				EntityProjectIdent,
				EntityIdent,
				AddASUserIdent,
				AddDateTime,
				EditASUserIdent,
				EditDateTime,
				Active
				)
		VALUES (
				@bntAddEntityProjectIdent,
				source.EntityIdent,
				@bntASUserIdent,
				dbo.ufnGetMyDate(),
				0,
				'1/1/1900',
				1
				); -- You really do need to end this function with a semi-colon

		-- Table 0: ResultCounts
		SELECT
			COUNT(*) as [ProjectEntityCount]
		FROM
			EntityProjectEntity WITH (NOLOCK)
		WHERE
			EntityProjectIdent = @bntAddEntityProjectIdent
			AND Active = 1

		DROP TABLE #tmpEntity

GO

