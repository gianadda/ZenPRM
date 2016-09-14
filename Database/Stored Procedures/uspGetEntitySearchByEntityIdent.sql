IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntitySearchByEntityIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetEntitySearchByEntityIdent
 GO
/* uspGetEntitySearchByEntityIdent
 *
 * returns all of an entities saved searches
 *
 *
*/
CREATE PROCEDURE uspGetEntitySearchByEntityIdent

	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT

AS

	SET NOCOUNT ON

	CREATE TABLE #tmpEntitySearchFilter(
		Ident BIGINT,
		EntitySearchIdent BIGINT,
		EntitySearchFilterTypeIdent BIGINT,
		EntitySearchOperatorIdent BIGINT,
		EntitySearchOperatorName1 NVARCHAR(150),
		EntityProjectRequirementIdent BIGINT,
		EntityProjectRequirementName1 NVARCHAR(MAX),
		ReferenceIdent BIGINT,
		ReferenceName1 NVARCHAR(MAX),
		SearchValue NVARCHAR(MAX)
	)

	SELECT 
		Ident,
		EntityIdent,
		Name1,
		Desc1,
		Category,
		BookmarkSearch,
		Keyword,
		Location,
		Latitude,
		Longitude,
		DistanceInMiles
	FROM
		EntitySearch WITH (NOLOCK)
	WHERE
		EntityIdent = @bntEntityIdent
		AND Active = 1
	ORDER BY
		Name1 ASC

	INSERT INTO #tmpEntitySearchFilter(
		Ident,
		EntitySearchIdent,
		EntitySearchFilterTypeIdent,
		EntitySearchOperatorIdent,
		EntitySearchOperatorName1,
		EntityProjectRequirementIdent,
		EntityProjectRequirementName1,
		ReferenceIdent,
		ReferenceName1,
		SearchValue
	)
	SELECT
		ESF.Ident,
		ESF.EntitySearchIdent,
		ESF.EntitySearchFilterTypeIdent,
		ESF.EntitySearchOperatorIdent,
		'',
		ESF.EntityProjectRequirementIdent,
		'',
		ESF.ReferenceIdent,
		'',
		ESF.SearchValue
	FROM
		EntitySearchFilter ESF WITH (NOLOCK)
		INNER JOIN
		EntitySearch ES WITH (NOLOCK)
			ON ES.Ident = ESF.EntitySearchIdent
	WHERE
		ES.EntityIdent = @bntEntityIdent
		AND ES.Active = 1
		AND ESF.Active = 1

	-- these are completed outside the initial insert because
	-- the joins may fail
	UPDATE
		tESF
	SET
		EntityProjectRequirementName1 = EPR.label
	FROM
		#tmpEntitySearchFilter tESF WITH (NOLOCK)
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.Ident = tESF.EntityProjectRequirementIdent
	WHERE
		tESF.EntityProjectRequirementIdent > 0

	UPDATE
		tESF
	SET
		EntitySearchOperatorName1 = ESO.Name1
	FROM
		#tmpEntitySearchFilter tESF WITH (NOLOCK)
		INNER JOIN
		EntitySearchOperator ESO WITH (NOLOCK)
			ON ESO.Ident = tESF.EntitySearchOperatorIdent
	WHERE
		tESF.EntitySearchOperatorIdent > 0

	-- or the value may have multiple references based on type
	UPDATE
		tESF
	SET
		ReferenceName1 = EP.Name1
	FROM
		#tmpEntitySearchFilter tESF WITH (NOLOCK)
		INNER JOIN
		EntitySearchFilterType ESFT WITH (NOLOCK)
			ON ESFT.Ident = tESF.EntitySearchFilterTypeIdent
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = tESF.ReferenceIdent
	WHERE
		tESF.ReferenceIdent > 0
		AND ESFT.ProjectSpecific = 1

	SELECT
		Ident,
		EntitySearchIdent,
		EntitySearchFilterTypeIdent,
		EntitySearchOperatorIdent,
		EntitySearchOperatorName1,
		EntityProjectRequirementIdent,
		EntityProjectRequirementName1,
		ReferenceIdent,
		ReferenceName1,
		SearchValue
	FROM
		#tmpEntitySearchFilter WITH (NOLOCK)
	ORDER BY
		EntitySearchIdent ASC,
		EntityProjectRequirementName1 ASC

	DROP TABLE #tmpEntitySearchFilter

GO