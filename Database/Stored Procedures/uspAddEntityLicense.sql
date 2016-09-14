IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddEntityLicense') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspAddEntityLicense
 GO
/* uspAddEntityLicense
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspAddEntityLicense]

	@intEntityIdent BIGINT = 0, 
	@intStatesIdent BIGINT = 0, 
	@nvrLicenseNumber NVARCHAR(MAX) = '', 
	@sdtLicenseNumberExpirationDate SMALLDATETIME = '1/1/1900', 
	@intAddASUserIdent BIGINT = 0, 
	@bitActive BIT = False

AS

	SET NOCOUNT ON

	INSERT INTO EntityLicense (
		EntityIdent, 
		StatesIdent, 
		LicenseNumber, 
		LicenseNumberExpirationDate, 
		AddASUserIdent, 
		AddDateTime, 
		EditASUserIdent, 
		EditDateTime, 
		Active
	) 
	SELECT 
		EntityIdent = @intEntityIdent, 
		StatesIdent = @intStatesIdent, 
		LicenseNumber = @nvrLicenseNumber, 
		LicenseNumberExpirationDate = @sdtLicenseNumberExpirationDate, 
		AddASUserIdent = @intAddASUserIdent, 
		AddDateTime = dbo.ufnGetMyDate(), 
		EditASUserIdent = 0, 
		EditDateTime = '1/1/1900', 
		Active = @bitActive

	SELECT SCOPE_IDENTITY() AS [Ident]

GO