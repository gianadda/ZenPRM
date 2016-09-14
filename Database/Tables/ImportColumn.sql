IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'ImportColumn') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE ImportColumn
GO

CREATE TABLE ImportColumn (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	Label NVARCHAR(250) NULL ,
	ColumnName NVARCHAR(250) NULL ,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_ImportColumn_Ident ON ImportColumn(Ident) --NO FILL FACTOR FOR IDENTITY DATA TYPE
GO
CREATE NONCLUSTERED INDEX idx_ImportColumn_Label ON ImportColumn(Label) 
INCLUDE (ColumnName)
GO

INSERT INTO ImportColumn(
	Label,
	ColumnName,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	Label = 'Organization Name',
	ColumnName = 'OrganizationName',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Prefix',
	ColumnName = 'Prefix',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Title',
	ColumnName = 'Title',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'First Name',
	ColumnName = 'FirstName',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Middle Name',
	ColumnName = 'MiddleName',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Last Name',
	ColumnName = 'LastName',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Suffix',
	ColumnName = 'Suffix',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Gender',
	ColumnName = 'Gender',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Birth Date',
	ColumnName = 'BirthDate',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Primary Phone Number',
	ColumnName = 'PrimaryPhone',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Secondary Phone Number',
	ColumnName = 'PrimaryPhone2',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Primary Fax Number',
	ColumnName = 'PrimaryFax',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Secondary Fax Number',
	ColumnName = 'PrimaryFax2',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Email',
	ColumnName = 'ImportEmailAddress', -- this needs to be different otherwise we break other features that use a read-only email label
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Primary Address 1',
	ColumnName = 'PrimaryAddress1',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Primary Address 2',
	ColumnName = 'PrimaryAddress2',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Primary Address 3',
	ColumnName = 'PrimaryAddress3',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Primary City',
	ColumnName = 'PrimaryCity',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Primary State',
	ColumnName = 'PrimaryState',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Primary Zip',
	ColumnName = 'PrimaryZip',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Mailing Address 1',
	ColumnName = 'MailingAddress1',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Mailing Address 2',
	ColumnName = 'MailingAddress2',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Mailing Address 3',
	ColumnName = 'MailingAddress3',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Mailing City',
	ColumnName = 'MailingCity',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Mailing State',
	ColumnName = 'MailingState',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Mailing Zip',
	ColumnName = 'MailingZip',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Practice Address 1',
	ColumnName = 'PracticeAddress1',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Practice Address 2',
	ColumnName = 'PracticeAddress2',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Practice Address 3',
	ColumnName = 'PracticeAddress3',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Practice City',
	ColumnName = 'PracticeCity',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Practice State',
	ColumnName = 'PracticeState',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1
UNION ALL
SELECT
	Label = 'Practice Zip',
	ColumnName = 'PracticeZip',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = 0,
	Active = 1

GO