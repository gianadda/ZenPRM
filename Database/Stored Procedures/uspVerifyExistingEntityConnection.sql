IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspVerifyExistingEntityConnection') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspVerifyExistingEntityConnection
GO
/********************************************************												
 *
 *	uspVerifyExistingEntityConnection 
 *
 ********************************************************/
 
CREATE PROCEDURE uspVerifyExistingEntityConnection

	@bntFromEntityIdent BIGINT,
	@bntToEntityIdent BIGINT,
	@bitDelegate BIT

AS

	SELECT
		EC.Ident
	FROM
		EntityConnection EC WITH (NOLOCK)
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.Ident = @bntToEntityIdent
		INNER JOIN
		ConnectionType CT WITH (NOLOCK)
			ON CT.Ident = EC.ConnectionTypeIdent
			AND CT.ToEntityTypeIdent = E.EntityTypeIdent
	WHERE
		EC.FromEntityIdent = @bntFromEntityIdent
		AND EC.ToEntityIdent = @bntToEntityIdent
		AND CT.Delegate = @bitDelegate
		AND EC.Active = 1
	
GO