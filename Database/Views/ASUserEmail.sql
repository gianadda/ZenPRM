IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'ASUserEmail') 
	AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP View ASUserEmail
GO

CREATE VIEW ASUserEmail 

AS 

	SELECT DISTINCT
		E.Ident as [ASUserIdent],
		'' as [Email]
	FROM
		Entity E WITH (NOLOCK)
	EXCEPT 
	SELECT DISTINCT
		EE.EntityIdent  as [ASUserIdent],
		'' as [Email]
	FROM
		EntityEmail EE WITH (NOLOCK)
	WHERE 
		EE.Active = 1
	UNION ALL
	SELECT DISTINCT
		EE.EntityIdent as [ASUserIdent],
		EE.Email
	FROM
		EntityEmail EE WITH (NOLOCK)
	WHERE
		EE.Active = 1

GO
