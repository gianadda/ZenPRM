IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspUpdateEntityLatitudeLongitude') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspUpdateEntityLatitudeLongitude
GO
/********************************************************													
 *
 *	uspUpdateEntityLatitudeLongitude 
 *
 ********************************************************/
 
CREATE PROCEDURE uspUpdateEntityLatitudeLongitude

	@vcrPrimaryAddress1 NVARCHAR(MAX),
    @vcrPrimaryCity NVARCHAR(MAX),
    @intPrimaryStateIdent BIGINT,
    @vcrPrimaryZip NVARCHAR(MAX),
    @decLatitude DECIMAL(20,8),
    @decLongitude DECIMAL(20,8)

AS

	DECLARE @geoLocation AS GEOGRAPHY = GEOGRAPHY::Point(@decLatitude, @decLongitude, 4326)
	
	-- were updating entities by address so that we can group by address and process duplicates
	-- this was tested against 16k records and no indexes. 35 ms exec time. not ready to scale for production
	UPDATE
		Entity
	SET
		Latitude = @decLatitude,
		Longitude = @decLongitude,
		GeoLocation = @geoLocation,
		GeocodingStatusIdent = CASE @decLatitude
								WHEN 0.0 THEN 2 -- failure
								ELSE 1 -- success
							   END
	WHERE
		PrimaryAddress1 = @vcrPrimaryAddress1
		AND PrimaryCity = @vcrPrimaryCity
		AND PrimaryStateIdent = @intPrimaryStateIdent
		AND LEFT(PrimaryZip,5) = LEFT(@vcrPrimaryZip,5)
	
GO