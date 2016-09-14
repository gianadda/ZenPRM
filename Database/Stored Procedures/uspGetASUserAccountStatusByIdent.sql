IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetASUserAccountStatusByIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetASUserAccountStatusByIdent
GO

/* uspGetASUserAccountStatusByIdent
 *
 *	TJF - This will retrieve Account Status Information, for the Modal ASUser popup
 *
 */

CREATE PROCEDURE uspGetASUserAccountStatusByIdent

	@bntASUserIdent BIGINT

AS
	
	SET NOCOUNT ON

	-- DataSet 1 - Result and Facility/CIT info
	SELECT
		U.IsLocked,
		U.LastPasswordChangedDate,
		U.LastSuccessfulLogin,
		U.AddDateTime
	FROM
		ASUser U WITH (NOLOCK)
	WHERE
		U.Ident = @bntASUserIdent

GO