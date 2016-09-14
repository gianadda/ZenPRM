IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityProjectByEntityIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityProjectByEntityIdent
GO

/* uspGetEntityProjectByEntityIdent 306489, 306489
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetEntityProjectByEntityIdent]

	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT

AS


	SET NOCOUNT ON
	
	DECLARE @bitEntityIsCustomer BIT
	SET @bitEntityIsCustomer = 0

	--Verify it's a customer
	SELECT
		@bitEntityIsCustomer = E.Customer
	FROM
		Entity E WITH (NOLOCK)
	WHERE 
		E.Ident = @bntEntityIdent
		AND (@bntEntityIdent = @bntASUserIdent) -- should only be a customer if its their projects
		
	IF (@bitEntityIsCustomer = 1)
	BEGIN 
		EXEC uspGetEntityProjectByEntityIdentForCustomer @bntEntityIdent, @bntASUserIdent
	END 
	ELSE
	BEGIN
		EXEC uspGetEntityProjectByEntityIdentForNonCustomer @bntEntityIdent, @bntASUserIdent
	END

GO

-- EXEC uspGetEntityProjectByEntityIdent 2, 2