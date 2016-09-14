IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspCheckProjectGUIDForOpenRegistration') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspCheckProjectGUIDForOpenRegistration
GO
/********************************************************
 * This procedure will check an incoming GUID to whether
 *  the project allows open reg, is active and not archived
 *
 *	uspCheckProjectGUIDForOpenRegistration 
 *
 ********************************************************/
 
CREATE PROCEDURE uspCheckProjectGUIDForOpenRegistration

	@vcrGuid VARCHAR(MAX)

AS
	
	SELECT
		EP.Ident,
		EP.Name1,
		EP.EntityIdent,
		E.Fullname AS [Customer]
	FROM
		EntityProject EP WITH (NOLOCK)
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = EP.EntityIdent
	WHERE
		EP.ProjectGUID = @vcrGuid
		AND EP.Active = 1
		AND EP.Archived = 0
		AND EP.AllowOpenRegistration = 1
		AND E.Active = 1
		AND E.Customer = 1 -- make sure the customer is in good standing

GO