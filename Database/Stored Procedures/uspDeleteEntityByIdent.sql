IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspDeleteEntityByIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspDeleteEntityByIdent
GO

/* uspDeleteEntityByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE uspDeleteEntityByIdent

	@bntEntityIdent BIGINT,
	@bntEditASUserIdent BIGINT,
	@bitSuppressOutput BIT

AS

	SET NOCOUNT ON

	-- deactivate the entity Record
	UPDATE
		Entity
	SET
		Active = 0,
		EditASUserIdent = @bntEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()
	WHERE
		Ident = @bntEntityIdent
		AND Active = 1

	-- deactivate the connections 
	UPDATE
		EntityConnection
	SET
		Active = 0,
		EditASUserIdent = @bntEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()
	WHERE
		FromEntityIdent = @bntEntityIdent
		AND Active = 1

	UPDATE
		EntityConnection
	SET
		Active = 0,
		EditASUserIdent = @bntEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()
	WHERE
		ToEntityIdent = @bntEntityIdent
		AND Active = 1

	-- deactivate the degrees
	UPDATE
		EntityDegreeXref
	SET
		Active = 0,
		EditASUserIdent = @bntEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()
	WHERE
		EntityIdent = @bntEntityIdent
		AND Active = 1

	-- deactivate the email addresses
	UPDATE
		EntityEmail
	SET
		Active = 0,
		EditASUserIdent = @bntEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()
	WHERE
		EntityIdent = @bntEntityIdent
		AND Active = 1

	-- deactivate the hierarchy
	UPDATE
		EntityHierarchy
	SET
		Active = 0,
		EditASUserIdent = @bntEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()		
	WHERE
		FromEntityIdent = @bntEntityIdent
		AND Active = 1

	UPDATE
		EntityHierarchy
	SET
		Active = 0,
		EditASUserIdent = @bntEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()		
	WHERE
		ToEntityIdent = @bntEntityIdent
		AND Active = 1

	-- deactivate the interactions
	UPDATE
		EntityInteraction
	SET
		Active = 0,
		EditASUserIdent = @bntEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()	
	WHERE
		FromEntityIdent = @bntEntityIdent
		AND Active = 1

	UPDATE
		EntityInteraction
	SET
		Active = 0,
		EditASUserIdent = @bntEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()	
	WHERE
		ToEntityIdent = @bntEntityIdent
		AND Active = 1

	-- deactivate the languages
	UPDATE
		EntityLanguage1Xref
	SET
		Active = 0,
		EditASUserIdent = @bntEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()	
	WHERE
		EntityIdent = @bntEntityIdent
		AND Active = 1

	-- deactivate the licenses
	UPDATE
		EntityLicense
	SET
		Active = 0,
		EditASUserIdent = @bntEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()	
	WHERE
		EntityIdent = @bntEntityIdent
		AND Active = 1

	-- deactivate the other IDs
	UPDATE
		EntityOtherID
	SET
		Active = 0,
		EditASUserIdent = @bntEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()	
	WHERE
		EntityIdent = @bntEntityIdent
		AND Active = 1

	-- deactivate the payors
	UPDATE
		EntityPayorXref
	SET
		Active = 0,
		EditASUserIdent = @bntEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()	
	WHERE
		EntityIdent = @bntEntityIdent
		AND Active = 1

	-- deactivate the services
	UPDATE
		EntityServices1Xref
	SET
		Active = 0,
		EditASUserIdent = @bntEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()
	WHERE
		EntityIdent = @bntEntityIdent
		AND Active = 1

	-- deactivate the systems
	UPDATE
		EntitySystem
	SET
		Active = 0,
		EditASUserIdent = @bntEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()
	FROM
		EntitySystem WITH (NOLOCK)
	WHERE
		EntityIdent = @bntEntityIdent
		AND Active = 1

	-- deactivate the taxonomies
	UPDATE
		EntityTaxonomyXref
	SET
		Active = 0,
		EditASUserIdent = @bntEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()
	WHERE
		EntityIdent = @bntEntityIdent
		AND Active = 1

	-- deactivate the external logins 
	UPDATE
		EntityExternalLogin
	SET
		Active = 0,
		EditASUserIdent = @bntEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()
	WHERE
		EntityIdent = @bntEntityIdent
		AND Active = 1

	-- deactivate project records
	UPDATE
		EntityProjectEntity
	SET
		Active = 0,
		EditASUserIdent = @bntEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()
	WHERE
		EntityIdent = @bntEntityIdent
		AND Active = 1

	-- final check to make sure no data remains
	IF (@bitSuppressOutput = 0)
		BEGIN

			SELECT
				Ident,
				'Entity' as [TableName]
			FROM
				Entity WITH (NOLOCK)
			WHERE
				Ident = @bntEntityIdent
				AND Active = 1
			UNION ALL
			SELECT
				Ident,
				'EntityConnection' as [TableName]
			FROM
				EntityConnection WITH (NOLOCK)
			WHERE
				FromEntityIdent = @bntEntityIdent
				AND Active = 1
			UNION ALL
			SELECT
				Ident,
				'EntityConnection' as [TableName]
			FROM
				EntityConnection WITH (NOLOCK)
			WHERE
				ToEntityIdent = @bntEntityIdent
				AND Active = 1
			UNION ALL
			SELECT
				Ident,
				'EntityDegreeXref' as [TableName]
			FROM
				EntityDegreeXref WITH (NOLOCK)
			WHERE
				EntityIdent = @bntEntityIdent
				AND Active = 1
			UNION ALL
			SELECT
				Ident,
				'EntityEmail' as [TableName]
			FROM
				EntityEmail WITH (NOLOCK)
			WHERE
				EntityIdent = @bntEntityIdent
				AND Active = 1
			UNION ALL
			SELECT
				Ident,
				'EntityHierarchy' as [TableName]
			FROM
				EntityHierarchy WITH (NOLOCK)
			WHERE
				FromEntityIdent = @bntEntityIdent
				AND Active = 1
			UNION ALL
			SELECT
				Ident,
				'EntityHierarchy' as [TableName]
			FROM
				EntityHierarchy WITH (NOLOCK)
			WHERE
				ToEntityIdent = @bntEntityIdent
				AND Active = 1
			UNION ALL
			SELECT
				Ident,
				'EntityInteraction' as [TableName]
			FROM
				EntityInteraction WITH (NOLOCK)
			WHERE
				FromEntityIdent = @bntEntityIdent
				AND Active = 1
			UNION ALL
			SELECT
				Ident,
				'EntityInteraction' as [TableName]
			FROM
				EntityInteraction WITH (NOLOCK)
			WHERE
				ToEntityIdent = @bntEntityIdent
				AND Active = 1
			UNION ALL
			SELECT
				Ident,
				'EntityLanguage1Xref' as [TableName]
			FROM
				EntityLanguage1Xref WITH (NOLOCK)
			WHERE
				EntityIdent = @bntEntityIdent
				AND Active = 1
			UNION ALL
			SELECT
				Ident,
				'EntityLicense' as [TableName]
			FROM
				EntityLicense WITH (NOLOCK)
			WHERE
				EntityIdent = @bntEntityIdent
				AND Active = 1
			UNION ALL
			SELECT
				Ident,
				'EntityOtherID' as [TableName]
			FROM
				EntityOtherID WITH (NOLOCK)
			WHERE
				EntityIdent = @bntEntityIdent
				AND Active = 1
			UNION ALL
			SELECT
				Ident,
				'EntityPayorXref' as [TableName]
			FROM
				EntityPayorXref WITH (NOLOCK)
			WHERE
				EntityIdent = @bntEntityIdent
				AND Active = 1
			UNION ALL
			SELECT
				Ident,
				'EntityServices1Xref' as [TableName]
			FROM
				EntityServices1Xref WITH (NOLOCK)
			WHERE
				EntityIdent = @bntEntityIdent
				AND Active = 1
			UNION ALL
			SELECT
				Ident,
				'EntitySystem' as [TableName]
			FROM
				EntitySystem WITH (NOLOCK)
			WHERE
				EntityIdent = @bntEntityIdent
				AND Active = 1
			UNION ALL
			SELECT
				Ident,
				'EntityTaxonomyXref' as [TableName]
			FROM
				EntityTaxonomyXref WITH (NOLOCK)
			WHERE
				EntityIdent = @bntEntityIdent
				AND Active = 1
			UNION ALL
			SELECT
				Ident,
				'EntityExternalLogin' as [TableName]
			FROM
				EntityExternalLogin WITH (NOLOCK)
			WHERE
				EntityIdent = @bntEntityIdent
				AND Active = 1
			UNION ALL
			SELECT
				Ident,
				'EntityProjectEntity' as [TableName]
			FROM
				EntityProjectEntity WITH (NOLOCK)
			WHERE
				EntityIdent = @bntEntityIdent
				AND Active = 1

		END

GO