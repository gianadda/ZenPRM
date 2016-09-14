IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetProfilePercentCompleteByEntityIdentAndEntityTypeIdent'))
DROP FUNCTION ufnGetProfilePercentCompleteByEntityIdentAndEntityTypeIdent
GO
/* ufnGetProfilePercentCompleteByEntityIdentAndEntityTypeIdent
 *
 *	Desc
 *
 */
CREATE FUNCTION ufnGetProfilePercentCompleteByEntityIdentAndEntityTypeIdent(@intIdent as BIGINT, @intEntityType as BIGINT)

	RETURNS INT
	
 BEGIN

	DECLARE @intFilledInCount INT
	SET @intFilledInCount = 0

	SELECT 
		@intEntityType = EntityTypeIdent
	FROM
		Entity WITH (NOLOCK)
	WHERE 
		Ident = @intIdent
		AND @intEntityType = 0

	SELECT 
		@intFilledInCount += CONVERT(INT,CONVERT(BIT,LEN(E.NPI)))
							+ CONVERT(INT,CONVERT(BIT,LEN(E.FirstName)))
							+ CONVERT(INT,IsDate(E.BirthDate))
							+ CONVERT(INT,CONVERT(BIT,LEN(E.MailingAddress1)))
							+ CONVERT(INT,CONVERT(BIT,LEN(E.PracticeAddress1)))
							+ CONVERT(INT,CONVERT(BIT,LEN(E.PrimaryPhone)))
							+ CONVERT(INT,CONVERT(BIT,LEN(E.PrimaryFax)))
							+ CONVERT(INT,CONVERT(BIT,LEN(E.DEANumber)))
							+ CONVERT(INT,IsDate(E.DEANumberExpirationDate))
							+ CONVERT(INT,CONVERT(BIT,LEN(E.PrescriptionLicenseNumber)))
							+ CONVERT(INT,IsDate(E.PrescriptionLicenseNumberExpirationDate))
							+ CONVERT(INT,CONVERT(BIT,LEN(E.MedicareUPIN)))
							+ CONVERT(INT,CONVERT(BIT,LEN(E.CAQHID)))
							+ CONVERT(INT,CONVERT(BIT,LEN(E.TaxIDNumber)))
							+ CONVERT(INT,CONVERT(BIT,E.MeaningfulUseIdent)) -- This will give a point for anything that isn't "0"
							+ CONVERT(INT,CONVERT(BIT,LEN(E.ProfilePhoto)))
	FROM	
		Entity E WITH (NOLOCK)
	WHERE 
		E.Ident =  @intIdent
		AND @intEntityType = 3 --Providers only


	SELECT 
		@intFilledInCount += CONVERT(INT,CONVERT(BIT,LEN(E.NPI)))
							+ CONVERT(INT,CONVERT(BIT,LEN(E.OrganizationName)))
							+ CONVERT(INT,CONVERT(BIT,LEN(E.TaxIDNumber)))
							+ CONVERT(INT,CONVERT(BIT,LEN(E.EIN)))
							+ CONVERT(INT,CONVERT(BIT,LEN(E.MailingAddress1)))
							+ CONVERT(INT,CONVERT(BIT,E.PCMHStatusIdent)) -- This will give a point for anything that isn't "0"
	FROM	
		Entity E WITH (NOLOCK)
	WHERE 
		E.Ident =  @intIdent
		AND @intEntityType = 2 --Organization only


	SELECT 
		@intFilledInCount += CONVERT(INT,CONVERT(BIT,COUNT(EE.EntityIdent)))
	FROM	
		EntityEmail EE WITH (NOLOCK)
	WHERE 
		EE.EntityIdent =  @intIdent
		AND EE.Active = 1
		AND @intEntityType = 3 --Providers only
		
	SELECT 
		@intFilledInCount += CONVERT(INT,CONVERT(BIT,COUNT(EL.EntityIdent)))
	FROM	
		EntityLicense EL WITH (NOLOCK)
	WHERE 
		EL.EntityIdent =  @intIdent
		AND EL.Active = 1
		AND @intEntityType = 3 --Providers only

	SELECT 
		@intFilledInCount += CONVERT(INT,CONVERT(BIT,COUNT(EC.EntityConnectionIdent)))
	FROM	
		EntityCommunity EC WITH (NOLOCK)
	WHERE 
		(EC.FromEntityIdent =  @intIdent
			OR EC.ToEntityIdent =  @intIdent)
		AND EC.Active = 1
				

	SELECT 
		@intFilledInCount += CONVERT(INT,CONVERT(BIT,COUNT(EDX.EntityIdent)))
	FROM	
		EntityDegreeXRef EDX WITH (NOLOCK)
		INNER JOIN
		Degree D WITH (NOLOCK)
			ON EDX.DegreeIdent = D.Ident
	WHERE 
		EDX.EntityIdent =  @intIdent
		AND EDX.Active = 1
		AND D.Active = 1
		AND D.Ident <> 0 -- Don't give them credit for a blank Degree (shouldn't be allowed anyway)
		AND @intEntityType = 3 --Providers only


	SELECT 
		@intFilledInCount += CONVERT(INT,CONVERT(BIT,COUNT(ELX.EntityIdent)))
	FROM	
		EntityLanguage1XRef ELX WITH (NOLOCK)
		INNER JOIN
		Language1 L WITH (NOLOCK)
			ON ELX.Language1Ident = L.Ident
	WHERE 
		ELX.EntityIdent =  @intIdent
		AND ELX.Active = 1
		AND L.Active = 1
		AND L.Ident <> 0 -- Don't give them credit for a blank Language1 (shouldn't be allowed anyway)
		AND @intEntityType = 3 --Providers only
		
	SELECT 
		@intFilledInCount += CONVERT(INT,CONVERT(BIT,COUNT(EPX.EntityIdent)))
	FROM	
		EntityPayorXRef EPX WITH (NOLOCK)
		INNER JOIN
		Payor P WITH (NOLOCK)
			ON EPX.PayorIdent = P.Ident
	WHERE 
		EPX.EntityIdent =  @intIdent
		AND EPX.Active = 1
		AND P.Active = 1
		AND P.Ident <> 0 -- Don't give them credit for a blank Language1 (shouldn't be allowed anyway)
		AND @intEntityType = 3 --Providers only
		
	SELECT 
		@intFilledInCount += CONVERT(INT,CONVERT(BIT,COUNT(ESX.EntityIdent)))
	FROM	
		EntitySpecialityXRef ESX WITH (NOLOCK)
		INNER JOIN
		Speciality S WITH (NOLOCK)
			ON ESX.SpecialityIdent = S.Ident
	WHERE 
		ESX.EntityIdent =  @intIdent
		AND ESX.Active = 1
		AND S.Active = 1
		AND S.Ident <> 0 -- Don't give them credit for a blank Language1 (shouldn't be allowed anyway)
		AND @intEntityType = 3 --Providers only


	SELECT 
		@intFilledInCount += CONVERT(INT,CONVERT(BIT,COUNT(ESX.EntityIdent)))
	FROM	
		EntityServices1XRef ESX WITH (NOLOCK)
		INNER JOIN
		Services1 S WITH (NOLOCK)
			ON ESX.Services1Ident = S.Ident
	WHERE 
		ESX.EntityIdent =  @intIdent
		AND ESX.Active = 1
		AND S.Active = 1
		AND S.Ident <> 0 -- Don't give them credit for a blank Services1 (shouldn't be allowed anyway)
		AND @intEntityType = 2 --Organization only
		
		
	SELECT 
		@intFilledInCount += CONVERT(INT,CONVERT(BIT,COUNT(ETX.EntityIdent)))
	FROM	
		EntityTaxonomyXRef ETX WITH (NOLOCK)
		INNER JOIN
		Taxonomy T WITH (NOLOCK)
			ON ETX.TaxonomyIdent = T.Ident
	WHERE 
		ETX.EntityIdent =  @intIdent
		AND ETX.Active = 1
		AND T.Active = 1
		AND T.Ident <> 0 -- Don't give them credit for a blank Services1 (shouldn't be allowed anyway)
		AND @intEntityType = 2 --Organization only
		
	SELECT 
		@intFilledInCount += CONVERT(INT,CONVERT(BIT,COUNT(ES.EntityIdent)))
	FROM	
		EntitySystem ES WITH (NOLOCK)
	WHERE 
		ES.EntityIdent =  @intIdent
		AND ES.Active = 1
		AND @intEntityType = 2 --Organization only
		
	SELECT 
		@intFilledInCount += CONVERT(INT,CONVERT(BIT,COUNT(EO.EntityIdent)))
	FROM	
		EntityOtherID EO WITH (NOLOCK)
	WHERE 
		EO.EntityIdent =  @intIdent
		AND EO.Active = 1
		AND @intEntityType = 2 --Organization only


	--Provider gets 23
	--Organizations gets 12

	SELECT 
		@intFilledInCount = CASE @intEntityType
								WHEN 3 THEN CONVERT(INT, @intFilledInCount * 100) / 23 -- PROVIDER
								WHEN 2 THEN CONVERT(INT, @intFilledInCount * 100) / 11 -- ORGANIZATION
								ELSE 100
							END 

	RETURN @intFilledInCount
	
 END

GO

SELECT
 dbo.ufnGetProfilePercentCompleteByEntityIdentAndEntityTypeIdent(506, 0)
 