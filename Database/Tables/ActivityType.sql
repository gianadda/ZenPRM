IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ActivityType') and 
	OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE ActivityType
GO
CREATE TABLE ActivityType(
	Ident BIGINT IDENTITY(1,1) NOT NULL,
	ActivityGroupIdent BIGINT NULL,
	Name1 NVARCHAR(500) NULL,
	Desc1 NVARCHAR(MAX) NULL,
	TableName NVARCHAR(500) NULL,
	EventType NVARCHAR(50) NULL,
	ShowToCustomer BIT NULL,
	CustomerSpecific BIT NULL,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)
GO 

CREATE UNIQUE CLUSTERED INDEX idx_ActivityType_Ident ON ActivityType(Ident)
GO

CREATE INDEX idx_ActivityType_ActivityGroupIdent ON ActivityType(ActivityGroupIdent) 
GO

INSERT INTO ActivityType(
	ActivityGroupIdent,
	Name1,
	Desc1,
	TableName,
	EventType,
	ShowToCustomer,
	CustomerSpecific,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	ActivityGroupIdent = 5,
	Name1 = 'Login',
	Desc1 = '@@Name has logged into ZenPRM.',
	TableName = '',
	EventType = '',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 7,
	Name1 = 'Logout',
	Desc1 = '@@Name has logged out of ZenPRM.',
	TableName = '',
	EventType = '',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 3,
	Name1 = 'Login As Delegate',
	Desc1 = '@@Name has switched context to work as @@Delegate.',
	TableName = '',
	EventType = '',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 3,
	Name1 = 'Logout As Delegate',
	Desc1 = '@@Name has ended their delegate session.',
	TableName = '',
	EventType = '',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Edit Profile',
	Desc1 = '@@Name has updated @@Entity profile.',
	TableName = 'Entity',
	EventType = 'Edit',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 10,
	Name1 = 'Completed Requirement',
	Desc1 = '@@Name supplied @@Number requirement(s) for the project @@ProjectName @@OnBehalfOfEntity.',
	TableName = 'EntityProjectEntityAnswerValue',
	EventType = 'Add',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Add Profile',
	Desc1 = '@@Name has added @@Entity profile.',
	TableName = 'Entity',
	EventType = 'Add',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 2,
	Name1 = 'Add Entity Network',
	Desc1 = '@@Name has added @@ToEntity to @@FromEntity.',
	TableName = 'EntityConnection',
	EventType = 'Add',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
	
UNION ALL
SELECT
	ActivityGroupIdent = 2,
	Name1 = 'Delete Entity Network',
	Desc1 = '@@Name has removed @@ToEntity from @@FromEntity.',
	TableName = 'EntityConnection',
	EventType = 'Delete',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

	
UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Add Entity Taxonomy',
	Desc1 = '@@Name has added @@Taxonomy to @@Entity profile.',
	TableName = 'EntityTaxonomyXRef',
	EventType = 'Add',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
	
UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Delete Entity Taxonomy',
	Desc1 = '@@Name has removed @@Taxonomy from @@Entity profile.',
	TableName = 'EntityTaxonomyXRef',
	EventType = 'Delete',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

	
UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Add Entity System',
	Desc1 = '@@Name has added @@System to @@Entity profile.',
	TableName = 'EntitySystem',
	EventType = 'Add',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Edit Entity System',
	Desc1 = '@@Name has edited @@System for @@Entity profile.',
	TableName = 'EntitySystem',
	EventType = 'Edit',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
	
UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Delete Entity System',
	Desc1 = '@@Name has removed @@System from @@Entity profile.',
	TableName = 'EntitySystem',
	EventType = 'Delete',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

	
UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Add Entity Specialty',
	Desc1 = '@@Name has added @@Specialty to @@Entity profile.',
	TableName = 'EntitySpecialityXRef',
	EventType = 'Add',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 0
	
UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Delete Entity Specialty',
	Desc1 = '@@Name has removed @@Specialty from @@Entity profile.',
	TableName = 'EntitySpecialityXRef',
	EventType = 'Delete',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 0

	
UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Add Entity Service',
	Desc1 = '@@Name has added @@Service to @@Entity profile.',
	TableName = 'EntityServices1XRef',
	EventType = 'Add',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
	
UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Delete Entity Service',
	Desc1 = '@@Name has removed @@Service from @@Entity profile.',
	TableName = 'EntityServices1XRef',
	EventType = 'Delete',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Add Entity Payor',
	Desc1 = '@@Name has added @@Payor to @@Entity profile.',
	TableName = 'EntityPayorXRef',
	EventType = 'Add',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
	
UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Delete Entity Payor',
	Desc1 = '@@Name has removed @@Payor from @@Entity profile.',
	TableName = 'EntityPayorXRef',
	EventType = 'Delete',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Add Entity Other ID',
	Desc1 = '@@Name has added @@OtherID to @@Entity profile.',
	TableName = 'EntityOtherID',
	EventType = 'Add',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Edit Entity Other ID',
	Desc1 = '@@Name has edited @@OtherID for @@Entity profile.',
	TableName = 'EntityOtherID',
	EventType = 'Edit',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
	
UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Delete Entity Other ID',
	Desc1 = '@@Name has removed @@OtherID from @@Entity profile.',
	TableName = 'EntityOtherID',
	EventType = 'Delete',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Add Entity License',
	Desc1 = '@@Name has added license # @@License to @@Entity profile.',
	TableName = 'EntityLicense',
	EventType = 'Add',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Edit Entity License',
	Desc1 = '@@Name has edited license # @@License for @@Entity profile.',
	TableName = 'EntityLicense',
	EventType = 'Edit',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
	
UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Delete Entity License',
	Desc1 = '@@Name has removed license # @@License from @@Entity profile.',
	TableName = 'EntityLicense',
	EventType = 'Delete',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Add Entity Language',
	Desc1 = '@@Name has added the language @@Language to @@Entity profile.',
	TableName = 'EntityLanguage1XRef',
	EventType = 'Add',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
	
UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Delete Entity Language',
	Desc1 = '@@Name has removed the language @@Language from @@Entity profile.',
	TableName = 'EntityLanguage1XRef',
	EventType = 'Delete',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
	
UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Add Entity Degree',
	Desc1 = '@@Name has added the degree @@Degree to @@Entity profile.',
	TableName = 'EntityDegreeXRef',
	EventType = 'Add',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
	
UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Delete Entity Degree',
	Desc1 = '@@Name has removed the degree @@Degree from @@Entity profile.',
	TableName = 'EntityDegreeXRef',
	EventType = 'Delete',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 12,
	Name1 = 'Add Entity Project',
	Desc1 = '@@Name has added project @@Project.',
	TableName = 'EntityProject',
	EventType = 'Add',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
	
UNION ALL
SELECT
	ActivityGroupIdent = 12,
	Name1 = 'Archive Entity Project',
	Desc1 = '@@Name has archived project @@Project.',
	TableName = 'EntityProject',
	EventType = 'Edit',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 12,
	Name1 = 'Restore Entity Project',
	Desc1 = '@@Name has restored archived project @@Project.',
	TableName = 'EntityProject',
	EventType = 'Edit',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 12,
	Name1 = 'Delete Entity Project',
	Desc1 = '@@Name has deleted project @@Project.',
	TableName = 'EntityProject',
	EventType = 'Delete',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Add Entity Email',
	Desc1 = '@@Name has added @@Email to @@Entity profile.',
	TableName = 'EntityEmail',
	EventType = 'Add',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Edit Entity Email',
	Desc1 = '@@Name has edited @@Email for @@Entity profile.',
	TableName = 'EntityEmail',
	EventType = 'Edit',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Delete Entity Email',
	Desc1 = '@@Name has removed @@Email from @@Entity profile.',
	TableName = 'EntityEmail',
	EventType = 'Delete',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Add Entity Project Entity',
	Desc1 = '@@Name has added @@EntityProjectEntity to project @@Project.',
	TableName = 'EntityProjectEntity',
	EventType = 'Add',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
	
UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Delete Entity Project Entity',
	Desc1 = '@@Name has removed @@EntityProjectEntity from project @@Project.',
	TableName = 'EntityProjectEntity',
	EventType = 'Delete',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 12,
	Name1 = 'Delete Entity File Repository',
	Desc1 = '@@Name has removed the file @@FileName from @@Entity repository.',
	TableName = 'EntityFileRepository',
	EventType = 'Delete',
	ShowToCustomer = 0,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 1,
	Name1 = 'Change Password',
	Desc1 = '@@Name has changed their password.',
	TableName = 'Entity',
	EventType = 'Edit',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 8,
	Name1 = 'Completed Registration',
	Desc1 = '@@Name has completed registration and is now able to access ZenPRM.',
	TableName = 'ASUser',
	EventType = 'Edit',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 11,
	Name1 = 'Add Ticket',
	Desc1 = '@@Name has added ticket @@ToDo for @@Entity.',
	TableName = 'EntityToDo',
	EventType = 'Add',
	ShowToCustomer = 1, -- we add blank records by default, so this doesnt make sense in the logs right now
	CustomerSpecific = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 11,
	Name1 = 'Edit Ticket',
	Desc1 = '@@Name has changed the status of ticket @@ToDo for @@Entity.',
	TableName = 'EntityToDo',
	EventType = 'Edit',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 11,
	Name1 = 'Delete Ticket',
	Desc1 = '@@Name has deleted ticket @@ToDo for @@Entity.',
	TableName = 'EntityToDo',
	EventType = 'Delete',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 1,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 12,
	Name1 = 'Add Entity Project Requirement',
	Desc1 = '@@Name has added @@RequirementName for @@EntityProject.',
	TableName = 'EntityProjectRequirement',
	EventType = 'Add',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 12,
	Name1 = 'Edit Entity Project Requirement',
	Desc1 = '@@Name has edited @@RequirementName for @@EntityProject.',
	TableName = 'EntityProjectRequirement',
	EventType = 'Edit',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1
	
UNION ALL
SELECT
	ActivityGroupIdent = 12,
	Name1 = 'Delete Entity Project Requirement',
	Desc1 = '@@Name has removed @@RequirementName for @@EntityProject.',
	TableName = 'EntityProjectRequirement',
	EventType = 'Delete',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Add Note',
	Desc1 = '@@Name has added a note for @@EntityName.',
	TableName = 'EntityInteraction',
	EventType = 'Add',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Edit Note',
	Desc1 = '@@Name has edited a note for @@EntityName.',
	TableName = 'EntityInteraction',
	EventType = 'Edit',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 9,
	Name1 = 'Delete Note',
	Desc1 = '@@Name has deleted a note for @@EntityName.',
	TableName = 'EntityInteraction',
	EventType = 'Delete',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 6,
	Name1 = 'Login Failed',
	Desc1 = '@@Name has failed to log into ZenPRM.',
	TableName = '',
	EventType = '',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 6,
	Name1 = 'User Account Locked',
	Desc1 = '@@Name has locked their account and cannot log into ZenPRM (unlocks after 5 minutes).',
	TableName = '',
	EventType = '',
	ShowToCustomer = 1,
	CustomerSpecific = 0,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 11,
	Name1 = 'Assigned Ticket',
	Desc1 = '@@Name has assigned ticket @@ToDo to @@ASUser.',
	TableName = 'EntityToDo',
	EventType = 'Edit',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 1,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 0

UNION ALL
SELECT
	ActivityGroupIdent = 13,
	Name1 = 'Added Project Dial',
	Desc1 = '@@Name has added dial @@MeasureName1.',
	TableName = 'EntityProjectMeasure',
	EventType = 'Add',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 1,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 13,
	Name1 = 'Edited Project Dial',
	Desc1 = '@@Name has edited dial @@MeasureName1.',
	TableName = 'EntityProjectMeasure',
	EventType = 'Edit',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 1,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 13,
	Name1 = 'Deleted Project Dial',
	Desc1 = '@@Name has deleted dial @@MeasureName1.',
	TableName = 'EntityProjectMeasure',
	EventType = 'Delete',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 1,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 2,
	Name1 = 'Added Entity Hierarchy',
	Desc1 = '@@Name has added @@Person to @@Organization.',
	TableName = 'EntityHierarchy',
	EventType = 'Add',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 1,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 2,
	Name1 = 'Deleted Entity Hierarchy',
	Desc1 = '@@Name has removed @@Person from @@Organization.',
	TableName = 'EntityHierarchy',
	EventType = 'Delete',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 1,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 11,
	Name1 = 'Added Category to Ticket',
	Desc1 = '@@Name has added category @@Category to ticket @@ToDo for @@Entity.',
	TableName = 'EntityToDoEntityToDoCategoryXRef',
	EventType = 'Add',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 1,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 11,
	Name1 = 'Removed Category from Ticket',
	Desc1 = '@@Name has removed category @@Category from ticket @@ToDo for @@Entity.',
	TableName = 'EntityToDoEntityToDoCategoryXRef',
	EventType = 'Delete',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 1,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 14,
	Name1 = 'Added Entity Segment',
	Desc1 = '@@Name has added @@Segment segment.',
	TableName = 'EntitySearch',
	EventType = 'Add',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 1,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 14,
	Name1 = 'Edited Entity Segment',
	Desc1 = '@@Name has edited @@Segment segment.',
	TableName = 'EntitySearch',
	EventType = 'Edit',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 1,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

UNION ALL
SELECT
	ActivityGroupIdent = 14,
	Name1 = 'Deleted Entity Segment',
	Desc1 = '@@Name has deleted @@Segment segment.',
	TableName = 'EntitySearch',
	EventType = 'Delete',
	ShowToCustomer = 1,
	CustomerSpecific = 1,
	AddASUserIdent = 1,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 1

GO

SELECT * FROM ActivityType
GO