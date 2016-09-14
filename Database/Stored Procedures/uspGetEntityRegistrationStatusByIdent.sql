IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityRegistrationStatusByIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityRegistrationStatusByIdent
GO

/* uspGetEntityRegistrationStatusByIdent
 *
 * Returns Entity Registration Status based on Ident
 *
 *
*/
CREATE PROCEDURE uspGetEntityRegistrationStatusByIdent

	@bntEntityIdent BIGINT

AS

	SET NOCOUNT ON

	SELECT
		E.Ident,
		E.FirstName,
		E.LastName,
		E.Registered as [AlreadyRegistered]
	FROM
		Entity E WITH (NOLOCK)
	WHERE
		E.Active = 1
		AND E.Ident = @bntEntityIdent

	SELECT
		EE.Ident,
		EE.EntityIdent,
		EE.Email,
		EE.Notify,
		EE.Verified
	FROM
		EntityEmail EE WITH (NOLOCK)
	WHERE
		EE.Active = 1
		AND EE.EntityIdent = @bntEntityIdent

GO

/**************************

exec uspGetEntityRegistrationStatusByIdent
			@bntEntityIdent = 306487

**************************/
