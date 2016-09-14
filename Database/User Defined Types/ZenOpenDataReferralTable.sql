IF NOT (SELECT TYPE_ID(N'ZenOpenDataReferralTable')) IS NULL
	BEGIN
		DROP TYPE ZenOpenDataReferralTable
	END
GO
	CREATE TYPE ZenOpenDataReferralTable AS TABLE 
	(
		NPI NVARCHAR(10),
		ReferredTo BIT,
		SharedTransactionCount BIGINT,
		PatientTotal BIGINT,
		SameDayTotal BIGINT
	)

GO