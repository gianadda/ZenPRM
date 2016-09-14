IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspMergeResourcesChildData') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspMergeResourcesChildData
GO
/********************************************************													
 *
 *	uspMergeResourcesChildData 
 *
 ********************************************************/
 
CREATE PROCEDURE uspMergeResourcesChildData

	@bntFromEntityIdent BIGINT,
	@bntToEntityIdent BIGINT,
	@bntASUserIdent BIGINT,
	@bntEditASUserIdent BIGINT

AS

		-- EntityDegreeXref
		-- EntityEmail
		-- EntityHierarchy (both directions)
		-- EntityInteraction
		-- EntityLanguage1Xref
		-- EntityLicense
		-- EntityOtherID
		-- EntityPayorXref
		-- EntityServices1Xref
		-- EntitySystem
		-- EntityTaxonomyXref

	-- EntityDegreeXref
	INSERT INTO EntityDegreeXref(
		EntityIdent,
		DegreeIdent,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT
		EntityIdent = @bntToEntityIdent,
		DegreeIdent = EDX.DegreeIdent,
		AddASUserIdent = @bntEditASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1
	FROM
		EntityDegreeXref EDX WITH (NOLOCK)
		OUTER APPLY 
		( 
		SELECT 
			Ident
		FROM 
			EntityDegreeXref oEDX WITH (NOLOCK)
		WHERE 
			oEDX.EntityIdent = @bntToEntityIdent
			AND oEDX.DegreeIdent = EDX.DegreeIdent
			AND oEDX.Active = 1
		) A 
	WHERE
		EDX.EntityIdent = @bntFromEntityIdent
		AND EDX.Active = 1
		AND COALESCE(A.Ident,0) = 0 -- and only return records where the outer apply returns NULL

	-- EntityEmail
	INSERT INTO EntityEmail(
		EntityIdent,
		Email,
		Notify,
		Verified,
		VerifiedASUserIdent,
		VerifiedDateTime,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT
		EntityIdent = @bntToEntityIdent,
		Email = EDX.Email,
		Notify = 0, -- private to public, these fields should be blank, but we need to reset anyways since this is an address that could
		Verified = 0, -- be used to log in
		VerifiedASUserIdent = 0,
		VerifiedDateTime = '1/1/1900',
		AddASUserIdent = @bntEditASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1
	FROM
		EntityEmail EDX WITH (NOLOCK)
		OUTER APPLY 
		( 
		SELECT 
			Ident
		FROM 
			EntityEmail oEDX WITH (NOLOCK)
		WHERE 
			oEDX.Email = EDX.Email -- note for the email, we just make sure it is unique in the system, and we dont worry or not it its assigned to our entity
			AND oEDX.Active = 1
			AND oEDX.EntityIdent <> @bntFromEntityIdent
		) A 
	WHERE
		EDX.EntityIdent = @bntFromEntityIdent
		AND EDX.Active = 1
		AND COALESCE(A.Ident,0) = 0 -- and only return records where the outer apply returns NULL

	-- EntityHierarchy (FROM)
	INSERT INTO EntityHierarchy(
		EntityIdent,
		HierarchyTypeIdent,
		FromEntityIdent,
		ToEntityIdent,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT
		EntityIdent = EH.EntityIdent,
		HierarchyTypeIdent = EH.HierarchyTypeIdent,
		FromEntityIdent = @bntToEntityIdent,
		ToEntityIdent = EH.ToEntityIdent,
		AddASUserIdent = @bntEditASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1
	FROM
		EntityHierarchy EH WITH (NOLOCK)
		OUTER APPLY 
		( 
		SELECT 
			Ident
		FROM 
			EntityHierarchy oEH WITH (NOLOCK)
		WHERE 
			oEH.EntityIdent = @bntASUserIdent
			AND oEH.FromEntityIdent = @bntToEntityIdent
			AND oEH.HierarchyTypeIdent = EH.HierarchyTypeIdent
			AND oEH.Active = 1
		) A 
	WHERE
		EH.EntityIdent = @bntASUserIdent
		AND EH.FromEntityIdent = @bntFromEntityIdent
		AND EH.Active = 1
		AND COALESCE(A.Ident,0) = 0 -- and only return records where the outer apply returns NULL

	-- EntityHierarchy (TO)
	INSERT INTO EntityHierarchy(
		EntityIdent,
		HierarchyTypeIdent,
		FromEntityIdent,
		ToEntityIdent,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT
		EntityIdent = EH.EntityIdent,
		HierarchyTypeIdent = EH.HierarchyTypeIdent,
		FromEntityIdent = EH.FromEntityIdent,
		ToEntityIdent = @bntToEntityIdent,
		AddASUserIdent = @bntEditASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1
	FROM
		EntityHierarchy EH WITH (NOLOCK)
		OUTER APPLY
		( 
		SELECT 
			Ident
		FROM 
			EntityHierarchy oEH WITH (NOLOCK)
		WHERE 
			oEH.EntityIdent = @bntASUserIdent
			AND oEH.ToEntityIdent = @bntToEntityIdent
			AND oEH.HierarchyTypeIdent = EH.HierarchyTypeIdent
			AND oEH.Active = 1
		) A 
	WHERE
		EH.EntityIdent = @bntASUserIdent
		AND EH.ToEntityIdent = @bntFromEntityIdent
		AND EH.Active = 1
		AND COALESCE(A.Ident,0) = 0 -- and only return records where the outer apply returns NULL

	-- EntityInteraction
	INSERT INTO EntityInteraction(
		FromEntityIdent,
		ToEntityIdent,
		InteractionText,
		Important,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT
		FromEntityIdent = EI.FromEntityIdent,
		ToEntityIdent = @bntToEntityIdent,
		InteractionText = EI.InteractionText,
		Important = EI.Important,
		AddASUserIdent = EI.AddASUserIdent,
		AddDateTime = EI.AddDateTime,
		EditASUserIdent = @bntEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate(),
		Active = 1
	FROM
		EntityInteraction EI WITH (NOLOCK)
	WHERE
		EI.FromEntityIdent = @bntASUserIdent
		AND EI.ToEntityIdent = @bntFromEntityIdent
		AND EI.Active = 1

	-- EntityLanguage1Xref
	INSERT INTO EntityLanguage1Xref(
		EntityIdent,
		Language1Ident,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT
		EntityIdent = @bntToEntityIdent,
		Language1Ident = EDX.Language1Ident,
		AddASUserIdent = @bntEditASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1
	FROM
		EntityLanguage1Xref EDX WITH (NOLOCK)
		OUTER APPLY 
		( 
		SELECT 
			Ident
		FROM 
			EntityLanguage1Xref oEDX WITH (NOLOCK)
		WHERE 
			oEDX.EntityIdent = @bntToEntityIdent
			AND oEDX.Language1Ident = EDX.Language1Ident
			AND oEDX.Active = 1
		) A 
	WHERE
		EDX.EntityIdent = @bntFromEntityIdent
		AND EDX.Active = 1
		AND COALESCE(A.Ident,0) = 0 -- and only return records where the outer apply returns NULL

	-- EntityLicense
	INSERT INTO EntityLicense(
		EntityIdent,
		StatesIdent,
		LicenseNumber,
		LicenseNumberExpirationDate,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT
		EntityIdent = @bntToEntityIdent,
		StatesIdent = EDX.StatesIdent,
		LicenseNumber = EDX.LicenseNumber,
		LicenseNumberExpirationDate = EDX.LicenseNumberExpirationDate,
		AddASUserIdent = @bntEditASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1
	FROM
		EntityLicense EDX WITH (NOLOCK)
		OUTER APPLY 
		( 
		SELECT 
			Ident
		FROM 
			EntityLicense oEDX WITH (NOLOCK)
		WHERE 
			oEDX.EntityIdent = @bntToEntityIdent
			AND oEDX.StatesIdent = EDX.StatesIdent
			AND oEDX.LicenseNumber = EDX.LicenseNumber
			AND oEDX.Active = 1
		) A 
	WHERE
		EDX.EntityIdent = @bntFromEntityIdent
		AND EDX.Active = 1
		AND COALESCE(A.Ident,0) = 0 -- and only return records where the outer apply returns NULL

	-- EntityOtherID
	INSERT INTO EntityOtherID(
		EntityIdent,
		IDType,
		IDNumber,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT
		EntityIdent = @bntToEntityIdent,
		IDType = EDX.IDType,
		IDNumber = EDX.IDNumber,
		AddASUserIdent = @bntEditASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1
	FROM
		EntityOtherID EDX WITH (NOLOCK)
		OUTER APPLY 
		( 
		SELECT 
			Ident
		FROM 
			EntityOtherID oEDX WITH (NOLOCK)
		WHERE 
			oEDX.EntityIdent = @bntToEntityIdent
			AND oEDX.IDType = EDX.IDType
			AND oEDX.IDNumber = EDX.IDNumber
			AND oEDX.Active = 1
		) A 
	WHERE
		EDX.EntityIdent = @bntFromEntityIdent
		AND EDX.Active = 1
		AND COALESCE(A.Ident,0) = 0 -- and only return records where the outer apply returns NULL

	-- EntityPayorXref
	INSERT INTO EntityPayorXref(
		EntityIdent,
		PayorIdent,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT
		EntityIdent = @bntToEntityIdent,
		PayorIdent = EDX.PayorIdent,
		AddASUserIdent = @bntEditASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1
	FROM
		EntityPayorXref EDX WITH (NOLOCK)
		OUTER APPLY 
		( 
		SELECT 
			Ident
		FROM 
			EntityPayorXref oEDX WITH (NOLOCK)
		WHERE 
			oEDX.EntityIdent = @bntToEntityIdent
			AND oEDX.PayorIdent = EDX.PayorIdent
			AND oEDX.Active = 1
		) A 
	WHERE
		EDX.EntityIdent = @bntFromEntityIdent
		AND EDX.Active = 1
		AND COALESCE(A.Ident,0) = 0 -- and only return records where the outer apply returns NULL

	-- EntityServices1Xref
	INSERT INTO EntityServices1Xref(
		EntityIdent,
		Services1Ident,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT
		EntityIdent = @bntToEntityIdent,
		Services1Ident = EDX.Services1Ident,
		AddASUserIdent = @bntEditASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1
	FROM
		EntityServices1Xref EDX WITH (NOLOCK)
		OUTER APPLY 
		( 
		SELECT 
			Ident
		FROM 
			EntityServices1Xref oEDX WITH (NOLOCK)
		WHERE 
			oEDX.EntityIdent = @bntToEntityIdent
			AND oEDX.Services1Ident = EDX.Services1Ident
			AND oEDX.Active = 1
		) A 
	WHERE
		EDX.EntityIdent = @bntFromEntityIdent
		AND EDX.Active = 1
		AND COALESCE(A.Ident,0) = 0 -- and only return records where the outer apply returns NULL

	-- EntitySystem
	INSERT INTO EntitySystem(
		EntityIdent,
		SystemTypeIdent,
		Name1,
		InstalationDate,
		GoLiveDate,
		DecomissionDate,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT
		EntityIdent = @bntToEntityIdent,
		SystemTypeIdent = EDX.SystemTypeIdent,
		Name1 = EDX.Name1,
		InstalationDate = EDX.InstalationDate,
		GoLiveDate = EDX.GoLiveDate,
		DecomissionDate = EDX.DecomissionDate,
		AddASUserIdent = @bntEditASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1
	FROM
		EntitySystem EDX WITH (NOLOCK)
		OUTER APPLY 
		( 
		SELECT 
			Ident
		FROM 
			EntitySystem oEDX WITH (NOLOCK)
		WHERE 
			oEDX.EntityIdent = @bntToEntityIdent
			AND oEDX.SystemTypeIdent = EDX.SystemTypeIdent
			AND oEDX.Name1 = EDX.Name1
			AND oEDX.Active = 1
		) A 
	WHERE
		EDX.EntityIdent = @bntFromEntityIdent
		AND EDX.Active = 1
		AND COALESCE(A.Ident,0) = 0 -- and only return records where the outer apply returns NULL

	-- EntityTaxonomyXref
	INSERT INTO EntityTaxonomyXref(
		EntityIdent,
		TaxonomyIdent,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT
		EntityIdent = @bntToEntityIdent,
		TaxonomyIdent = EDX.TaxonomyIdent,
		AddASUserIdent = @bntEditASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1
	FROM
		EntityTaxonomyXref EDX WITH (NOLOCK)
		OUTER APPLY 
		( 
		SELECT 
			Ident
		FROM 
			EntityTaxonomyXref oEDX WITH (NOLOCK)
		WHERE 
			oEDX.EntityIdent = @bntToEntityIdent
			AND oEDX.TaxonomyIdent = EDX.TaxonomyIdent
			AND oEDX.Active = 1
		) A 
	WHERE
		EDX.EntityIdent = @bntFromEntityIdent
		AND EDX.Active = 1
		AND COALESCE(A.Ident,0) = 0 -- and only return records where the outer apply returns NULL


GO