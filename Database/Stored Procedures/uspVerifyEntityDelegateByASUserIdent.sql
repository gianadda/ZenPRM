IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspVerifyEntityDelegateByASUserIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspVerifyEntityDelegateByASUserIdent
GO

/* uspVerifyEntityDelegateByASUserIdent 
 *
 *  This proc is used to determine if the delegation relationship exists for the
 *  user attempting to switch context to
 *
*/
CREATE PROCEDURE uspVerifyEntityDelegateByASUserIdent

	@bntASUserIdent BIGINT,
	@bntEntityIdent BIGINT

AS

	SET NOCOUNT ON

	SELECT 
		EC.Ident
	FROM 
		ConnectionType CT WITH (NOLOCK)
		INNER JOIN
		EntityConnection EC WITH (NOLOCK)
			ON CT.Ident = EC.ConnectionTypeIdent
		INNER JOIN
		Entity fromE WITH (NOLOCK)
			ON EC.FromEntityIdent = fromE.Ident
				AND CT.FromEntityTypeIdent = fromE.EntityTypeIdent
		INNER JOIN
		Entity toE WITH (NOLOCK)
			ON EC.ToEntityIdent = toE.Ident
				AND CT.ToEntityTypeIdent = toE.EntityTypeIdent
	WHERE 
		CT.IncludeInNetwork = 0 -- Don't include network links
		AND CT.Delegate = 1
		AND EC.Active = 1
		AND CT.Active = 1
		AND fromE.Ident = @bntEntityIdent
		AND toE.Ident = @bntASUserIdent
	UNION ALL
	SELECT 
		1 as [EntityConnectionIdent]
	FROM
		ZenTeam toE WITH (NOLOCK)
		INNER JOIN
		ConnectionType CT WITH (NOLOCK)
			ON CT.ToEntityTypeIdent= toE.EntityTypeIdent
		INNER JOIN
		Customer fromE WITH (NOLOCK)
			ON CT.FromEntityTypeIdent = fromE.EntityTypeIdent
	WHERE 
		CT.IncludeInNetwork = 0 -- Don't include network links
		AND CT.Delegate = 1
		AND fromE.Ident = @bntEntityIdent
		AND toE.Ident = @bntASUserIdent
		AND fromE.Active = 1
		AND fromE.Customer = 1 

GO