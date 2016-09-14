IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspCheckASUserUsernameUnique') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspCheckASUserUsernameUnique
GO
/********************************************************												
 *
 *	uspCheckASUserUsernameUnique 
 *
 ********************************************************/
 
CREATE PROCEDURE uspCheckASUserUsernameUnique

	@vcrUsername NVARCHAR(75)
AS
	
	IF EXISTS (
		SELECT 1 
		FROM 
			ASUser WITH (NOLOCK)
		WHERE 
			Username = @vcrUsername
			AND Active = 1
	)
	BEGIN
		SELECT 0
	END
	ELSE 
	BEGIN
		SELECT 1 
	END 

GO