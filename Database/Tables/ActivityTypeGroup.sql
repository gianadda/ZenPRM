IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ActivityTypeGroup') and 
	OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE ActivityTypeGroup
GO
CREATE TABLE ActivityTypeGroup(
	Ident BIGINT IDENTITY(1,1) NOT NULL,
	Name1 NVARCHAR(500) NULL,
	Desc1 NVARCHAR(MAX) NULL,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)
GO 

CREATE UNIQUE CLUSTERED INDEX idx_ActivityTypeGroup_Ident ON ActivityTypeGroup(Ident)
GO

INSERT INTO ActivityTypeGroup(
	Name1,
	Desc1,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	Name1 = 'Change Password',
	Desc1 = '',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	Name1 = 'Network',
	Desc1 = '',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	Name1 = 'Delegation',
	Desc1 = '',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	Name1 = 'Interactions',
	Desc1 = '',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 0

UNION ALL
SELECT
	Name1 = 'Login',
	Desc1 = '',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	Name1 = 'Login Failed',
	Desc1 = '',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	Name1 = 'Logout',
	Desc1 = '',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	Name1 = 'Registration',
	Desc1 = '',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	Name1 = 'Profile changed',
	Desc1 = '',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	Name1 = 'Project Answer Submission',
	Desc1 = '',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	Name1 = 'Tickets',
	Desc1 = '',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	Name1 = 'Project Changes',
	Desc1 = '',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	Name1 = 'Dials',
	Desc1 = '',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	Name1 = 'Segments',
	Desc1 = '',
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
		
GO