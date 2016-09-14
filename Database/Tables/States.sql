IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'States') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE States
GO

CREATE TABLE States (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	Name1 NVARCHAR(75) NULL ,
	Desc1 NVARCHAR(200) NULL ,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL ,
	LockSessionIdent BIGINT NULL ,
	LockTime SMALLDATETIME NULL 
)

CREATE UNIQUE CLUSTERED INDEX idx_States_Ident ON States(Ident) 
GO
CREATE NONCLUSTERED INDEX idx_States_Name1 ON States(Name1) 
GO

SET IDENTITY_INSERT States ON

INSERT INTO States (
	Ident ,
	Name1 ,
	Desc1 ,
	AddASUserIdent ,
	AddDateTime ,
	EditASUserIdent ,
	EditDateTime ,
	Active ,
	LockSessionIdent ,
	LockTime 
)
SELECT
	0 ,
	'' ,
	'' ,
	0 ,
	'01/01/1900' ,
	0 ,
	'01/01/1900' ,
	1 ,
	0 ,
	'01/01/1900' 
UNION ALL 
	SELECT 1, 'NY' , 'New York' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 2, 'AL' , 'Alabama' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 3, 'AK' , 'Alaska' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 4, 'AZ' , 'Arizona' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 5, 'AR' , 'Arkansas' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 6, 'CA' , 'California' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 7, 'CO' , 'Colorado' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 8, 'CT' , 'Connecticut' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 9, 'DE' , 'Delaware' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 10, 'DC' , 'District of Columbia' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 11, 'FL' , 'Florida' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 12, 'GA' , 'Georgia' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 13, 'HI' , 'Hawaii' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 14, 'ID' , 'Idaho' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 15, 'IL' , 'Illinois' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 16, 'IN' , 'Indiana' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 17, 'IA' , 'Iowa' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 18, 'KS' , 'Kansas' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 19, 'KY' , 'Kentucky' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 20, 'LA' , 'Louisiana' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 21, 'ME' , 'Maine' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 22, 'MD' , 'Maryland' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 23, 'MA' , 'Massachusetts' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 24, 'MI' , 'Michigan' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 25, 'MN' , 'Minnesota' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 26, 'MS' , 'Mississippi' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 27, 'MO' , 'Missouri' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 28, 'MT' , 'Montana' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 29, 'NE' , 'Nebraska' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 30, 'NV' , 'Nevada' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 31, 'NH' , 'New Hampshire' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 32, 'NJ' , 'New Jersey' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 33, 'NM' , 'New Mexico' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 35, 'NC' , 'North Carolina' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 36, 'ND' , 'North Dakota' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 37, 'OH' , 'Ohio' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 38, 'OK' , 'Oklahoma' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 39, 'OR' , 'Oregon' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 40, 'PA' , 'Pennsylvania' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 41, 'RI' , 'Rhode Island' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 42, 'SC' , 'South Carolina' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 43, 'SD' , 'South Dakota' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 44, 'TN' , 'Tennessee' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 45, 'TX' , 'Texas' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 46, 'UT' , 'Utah' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 47, 'VT' , 'Vermont' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 48, 'VA' , 'Virginia' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 49, 'WA' , 'Washington' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 50, 'WV' , 'West Virginia' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 51, 'WI' , 'Wisconsin' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 52, 'WY' , 'Wyoming' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 66, 'AS' , 'American Samoa' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 67, 'FM' , 'Federated States of Micronesia' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 68, 'GM' , 'Guam' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 69, 'MH' , 'Marshall Islands' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 70, 'MP' , 'Northern Mariana Islands' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 71, 'PW' , 'Palau' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 72, 'VI' , 'Virgin Islands' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 73, 'AE' , 'Armed Forces Europe, the Middle East, and Canada' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 74, 'AP' , 'Armed Forces Pacific' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 75, 'AA' , 'Armed Forces Americas (except Canada)' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
UNION ALL 
	SELECT 76, 'PR' , 'Puerto Rico' , 0 , '01/01/1900' , 0 , '01/01/1900' , 1 , 0 , '01/01/1900' 
	
SET IDENTITY_INSERT States OFF

GO 
SELECT * FROM States