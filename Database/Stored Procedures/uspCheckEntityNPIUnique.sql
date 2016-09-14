IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspCheckEntityNPIUnique') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspCheckEntityNPIUnique
GO
/********************************************************												
 *
 *	uspCheckEntityNPIUnique 
 *
 ********************************************************/
 
CREATE PROCEDURE uspCheckEntityNPIUnique

	@intIdent BIGINT,
	@vcrNPI VARCHAR(MAX)

AS
	
	IF EXISTS (
		SELECT 1 
		FROM 
			Entity WITH (NOLOCK)
		WHERE 
			NPI = @vcrNPI
			AND Active = 1
			AND Ident <> @intIdent
			AND @vcrNPI <> ''
	)
	BEGIN
		SELECT 0
	END
	ELSE 
	BEGIN
		SELECT 1 
	END 

GO