IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityAuditHistoryByEntityIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityAuditHistoryByEntityIdent
GO

/* uspGetEntityAuditHistoryByEntityIdent
 *
 *	
 *
 */

CREATE PROCEDURE uspGetEntityAuditHistoryByEntityIdent

	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT

AS
	
	SET NOCOUNT ON

	DECLARE @intActivityTypeEditProfileIdent BIGINT
	DECLARE @intActivityTypeAddProfileIdent BIGINT
	
	SET @intActivityTypeEditProfileIdent = dbo.ufnActivityTypeEditProfile()
	SET @intActivityTypeAddProfileIdent  = dbo.ufnActivityTypeAddProfile()

	CREATE TABLE #tmpActivityTypeRecordIdents (
		RecordIdent BIGINT,
		TableName NVARCHAR(1000)
	)

	INSERT INTO #tmpActivityTypeRecordIdents (
		RecordIdent ,
		TableName 
	)
	SELECT 
		@bntEntityIdent,
		'Entity'
	UNION ALL
	SELECT 
		Ident,
		'EntityDegreeXRef'
	FROM
		EntityDegreeXRef tbl WITH (NOLOCK)
	WHERE 
		tbl.EntityIdent = @bntEntityIdent
	UNION ALL
	SELECT 
		Ident,
		'EntityEmail'
	FROM
		EntityEmail tbl WITH (NOLOCK)
	WHERE 
		tbl.EntityIdent = @bntEntityIdent
	UNION ALL
	SELECT 
		Ident,
		'EntityLanguage1XRef'
	FROM
		EntityLanguage1XRef tbl WITH (NOLOCK)
	WHERE 
		tbl.EntityIdent = @bntEntityIdent
	UNION ALL
	SELECT 
		Ident,
		'EntityLicense'
	FROM
		EntityLicense tbl WITH (NOLOCK)
	WHERE 
		tbl.EntityIdent = @bntEntityIdent
	UNION ALL
	SELECT 
		Ident,
		'EntityOtherID'
	FROM
		EntityOtherID tbl WITH (NOLOCK)
	WHERE 
		tbl.EntityIdent = @bntEntityIdent
	UNION ALL
	SELECT 
		Ident,
		'EntityPayorXRef'
	FROM
		EntityPayorXRef tbl WITH (NOLOCK)
	WHERE 
		tbl.EntityIdent = @bntEntityIdent
	UNION ALL
	SELECT 
		Ident,
		'EntityProject'
	FROM
		EntityProject tbl WITH (NOLOCK)
	WHERE 
		tbl.EntityIdent = @bntEntityIdent
	UNION ALL
	SELECT 
		Ident,
		'EntityServices1XRef'
	FROM
		EntityServices1XRef tbl WITH (NOLOCK)
	WHERE 
		tbl.EntityIdent = @bntEntityIdent
	UNION ALL
	SELECT 
		Ident,
		'EntitySpecialityXRef'
	FROM
		EntitySpecialityXRef tbl WITH (NOLOCK)
	WHERE 
		tbl.EntityIdent = @bntEntityIdent
	UNION ALL
	SELECT 
		Ident,
		'EntitySystem'
	FROM
		EntitySystem tbl WITH (NOLOCK)
	WHERE 
		tbl.EntityIdent = @bntEntityIdent
	UNION ALL
	SELECT 
		Ident,
		'EntityTaxonomyXRef'
	FROM
		EntityTaxonomyXRef tbl WITH (NOLOCK)
	WHERE 
		tbl.EntityIdent = @bntEntityIdent

	SELECT
		AUA.Ident,
		AUA.ASUserIdent,
		U.FullName as [Author],
		AUA.ActivityTypeIdent,
		AUA.ActivityDateTime,
		AUA.ActivityDescription,
		AUA.ClientIPAddress,
		AUA.RecordIdent,
		AT.Name1,
		AT.Desc1,
		AT.TableName,
		AT.EventType,
		AT.ShowToCustomer,
		COALESCE(AUAD.Ident, 0) as [ASUserActivityDetail],
		COALESCE(AUAD.ASUserActivityIdent, 0) as [ASUserActivityIdent],
		COALESCE(AUAD.FieldName, '') as [FieldName],
		COALESCE(AUAD.OldValue,'') as [OldValue],
		COALESCE(AUAD.NewValue, '') as [NewValue]
	FROM
		ASUserActivity AUA WITH (NOLOCK)
		INNER JOIN
		ActivityType AT WITH (NOLOCK)
			ON AUA.ActivityTypeIdent = AT.Ident
		INNER JOIN
		ASUser U WITH (NOLOCK)
			ON U.Ident = AUA.ASUserIdent
		INNER JOIN
		#tmpActivityTypeRecordIdents tAR WITH (NOLOCK)
			ON tAR.TableName = AT.TableName
		LEFT OUTER JOIN
		ASUserActivityDetail AUAD WITH (NOLOCK)
			ON AUA.Ident = AUAD.ASUserActivityIdent
	WHERE 
		AT.ShowToCustomer = 1
		AND (COALESCE(AUAD.OldValue,'') <> COALESCE(AUAD.NewValue, '') OR COALESCE(AUAD.OldValue,'') = '')
		AND AUA.UpdatedEntityIdent = @bntEntityIdent -- only bring back records where the edited entity is the entity we are searching for
	ORDER BY 
		AUA.Ident DESC

	DROP TABLE #tmpActivityTypeRecordIdents
		
GO

-- uspGetEntityAuditHistoryByEntityIdent 306486, 2