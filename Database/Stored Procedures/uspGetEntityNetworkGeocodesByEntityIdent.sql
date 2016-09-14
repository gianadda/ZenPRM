IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityNetworkGeocodesByEntityIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityNetworkGeocodesByEntityIdent
GO

/* uspGetEntityNetworkGeocodesByEntityIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE uspGetEntityNetworkGeocodesByEntityIdent

	@bntEntityIdent BIGINT

AS

	SET NOCOUNT ON

	
	SELECT
		E.Ident,
		E.FullName,
		ET.Name1 as [EntityType],
		E.PrimaryAddress1,
		E.PrimaryAddress2,
		E.PrimaryAddress3,
		E.PrimaryCity,
		E.PrimaryCounty,
		E.PrimaryPhone,
		E.PrimaryPhone2,
		PS.Name1 as [PrimaryState],
		E.PrimaryZip,
		E.Website,
		E.SoleProvider,
		E.AcceptingNewPatients,
		G.Name1 as [Gender],
		E.Latitude,
		E.Longitude,
		ET.MapIconColor as [markerColor],
		'fa fa-star' as [markerIcon] -- hard code for now, we want the entity to stand out
	FROM
		Entity E WITH (NOLOCK)
		INNER JOIN
		States PS WITH (NOLOCK)
			ON PS.Ident = E.PrimaryStateIdent
		INNER JOIN
		Gender G WITH (NOLOCK)
			ON G.Ident = E.GenderIdent
		INNER JOIN
		EntityType ET WITH (NOLOCK)
			ON ET.Ident = E.EntityTypeIdent
	WHERE
		E.Ident = @bntEntityIdent
		AND E.Active = 1
	
	SELECT DISTINCT
		E.Ident,
		E.FullName,
		ET.Name1 as [EntityType],
		E.PrimaryAddress1,
		E.PrimaryAddress2,
		E.PrimaryAddress3,
		E.PrimaryCity,
		E.PrimaryCounty,
		E.PrimaryPhone,
		E.PrimaryPhone2,
		PS.Name1 as [PrimaryState],
		E.PrimaryZip,
		E.Website,
		E.SoleProvider,
		E.AcceptingNewPatients,
		G.Name1 as [Gender],
		E.Latitude,
		E.Longitude,
		ET.MapIconColor as [markerColor],
		ET.MapIcon as [markerIcon]
	FROM
		EntityNetwork EN WITH (NOLOCK)
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = EN.ToEntityIdent
		INNER JOIN
		States PS WITH (NOLOCK)
			ON PS.Ident = E.PrimaryStateIdent
		INNER JOIN
		Gender G WITH (NOLOCK)
			ON G.Ident = E.GenderIdent
		INNER JOIN
		EntityType ET WITH (NOLOCK)
			ON ET.Ident = E.EntityTypeIdent
	WHERE
		EN.Active = 1
		AND EN.FromEntityIdent = @bntEntityIdent
		AND E.Active = 1
		AND E.Latitude NOT IN (0.0, 0.1, 1.0) -- rule out all the bad import data that shouldnt be mapped
		AND E.Longitude NOT IN (0.0, 0.1, 1.0) -- rule out all the bad import data that shouldnt be mapped
	ORDER BY
		E.Fullname ASC
			
	SELECT
		Ident,
		Person,
		IncludeInCNP,
		Name1,
		MapIconColor as [markerColor],
		MapIcon as [markerIcon],
		CONVERT(BIT,1) as [selected]
	FROM
		EntityType ET WITH (NOLOCK)
	WHERE
		Active = 1
		AND Ident > 0
	ORDER BY
		Name1 ASC

GO

