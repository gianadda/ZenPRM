IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspEditEntityLicenseByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspEditEntityLicenseByIdent
 GO
/* uspEditEntityLicenseByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspEditEntityLicenseByIdent]

	@intIdent BIGINT, 
	@intEntityIdent BIGINT, 
	@intStatesIdent BIGINT, 
	@nvrLicenseNumber NVARCHAR(MAX), 
	@sdtLicenseNumberExpirationDate SMALLDATETIME, 
	@intEditASUserIdent BIGINT, 
	@bitActive BIT

AS

	SET NOCOUNT ON

	UPDATE EntityLicense
	SET 
		EntityIdent = @intEntityIdent, 
		StatesIdent = @intStatesIdent, 
		LicenseNumber = @nvrLicenseNumber, 
		LicenseNumberExpirationDate = @sdtLicenseNumberExpirationDate, 
		EditASUserIdent = @intEditASUserIdent, 
		EditDateTime = dbo.ufnGetMyDate(), 
		Active = @bitActive
	WHERE
		Ident = @intIdent

	SELECT @intIdent as [Ident]

GO