IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspUpdateEntityEntityTypeIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspUpdateEntityEntityTypeIdent
GO
/********************************************************													
 *
 *	uspUpdateEntityEntityTypeIdent 
 *
 ********************************************************/
 
CREATE PROCEDURE uspUpdateEntityEntityTypeIdent

	@bntEntityIdent BIGINT,
	@bntASUserIdent BIGINT,
	@bntEditASUserIdent BIGINT,
	@bntEntityTypeIdent BIGINT,
	@nvrNPI NVARCHAR(10)

AS

	/***

		1. Verify the entity to edit is private and in the customer's network
		2. Verify the new entity type is public
		3. If Provider, then ensure NPI is included
		4. If NPI included, if exists, merge with current profile
		5. Make sure the network is setup appropriate after the entityType change

	***/

	DECLARE @bitEntityIsPrivateResource BIT
	DECLARE @bitNewEntityTypeIsPublicResource BIT
	DECLARE @bitIsInCustomerNetwork BIT
	DECLARE @bitAccessDenied BIT
	DECLARE @intEntityTypeProviderIdent BIGINT
	DECLARE @bntToEntityIdent BIGINT

	SET @intEntityTypeProviderIdent = dbo.ufnEntityTypeProviderIdent()

	SET @bitEntityIsPrivateResource = 0
	SET @bitNewEntityTypeIsPublicResource = 0
	SET @bitIsInCustomerNetwork = 0
	SET @bitAccessDenied = 0
	SET @bntToEntityIdent = 0

	CREATE TABLE #tmpFiles(
		OldFileAnswerIdent BIGINT,
		NewFileAnswerIdent BIGINT,
		RequirementTypeIdent BIGINT
	)

	-- 1a. Verify the entity to edit is private 
	SELECT
		@bitEntityIsPrivateResource = 1
	FROM
		Entity E WITH (NOLOCK)
		INNER JOIN
		EntityType ET WITH (NOLOCK)
			ON ET.Ident = E.EntityTypeIdent
	WHERE
		E.Ident = @bntEntityIdent
		AND ET.IncludeInCNP = 0

	-- 1b. Verify the entity to edit is private and in the customer's network
	SELECT
		@bitIsInCustomerNetwork = 1
	FROM
		EntityNetwork EN WITH (NOLOCK)
	WHERE
		EN.FromEntityIdent = @bntASUserIdent
		AND EN.ToEntityIdent = @bntEntityIdent
		AND EN.Active = 1

	-- 2. Verify the new entity type is public
	SELECT
		@bitNewEntityTypeIsPublicResource = 1
	FROM
		EntityType WITH (NOLOCK)
	WHERE
		Ident = @bntEntityTypeIdent
		AND IncludeInCNP = 1

	IF (@bitEntityIsPrivateResource = 0 OR @bitIsInCustomerNetwork = 0 OR @bitNewEntityTypeIsPublicResource = 0)
		BEGIN

			SET @bitAccessDenied = 1

		END

	-- 3. If Provider, then ensure NPI is included
	IF (@bntEntityTypeIdent = @intEntityTypeProviderIdent AND @nvrNPI = '')
		BEGIN

			SET @bitAccessDenied = 1

		END

	-- 4. If NPI included, check and see if the resource already exists
	IF (@bitAccessDenied = 0 AND @bntEntityTypeIdent = @intEntityTypeProviderIdent)
		BEGIN

			SELECT
				@bntToEntityIdent = E.Ident
			FROM
				Entity E WITH (NOLOCK)
			WHERE
				E.NPI = @nvrNPI
				AND E.Active = 1

		END

	-- If NPI is included, but doesnt exist in the global registry
	IF (@bitAccessDenied = 0 AND @bntEntityTypeIdent = @intEntityTypeProviderIdent AND @bntToEntityIdent = 0)
		BEGIN

				UPDATE
					Entity
				SET
					NPI = @nvrNPI,
					EntityTypeIdent = @bntEntityTypeIdent,
					EditASUserIdent = @bntEditASUserIdent,
					EditDateTime = dbo.ufnGetMyDate()
				WHERE
					Ident = @bntEntityIdent

				-- 5. Make sure the network is setup appropriate after the entityType change
				EXEC uspAddEntityToNetwork @intFromEntityIdent = @bntASUserIdent,
										@intToEntityIdent = @bntEntityIdent,
										@intAddASUserIdent = @bntEditASUserIdent,
										@bitActive = 1,
										@bitSuppressOutput = 1

		END


	-- If NPI is included, and the NPI is found in the global list, then merge the accounts
	IF (@bitAccessDenied = 0 AND @bntEntityTypeIdent = @intEntityTypeProviderIdent AND @bntToEntityIdent > 0)
		BEGIN

			-- complete the entity merge (profile and project data)
			EXEC uspMergeResources @bntFromEntityIdent = @bntEntityIdent,
										@bntToEntityIdent = @bntToEntityIdent,
										@bntASUserIdent = @bntASUserIdent,
										@bntEditASUserIdent = @bntEditASUserIdent

			-- get the list of the old resources files (that match the new resources files on name)
			INSERT INTO #tmpFiles(
				OldFileAnswerIdent,
				NewFileAnswerIdent,
				RequirementTypeIdent
			)
			SELECT
				OldFileAnswerIdent = oldEFR.AnswerIdent,
				NewFileAnswerIdent = newEFR.AnswerIdent,
				RequirementTypeIdent = EPR.RequirementTypeIdent
			FROM
				EntityFileRepository oldEFR WITH (NOLOCK)
				INNER JOIN
				EntityFileRepository newEFR WITH (NOLOCK)
					ON newEFR.ProjectIdent = oldEFR.ProjectIdent
					AND newEFR.[FileName] = oldEFR.[FileName] -- match on name to make sure its the same file
					AND newEFR.FileKey = oldEFR.FileKey -- match on key to make sure we have to data to decrypt
				INNER JOIN
				EntityProjectEntityAnswer A WITH (NOLOCK)
					ON A.Ident = oldEFR.AnswerIdent
				INNER JOIN
				EntityProjectRequirement EPR WITH (NOLOCK)
					ON EPR.Ident = A.EntityProjectRequirementIdent
			WHERE
				oldEFR.EntityIdent = @bntEntityIdent
				AND newEFR.EntityIdent = @bntToEntityIdent
			
			-- Delete the old resource profile
			EXEC uspDeleteEntityByIdent @bntEntityIdent, @bntEditASUserIdent, 1


		END


	IF (@bitAccessDenied = 0 AND @bntEntityTypeIdent <> @intEntityTypeProviderIdent)
		BEGIN

			UPDATE
				Entity
			SET
				EntityTypeIdent = @bntEntityTypeIdent,
				EditASUserIdent = @bntEditASUserIdent,
				EditDateTime = dbo.ufnGetMyDate()
			WHERE
				Ident = @bntEntityIdent

			-- 5. Make sure the network is setup appropriate after the entityType change
			EXEC uspAddEntityToNetwork @intFromEntityIdent = @bntASUserIdent,
									@intToEntityIdent = @bntEntityIdent,
									@intAddASUserIdent = @bntEditASUserIdent,
									@bitActive = 1,
									@bitSuppressOutput = 1


		END

	SELECT
		@bitAccessDenied as [AccessDenied],
		@bntToEntityIdent as [ToEntityIdent]

	SELECT
		OldFileAnswerIdent,
		NewFileAnswerIdent,
		RequirementTypeIdent
	FROM
		#tmpFiles WITH (NOLOCK)

	DROP TABLE #tmpFiles

GO