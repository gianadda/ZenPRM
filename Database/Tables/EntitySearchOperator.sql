IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntitySearchOperator') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntitySearchOperator
GO

CREATE TABLE EntitySearchOperator (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	EntitySearchDataTypeIdent BIGINT NULL,
	Name1 NVARCHAR(150) NULL ,
	Operator NVARCHAR(300) NULL,
	CheckIfEntityOnProject BIT NULL,
	CheckIfAnswerComplete BIT NULL,
	CheckIfAnswerNULL BIT NULL,
	ShowProjectQuestionFilter BIT NULL,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_EntitySearchOperator_Ident ON EntitySearchOperator(Ident) --NO FILL FACTOR FOR IDENTITY DATA TYPE
GO

CREATE NONCLUSTERED INDEX idx_EntitySearchOperator_EntitySearchDataTypeIdent ON dbo.EntitySearchOperator(EntitySearchDataTypeIdent)
GO

INSERT INTO EntitySearchOperator(
	EntitySearchDataTypeIdent,
	Name1,
	Operator,
	CheckIfEntityOnProject,
	CheckIfAnswerComplete,
	CheckIfAnswerNULL,
	ShowProjectQuestionFilter,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)

-- PROJECT WIDE
SELECT
	EntitySearchDataTypeIdent = 0,
	Name1 = 'Entity Is On Project',
	Operator = '',
	CheckIfEntityOnProject = 1,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

-- NUMBER
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 1,
	Name1 = 'Greater Than',
	Operator = 'TRY_CAST(ColumnValue AS DECIMAL(20,4)) > @nvrSearch',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 1,
	Name1 = 'Greater Than / Equal To',
	Operator = 'TRY_CAST(ColumnValue AS DECIMAL(20,4)) >= @nvrSearch',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 1,
	Name1 = 'Equal To',
	Operator = 'TRY_CAST(ColumnValue AS DECIMAL(20,4)) = @nvrSearch',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 1,
	Name1 = 'Not Equal To',
	Operator = 'TRY_CAST(ColumnValue AS DECIMAL(20,4)) <> @nvrSearch',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 1,
	Name1 = 'Less Than',
	Operator = 'TRY_CAST(ColumnValue AS DECIMAL(20,4)) < @nvrSearch',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 1,
	Name1 = 'Less Than / Equal To',
	Operator = 'TRY_CAST(ColumnValue AS DECIMAL(20,4)) <= @nvrSearch',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 1,
	Name1 = 'Did Not Answer',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 1,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 1,
	Name1 = 'Answered Question',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 1,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

-- TEXT
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 2,
	Name1 = 'Is Exactly',
	Operator = 'ColumnValue = @nvrSearch',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 2,
	Name1 = 'Contains',
	Operator = 'ColumnValue LIKE ''%'' + @nvrSearch + ''%''',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 2,
	Name1 = 'Does Not Contain',
	Operator = 'ColumnValue NOT LIKE ''%'' + @nvrSearch + ''%''',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 2,
	Name1 = 'Starts With',
	Operator = 'LEFT(ColumnValue,@intSearchLength) = @nvrSearch',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 2,
	Name1 = 'Ends With',
	Operator = 'RIGHT(ColumnValue,@intSearchLength) = @nvrSearch',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 2,
	Name1 = 'Did Not Answer',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 1,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 2,
	Name1 = 'Answered Question',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 1,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

-- DATE
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 3,
	Name1 = 'Prior To',
	Operator = 'TRY_CAST(LEFT(ColumnValue,10) AS DATE) < TRY_CAST(@nvrSearch AS DATE)',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 3,
	Name1 = 'After',
	Operator = 'TRY_CAST(LEFT(ColumnValue,10) AS DATE) > TRY_CAST(@nvrSearch AS DATE)',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 3,
	Name1 = 'Equal To',
	Operator = 'TRY_CAST(LEFT(ColumnValue,10) AS DATE) = TRY_CAST(@nvrSearch AS DATE)',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 3,
	Name1 = 'Not Equal To',
	Operator = 'TRY_CAST(LEFT(ColumnValue,10) AS DATE) <> TRY_CAST(@nvrSearch AS DATE)',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 3,
	Name1 = 'Before Today',
	Operator = 'TRY_CAST(LEFT(ColumnValue,10) AS DATE) < CAST(dbo.ufnGetMyDate() AS DATE)',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 3,
	Name1 = 'After Today',
	Operator = 'TRY_CAST(LEFT(ColumnValue,10) AS DATE) > CAST(dbo.ufnGetMyDate() AS DATE)',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 3,
	Name1 = 'Equal To Today',
	Operator = 'TRY_CAST(LEFT(ColumnValue,10) AS DATE) = CAST(dbo.ufnGetMyDate() AS DATE)',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 3,
	Name1 = 'Did Not Answer',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 1,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 3,
	Name1 = 'Answered Question',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 1,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

-- OPTIONS/LIST
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 4,
	Name1 = 'Selected One of the Values',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 4,
	Name1 = 'Selected All of the Values',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 4,
	Name1 = 'Did Not Select This/These Values',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 4,
	Name1 = 'Did Not Answer',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 1,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 4,
	Name1 = 'Answered Question',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 1,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

-- BIT
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 5,
	Name1 = 'Is Yes',
	Operator = 'ColumnValue = ''Yes''',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 5,
	Name1 = 'Is No',
	Operator = 'ColumnValue = ''No''',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 5,
	Name1 = 'Is N/A',
	Operator = 'ColumnValue = ''N/A''',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 0 -- deleted for now, we didnt go through with this as an option
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 5,
	Name1 = 'Did Not Answer',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 1,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 5,
	Name1 = 'Answered Question',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 1,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

-- FILE
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 6,
	Name1 = 'Contains File',
	Operator = 'ColumnValue <> ''''',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 0
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 6,
	Name1 = 'Did Not Answer',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 1,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 6,
	Name1 = 'Answered Question',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 1,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

-- HOURS OF OPERATION
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 7,
	Name1 = 'Is Open at this Date/Time',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 7,
	Name1 = 'Is Open Today',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 7,
	Name1 = 'Did Not Answer',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 1,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 7,
	Name1 = 'Answered Question',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 1,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

-- ADDRESS
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 8,
	Name1 = 'Address is Equal To',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 8,
	Name1 = 'Address is Not Equal To',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 8,
	Name1 = 'Address Contains',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 8,
	Name1 = 'City is Equal To',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 8,
	Name1 = 'City is Not Equal To',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 8,
	Name1 = 'State is Equal To',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 8,
	Name1 = 'State is Not Equal To',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 8,
	Name1 = 'Zip is Equal To',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 8,
	Name1 = 'Zip is Not Equal To',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 8,
	Name1 = 'Did Not Answer',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 1,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 8,
	Name1 = 'Answered Question',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 1,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 3,
	Name1 = 'Within X Days from Today',
	Operator = 'TRY_CAST(LEFT(ColumnValue,10) AS DATE) BETWEEN CAST(dbo.ufnGetMyDate() AS DATE) AND CAST(DATEADD(DD, CAST(@nvrSearch AS INT), dbo.ufnGetMyDate()) AS DATE)',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 3,
	Name1 = 'Within X Days prior to Today',
	Operator = 'TRY_CAST(LEFT(ColumnValue,10) AS DATE) BETWEEN CAST(DATEADD(DD, (CAST(@nvrSearch AS INT) * -1), dbo.ufnGetMyDate()) AS DATE) AND CAST(dbo.ufnGetMyDate() AS DATE)',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

-- EMAIL
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 9,
	Name1 = 'Is Exactly',
	Operator = 'Email = @nvrSearch',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 9,
	Name1 = 'Contains',
	Operator = 'Email LIKE + ''%''@nvrSearch + ''%''',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 9,
	Name1 = 'Does Not Contain',
	Operator = 'Email NOT LIKE + ''%''@nvrSearch + ''%''',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 9,
	Name1 = 'Starts With',
	Operator = 'LEFT(Email,@intSearchLength) = @nvrSearch',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 9,
	Name1 = 'Ends With',
	Operator = 'RIGHT(Email,@intSearchLength) = @nvrSearch',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 1,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 9,
	Name1 = 'No Email on File',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 1,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 9,
	Name1 = 'Has Email on File',
	Operator = '',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 1,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
UNION ALL
SELECT
	EntitySearchDataTypeIdent = 9,
	Name1 = 'Has Opted-Out of Emails',
	Operator = 'Verified = 1 AND Notify = 0',
	CheckIfEntityOnProject = 0,
	CheckIfAnswerComplete = 0,
	CheckIfAnswerNULL = 0,
	ShowProjectQuestionFilter = 0,
	AddASUserIdent = 0,
	AddDateTime = GETDATE(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

GO