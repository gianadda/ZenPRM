IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetLookupTables') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetLookupTables
GO

/* uspGetLookupTables
 *
 *	NG - Call each of the "GetAll" sps for the lookup tables in the system
 *
 */

CREATE PROCEDURE uspGetLookupTables

AS
	
	SET NOCOUNT ON

	EXEC uspGetAllActivePCMHStatus
	EXEC uspGetAllActiveTaxonomy
	EXEC uspGetAllActiveServices
	EXEC uspGetAllActivePayor
	EXEC uspGetAllActiveLanguage
	EXEC uspGetAllActiveMeaningfulUse
	EXEC uspGetAllActiveGender
	EXEC uspGetAllActiveSpeciality
	EXEC uspGetAllActiveStates
	EXEC uspGetAllActiveDegree
	EXEC uspGetAllActiveEntityType
	EXEC uspGetAllActiveConnectionType
	EXEC uspGetAllActiveInteractionType
	EXEC uspGetAllActiveSystemType
	EXEC uspGetAllActiveToDoType
	EXEC uspGetAllActiveEntitySearchDataType
	EXEC uspGetAllActiveEntitySearchFilterType
	EXEC uspGetAllActiveEntitySearchOperator
	EXEC uspGetAllActiveActivityTypeGroup
	EXEC uspGetAllActiveMeasureType
	EXEC uspGetAllActiveHierarchyType
	EXEC uspGetAllActiveToDoInitiatorType
	EXEC uspGetAllActiveToDoStatus
	EXEC uspGetAllActiveMeasureLocation

GO

-- EXEC uspGetLookupTables