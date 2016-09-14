IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntitySummaryByIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntitySummaryByIdent
GO


/* uspGetEntitySummaryByIdent 306486, 306486, 306486
 *
 *
 *
 *
*/
CREATE PROCEDURE uspGetEntitySummaryByIdent

	@bntIdent BIGINT,
	@bntASUserIdent BIGINT, --Current User (i.e. Delegated)
	@bntAddEditASUserIdent BIGINT = 0 -- Logged in User (ie. Office Manager)

AS

	SET NOCOUNT ON

	
--	PRINT '1. Entity  --------------------------------------------------------------------------------------------------------------------------'	
	--1. Entity
	SELECT DISTINCT
		E.Ident,
		E.FullName,
		E.NPI,
		E.PrimaryAddress1,
		E.PrimaryAddress2,
		E.PrimaryCity,
		PrimaryState.Name1 as [PrimaryState],
		E.PrimaryZip,
		E.PrimaryPhone,
		E.PrimaryPhoneExtension,
		E.ProfilePhoto
	FROM
		Entity E WITH (NOLOCK)
		INNER JOIN
		States PrimaryState WITH (NOLOCK)
			ON E.PrimaryStateIdent = PrimaryState.Ident
	WHERE
		E.Ident = @bntIdent	
		AND E.Active = 1
GO
