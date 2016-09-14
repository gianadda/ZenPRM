IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetAllActiveEntityWithoutGeocodes') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspGetAllActiveEntityWithoutGeocodes
 GO
/* uspGetAllActiveEntityWithoutGeocodes
 *
 *
 *
 *
*/
CREATE PROCEDURE uspGetAllActiveEntityWithoutGeocodes

AS

	SET NOCOUNT ON

	DECLARE @intProcessCount INT
	SET @intProcessCount = 10

	CREATE TABLE #tmpEntities(
		EntityIdent BIGINT,
		CustomerResource BIT
	)

	INSERT INTO #tmpEntities(
		EntityIdent,
		CustomerResource
	)
	SELECT TOP (@intProcessCount)
		E.Ident,
		1
	FROM
		Customer C WITH (NOLOCK)
		INNER JOIN
		EntityNetwork EN WITH (NOLOCK)
			ON EN.FromEntityIdent = C.Ident
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = EN.ToEntityIdent
	WHERE
		E.Active = 1
		AND E.GeocodingStatusIdent = 0
		AND E.PrimaryAddress1 <> ''
	UNION
	SELECT TOP (@intProcessCount)
		E.Ident,
		0
	FROM
		Entity E WITH (NOLOCK)
	WHERE
		E.Active = 1
		AND E.GeocodingStatusIdent = 0
		AND E.PrimaryAddress1 <> ''

	SELECT TOP (@intProcessCount) -- complete is small batches so Google Maps doesnt block us
		E.PrimaryAddress1,
		E.PrimaryCity,
		E.PrimaryStateIdent,
		S.Name1 as [PrimaryState],
		LEFT(E.PrimaryZip,5) as [PrimaryZip]
	FROM
		#tmpEntities tE WITH (NOLOCK)
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = tE.EntityIdent
		INNER JOIN
		States S WITH (NOLOCK)
			ON S.Ident = E.PrimaryStateIdent
	GROUP BY
		E.PrimaryAddress1,
		E.PrimaryCity,
		E.PrimaryStateIdent,
		S.Name1,
		LEFT(E.PrimaryZip,5),
		tE.CustomerResource
	ORDER BY
		CustomerResource DESC

	DROP TABLE #tmpEntities

GO