IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspCreateEntityCustomImportMapByEntityProjectIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspCreateEntityCustomImportMapByEntityProjectIdent
 GO
/* uspCreateEntityCustomImportMapByEntityProjectIdent
 *
 * 
 *
 *
*/
CREATE PROCEDURE uspCreateEntityCustomImportMapByEntityProjectIdent

	@intEntityIdent BIGINT,
	@ncrImportUID NVARCHAR(MAX)

AS

	INSERT INTO EntityCustomImportMap (
		EntityProjectRequirementIdent,
		DataSchema,
		ImportUID
	)
	SELECT 
		'EntityProjectRequirementIdent' = EPR.Ident,
		'DataSchema' = CASE EPR.RequirementTypeIdent 
							WHEN 2 THEN '"@@Text"' -- Text 
							WHEN 3 THEN '"@@Paragraph"' -- Paragraph
							WHEN 4 THEN '"@@Date"' -- Date 
							WHEN 5 THEN '{  
										  "@@MultipleChoice1":false,
										  "@@MultipleChoice2":false,
										  "@@MultipleChoice3":false
									   }' -- Multiple Choice - Option 1|Option 2|Option 3
							WHEN 6 THEN '"@@SingleChoice"' -- Single Choice - Option 1|Option 2|Option 3
							WHEN 7 THEN '"@@Dropdown"' -- Dropdown - Option 1|Option 2|Option 3
							WHEN 8 THEN '@@Number' -- Number 
							WHEN 9 THEN '@@ToggleSwitch' -- Toggle Switch 
							WHEN 11 THEN '[  
											  {  
												 "name":"@@Tags1"
											  },
											  {  
												 "name":"@@Tags2"
											  }
										   ]' -- Tags - Option 1|Option 2|Option 3
							WHEN 12 THEN '{  
											  "Address1":"@@Address1",
											  "Address2":"@@Address2",
											  "Address3":"@@Address3",
											  "City":"@@City",
											  "StateIdent":@@StateIdent,
											  "Zip":"@@ZipCode"
										   }' -- Address
							WHEN 13 THEN '"@@Website"' -- Website
							WHEN 14 THEN '"@@Email"' -- Email 
							WHEN 15 THEN '"@@Search"' -- Search - Option 1|Option 2|Option 3
							WHEN 16 THEN '@@Money' -- Money
							WHEN 17 THEN '"@@Slider"' -- Slider
							WHEN 18 THEN '{  
											  "StartTime":"@@StartTime",
											  "EndTime":"@@EndTime",
											  "Closed":@@Closed
										   }' -- Hours of Operation - 
							WHEN 21 THEN '"@@DateTime"' -- DateTime
						END,
		@ncrImportUID
	FROM
		EntityProjectRequirement EPR WITH (NOLOCK)
		INNER JOIN
		RequirementType RT WITH (NOLOCK)
			ON RT.Ident = EPR.RequirementTypeIdent 
	WHERE 
		EPR.EntityProjectIdent = @intEntityIdent
		AND EPR.Active = 1
		AND RT.RequiresAnswer = 1
		AND RT.IsFileUpload = 0


	SELECT * FROM EntityCustomImportMap

GO


TRUNCATE TABLE EntityCustomImportMap
EXEC uspCreateEntityCustomImportMapByEntityProjectIdent 42, 'Private Profile'
EXEC uspCreateEntityCustomImportMapByEntityProjectIdent 43, 'PPS Status'
EXEC uspCreateEntityCustomImportMapByEntityProjectIdent 44, 'PPS Priority Partner'
EXEC uspCreateEntityCustomImportMapByEntityProjectIdent 45, 'DQ Survey'






/*
EXAMPLE
   "281":"@@Text",
   "282":"@@Paragraph",
   "283":"1981-11-05 00:00:00 -0500",
   "284":{  
      "Option 1":true,
      "Option 2":true,
      "Option 3":true
   },
   "285":"Option 2",
   "286":"Option 2",
   "287":55555,
   "288":true,
   "290":[  
      {  
         "name":"Option-2"
      },
      {  
         "name":"Option-3"
      }
   ],
   "291":{  
      "Address1":"Address1",
      "Address2":"Address2",
      "Address3":"Address3",
      "City":"Buffalo",
      "StateIdent":1,
      "Zip":"14222"
   },
   "292":"http://google.com",
   "293":"gianadda@aol.com",
   "294":"Option 2",
   "295":0.11,
   "296":"11",
   "297":{  
      "StartTime":"1970-01-01 02:00:00 -0500",
      "EndTime":"1970-01-01 14:00:00 -0500",
      "Closed":true
   },
   "300":"2015-01-01 02:00:00 -0500"


  */