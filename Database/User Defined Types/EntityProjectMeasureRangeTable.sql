IF NOT (SELECT TYPE_ID(N'EntityProjectMeasureRangeTable')) IS NULL
	BEGIN
		DROP TYPE EntityProjectMeasureRangeTable
	END
GO
-- Used to pass entity search filters from UI to SQL
	CREATE TYPE EntityProjectMeasureRangeTable AS TABLE 
	(
		EntityProjectMeasureIdent BIGINT,
		Name1 NVARCHAR(MAX),
		Color NVARCHAR(50),
		RangeStartValue DECIMAL(20,4),
		RangeEndValue DECIMAL(20,4)
	)

GO