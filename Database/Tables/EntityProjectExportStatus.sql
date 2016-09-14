IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityProjectExportStatus') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityProjectExportStatus

GO

CREATE TABLE EntityProjectExportStatus (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	Name1 NVARCHAR(150) NULL ,
	Desc1 NVARCHAR(500) NULL ,
	Downloadable BIT NULL,
	ProcessFile BIT NULL,
	PercentComplete INT NULL,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_EntityProjectExportStatus_Ident ON dbo.EntityProjectExportStatus(Ident) 
GO

SET IDENTITY_INSERT dbo.EntityProjectExportStatus ON

INSERT INTO EntityProjectExportStatus(
	Ident,
	Name1,
	Desc1,
	Downloadable,
	ProcessFile,
	PercentComplete,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	Ident = 0,
	Name1 = 'Queued',
	Desc1 = 'Project has been exported but no processing has started',
	Downloadable = 0,
	ProcessFile = 1,
	PercentComplete = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

INSERT INTO EntityProjectExportStatus(
	Ident,
	Name1,
	Desc1,
	Downloadable,
	ProcessFile,
	PercentComplete,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	Ident = 1,
	Name1 = 'Generating CSV',
	Desc1 = 'Export process is generating the project CSV which contains all entity answers',
	Downloadable = 0,
	ProcessFile = 1,
	PercentComplete = 10,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

INSERT INTO EntityProjectExportStatus(
	Ident,
	Name1,
	Desc1,
	Downloadable,
	ProcessFile,
	PercentComplete,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	Ident = 2,
	Name1 = 'Generating Files (@@NumberOfFilesGenerated of @@NumberOfFilesAttached)',
	Desc1 = 'CSV file has been generated and now the process is generating all attached files',
	Downloadable = 0,
	ProcessFile = 1,
	PercentComplete = 30,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

INSERT INTO EntityProjectExportStatus(
	Ident,
	Name1,
	Desc1,
	Downloadable,
	ProcessFile,
	PercentComplete,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	Ident = 3,
	Name1 = 'Compressing Files',
	Desc1 = 'All project files are generated and now the process is compressing them into a single ZIP file',
	Downloadable = 0,
	ProcessFile = 1,
	PercentComplete = 75,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

INSERT INTO EntityProjectExportStatus(
	Ident,
	Name1,
	Desc1,
	Downloadable,
	ProcessFile,
	PercentComplete,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	Ident = 4,
	Name1 = 'Cleaning Up Temp Files',
	Desc1 = 'The archiving process is complete and now we are cleaning up any generated files (other than the zip)',
	Downloadable = 0,
	ProcessFile = 1,
	PercentComplete = 95,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

INSERT INTO EntityProjectExportStatus(
	Ident,
	Name1,
	Desc1,
	Downloadable,
	ProcessFile,
	PercentComplete,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	Ident = 5,
	Name1 = 'Ready to Download',
	Desc1 = 'The export process is complete and the ZIP file is ready to download',
	Downloadable = 1,
	ProcessFile = 0,
	PercentComplete = 100,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

INSERT INTO EntityProjectExportStatus(
	Ident,
	Name1,
	Desc1,
	Downloadable,
	ProcessFile,
	PercentComplete,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	Ident = 6,
	Name1 = 'Error - Unable to Generate File',
	Desc1 = 'The process was not able to complete successfully',
	Downloadable = 0,
	ProcessFile = 0,
	PercentComplete = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
	
INSERT INTO EntityProjectExportStatus(
	Ident,
	Name1,
	Desc1,
	Downloadable,
	ProcessFile,
	PercentComplete,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	Ident = 7,
	Name1 = 'Error - No project answers / data to generate',
	Desc1 = 'The process was not able to complete successfully because the project has no data to generate',
	Downloadable = 0,
	ProcessFile = 0,
	PercentComplete = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

SET IDENTITY_INSERT dbo.EntityProjectExportStatus OFF