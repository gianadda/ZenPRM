IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityByNPIForZenOpenDataReferrals') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityByNPIForZenOpenDataReferrals
GO

/* uspGetEntityByNPIForZenOpenDataReferrals
 *
 *	Gets the Entity data based on NPI received from the referral query
 *
 */

CREATE PROCEDURE uspGetEntityByNPIForZenOpenDataReferrals

	@bntEntityIdent BIGINT,
	@tblReferral [ZenOpenDataReferralTable] READONLY

AS
	
	SET NOCOUNT ON

	SELECT
		R.NPI,
		E.Ident,
		E.FullName,
		E.DisplayName,
		E.ProfilePhoto,
		dbo.ufnGetEntitySpecialtyListByEntityIdent(E.Ident) as [Specialty],
		CASE COALESCE(EN.EntityConnectionIdent,0)
			WHEN 0 THEN CAST(0 AS BIT)
			ELSE CAST(1 AS BIT)
		END as [InNetwork],
		R.SharedTransactionCount,
		R.PatientTotal,
		R.SameDayTotal,
		R.ReferredTo
	FROM
		@tblReferral R
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON E.NPI = R.NPI
		INNER JOIN
		EntityType ET WITH (NOLOCK)
			ON ET.Ident = E.EntityTypeIdent
		LEFT OUTER JOIN
		EntityNetwork EN WITH (NOLOCK)
			ON EN.FromEntityIdent = @bntEntityIdent
			AND EN.ToEntityIdent = E.Ident
	WHERE
		E.Active = 1
	ORDER BY
		R.SharedTransactionCount DESC,
		E.DisplayName ASC

GO