IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnCalculateGeoLocationDistance') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnCalculateGeoLocationDistance
GO
/* ufnCalculateFileSize
 *
 *	takes 2 sets of lat/long and calculates distance in miles
 *
 */
CREATE FUNCTION ufnCalculateGeoLocationDistance(@decSourceLatitude AS DECIMAL(20,8), @decSourceLongitude AS DECIMAL(20,8), @decDestLatitude AS DECIMAL(20,8), @decDestLongitude AS DECIMAL(20,8))

	RETURNS DECIMAL(20,8)
	
 BEGIN

	RETURN (3959 * ACOS(COS(RADIANS(@decSourceLatitude)) * COS(RADIANS(@decDestLatitude)) * COS(RADIANS(@decDestLongitude) - RADIANS(@decSourceLongitude)) + SIN(RADIANS(@decSourceLatitude)) * SIN(RADIANS(@decDestLatitude))))
	
 END

GO
