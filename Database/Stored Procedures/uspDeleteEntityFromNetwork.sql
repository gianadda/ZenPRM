IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspDeleteEntityFromNetwork') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspDeleteEntityFromNetwork
 GO
/* uspDeleteEntityFromNetwork
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspDeleteEntityFromNetwork]

	@intFromEntityIdent BIGINT,
	@intToEntityIdent BIGINT

AS

	SET NOCOUNT ON
	
	DECLARE @intConnectionTypeInNetworkOfIdent AS BIGINT
	SET @intConnectionTypeInNetworkOfIdent = dbo.ufnGetConnectionTypeInNetworkOfIdent()

	UPDATE EntityConnection
	SET 
		Active = 0
	WHERE
		FromEntityIdent = @intFromEntityIdent
		AND ToEntityIdent = @intToEntityIdent
		AND ConnectionTypeIdent = @intConnectionTypeInNetworkOfIdent

	SELECT SCOPE_IDENTITY() as [Ident]
	
GO