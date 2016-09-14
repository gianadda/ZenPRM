IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetMyDate') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnGetMyDate
GO
/*

	select dbo.ufnGetMyDate()

	get the correct time zone from GETDATE
	
*/

CREATE FUNCTION ufnGetMyDate()

	RETURNS DATETIME

AS

	BEGIN
		
		RETURN DATEADD(hh, -4, GETUTCDATE())

	END

GO