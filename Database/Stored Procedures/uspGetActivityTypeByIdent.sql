IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetActivityTypeByIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetActivityTypeByIdent
GO

/* uspGetActivityTypeByIdent
 *
 *	This will retrieve an ActivityType record by ident
 *
 */

CREATE PROCEDURE uspGetActivityTypeByIdent

	@bntIdent BIGINT

AS
	
	SET NOCOUNT ON

	SELECT
		Ident,
		Name1,
		Desc1,
		TableName,
		EventType,
		ShowToCustomer,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	FROM
		ActivityType WITH (NOLOCK)
	WHERE 
		Ident = @bntIdent 

GO