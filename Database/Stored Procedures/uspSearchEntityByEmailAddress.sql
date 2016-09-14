IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspSearchEntityByEmailAddress') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspSearchEntityByEmailAddress
GO

/* uspSearchEntityByEmailAddress
 *
 * Advanced search
 *
 *
*/
CREATE PROCEDURE uspSearchEntityByEmailAddress

	@nvrEmailAddress NVARCHAR(MAX)

AS

	SET NOCOUNT ON

	SELECT
		E.Ident,
		E.FirstName,
		E.LastName,
		EE.Email,
		E.Registered AS [AlreadyRegistered]
	FROM
		Entity E WITH (NOLOCK)
		INNER JOIN
		EntityEmail EE WITH (NOLOCK)
			ON EE.EntityIdent = E.Ident
	WHERE
		E.Active = 1
		AND EE.Active = 1
		AND EE.Email = @nvrEmailAddress

GO

/**************************

exec uspSearchEntityByEmailAddress
			@nvrEmailAddress = 'marra@ahealthtech.com'

**************************/
