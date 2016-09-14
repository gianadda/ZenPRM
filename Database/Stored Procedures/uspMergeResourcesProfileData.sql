IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspMergeResourcesProfileData') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspMergeResourcesProfileData
GO
/********************************************************													
 *
 *	uspMergeResourcesProfileData 
 *
 ********************************************************/
 
CREATE PROCEDURE uspMergeResourcesProfileData

	@bntFromEntityIdent BIGINT,
	@bntToEntityIdent BIGINT,
	@bntASUserIdent BIGINT,
	@bntEditASUserIdent BIGINT

AS

	DECLARE @bntASUserActivityTypeEditProfileIdent BIGINT,
			@bntMostRecentEntityIdent BIGINT,
			@bntMostRecentEntityIdentForManualCheck BIGINT,
			@nvrColumnName NVARCHAR(MAX),
			@nvrColumnValue NVARCHAR(MAX),
			@nvrSQL NVARCHAR(MAX)

	SET @bntASUserActivityTypeEditProfileIdent = dbo.ufnActivityTypeEditProfile()

	CREATE TABLE #tmpEntity(
		Ident BIGINT,
		NPI NVARCHAR(250),
		DBA NVARCHAR(MAX),
		OrganizationName NVARCHAR(MAX),
		Prefix NVARCHAR(MAX),
		FirstName NVARCHAR(MAX),
		MiddleName NVARCHAR(MAX),
		LastName NVARCHAR(MAX),
		Suffix NVARCHAR(MAX),
		Title NVARCHAR(MAX),
		MedicalSchool NVARCHAR(MAX),
		GenderIdent BIGINT,
		PrimaryAddress1 NVARCHAR(MAX),
		PrimaryAddress2 NVARCHAR(MAX),
		PrimaryAddress3 NVARCHAR(MAX),
		PrimaryCity NVARCHAR(MAX),
		PrimaryStateIdent BIGINT,
		PrimaryZip NVARCHAR(MAX),
		PrimaryCounty NVARCHAR(MAX),
		PrimaryPhone NVARCHAR(MAX),
		PrimaryPhoneExtension NVARCHAR(MAX),
		PrimaryPhone2 NVARCHAR(MAX),
		PrimaryPhone2Extension NVARCHAR(MAX),
		PrimaryFax NVARCHAR(MAX),
		PrimaryFax2 NVARCHAR(MAX),
		MailingAddress1 NVARCHAR(MAX),
		MailingAddress2 NVARCHAR(MAX),
		MailingAddress3 NVARCHAR(MAX),
		MailingCity NVARCHAR(MAX),
		MailingStateIdent BIGINT,
		MailingZip NVARCHAR(MAX),
		MailingCounty NVARCHAR(MAX),
		PracticeAddress1 NVARCHAR(MAX),
		PracticeAddress2 NVARCHAR(MAX),
		PracticeAddress3 NVARCHAR(MAX),
		PracticeCity NVARCHAR(MAX),
		PracticeStateIdent BIGINT,
		PracticeZip NVARCHAR(MAX),
		PracticeCounty NVARCHAR(MAX),
		ProfilePhoto NVARCHAR(MAX),
		Website NVARCHAR(MAX),
		Latitude DECIMAL(20,8),
		Longitude DECIMAL(20,8),
		BirthDate SMALLDATETIME,
		GeocodingStatusIdent BIGINT,
		AddDateTime SMALLDATETIME
	)

	CREATE TABLE #tmpEntityEdits(
		EntityIdent BIGINT,
		EditDateTime DATETIME,
		FieldName NVARCHAR(MAX),
		FieldValue NVARCHAR(MAX)
	)

	CREATE TABLE #tmpEntityUpdate(
		FieldName NVARCHAR(MAX),
		FieldValue NVARCHAR(MAX)
	)

	-- get the 2 entity records that we are merging
	INSERT INTO #tmpEntity(
		Ident,
		NPI,
		DBA,
		OrganizationName,
		Prefix ,
		FirstName ,
		MiddleName ,
		LastName ,
		Suffix ,
		Title ,
		MedicalSchool ,
		GenderIdent ,
		PrimaryAddress1 ,
		PrimaryAddress2 ,
		PrimaryAddress3 ,
		PrimaryCity ,
		PrimaryStateIdent ,
		PrimaryZip ,
		PrimaryCounty ,
		PrimaryPhone ,
		PrimaryPhoneExtension ,
		PrimaryPhone2 ,
		PrimaryPhone2Extension ,
		PrimaryFax ,
		PrimaryFax2 ,
		MailingAddress1 ,
		MailingAddress2 ,
		MailingAddress3 ,
		MailingCity ,
		MailingStateIdent ,
		MailingZip ,
		MailingCounty ,
		PracticeAddress1 ,
		PracticeAddress2 ,
		PracticeAddress3 ,
		PracticeCity ,
		PracticeStateIdent ,
		PracticeZip ,
		PracticeCounty ,
		ProfilePhoto ,
		Website ,
		Latitude ,
		Longitude ,
		BirthDate,
		GeocodingStatusIdent ,
		AddDateTime
	)
	SELECT
		Ident,
		NPI,
		DBA,
		OrganizationName,
		Prefix ,
		FirstName ,
		MiddleName ,
		LastName ,
		Suffix ,
		Title ,
		MedicalSchool ,
		GenderIdent ,
		PrimaryAddress1 ,
		PrimaryAddress2 ,
		PrimaryAddress3 ,
		PrimaryCity ,
		PrimaryStateIdent ,
		PrimaryZip ,
		PrimaryCounty ,
		PrimaryPhone ,
		PrimaryPhoneExtension ,
		PrimaryPhone2 ,
		PrimaryPhone2Extension ,
		PrimaryFax ,
		PrimaryFax2 ,
		MailingAddress1 ,
		MailingAddress2 ,
		MailingAddress3 ,
		MailingCity ,
		MailingStateIdent ,
		MailingZip ,
		MailingCounty ,
		PracticeAddress1 ,
		PracticeAddress2 ,
		PracticeAddress3 ,
		PracticeCity ,
		PracticeStateIdent ,
		PracticeZip ,
		PracticeCounty ,
		ProfilePhoto ,
		Website ,
		Latitude ,
		Longitude ,
		BirthDate,
		GeocodingStatusIdent,
		AddDateTime
	FROM
		Entity WITH (NOLOCK)
	WHERE
		Ident IN (@bntFromEntityIdent, @bntToEntityIdent)

	-- get any of their profile edits
	INSERT INTO #tmpEntityEdits(
		EntityIdent,
		EditDateTime,
		FieldName,
		FieldValue
	)
	SELECT
		EntityIdent = A.UpdatedEntityIdent,
		EditDateTime = A.ActivityDateTime,
		FieldName = AD.FieldName,
		FieldValue = AD.NewValue
	FROM
		ASUserActivity A WITH (NOLOCK)
		INNER JOIN
		ASUserActivityDetail AD WITH (NOLOCK)
			ON AD.ASUserActivityIdent = A.Ident
	WHERE
		A.UpdatedEntityIdent IN (@bntFromEntityIdent, @bntToEntityIdent)
		AND A.ActivityTypeIdent = @bntASUserActivityTypeEditProfileIdent

	-- find out who the most recent resource is. If there is no audit history, we'll default to this profile data
	SELECT TOP 1
		@bntMostRecentEntityIdent = Ident
	FROM
		#tmpEntity WITH (NOLOCK)
	ORDER BY
		AddDateTime DESC

	-- loop through each project
	DECLARE profile_cursor CURSOR FOR

		-- get all of the columns we want to update
		-- doing this so we can cursor through them and save lines of code
		SELECT
			'NPI'
		UNION ALL
		SELECT
			'DBA'
		UNION ALL
		SELECT
			'OrganizationName'
		UNION ALL
		SELECT
			'Prefix'
		UNION ALL
		SELECT
			'FirstName'
		UNION ALL
		SELECT
			'MiddleName'
		UNION ALL
		SELECT
			'LastName'
		UNION ALL
		SELECT
			'Suffix'
		UNION ALL
		SELECT
			'Title'
		UNION ALL
		SELECT
			'MedicalSchool'
		UNION ALL
		SELECT
			'GenderIdent'
		UNION ALL
		SELECT
			'ProfilePhoto'
		UNION ALL
		SELECT
			'Website'
		UNION ALL
		SELECT
			'BirthDate'
		UNION ALL
		SELECT
			'PrimaryFax'
		UNION ALL
		SELECT
			'PrimaryFax2'

		OPEN profile_cursor
		
		FETCH NEXT FROM profile_cursor
		INTO @nvrColumnName

		WHILE @@FETCH_STATUS = 0
		BEGIN

			-- reset the value on the loop
			SET @nvrColumnValue = ''
			SET @nvrSQL = ''

			-- check the audit history to see what the most recent value is
			SELECT TOP 1
				@nvrColumnValue = FieldValue
			FROM
				#tmpEntityEdits
			WHERE
				FieldName = @nvrColumnName
			ORDER BY
				EditDateTime DESC

			-- if there is no history, get the value from the most recent entity
			IF (@nvrColumnValue = '')
				BEGIN

					SET @nvrSQL = 'SELECT @nvrOutColumnValue = ' + @nvrColumnName + ' FROM #tmpEntity WHERE Ident = @bntMostRecentEntityIdent AND @bntMostRecentEntityIdent <> @bntToEntityIdent'

					--PRINT @nvrSQL

					EXEC sp_executesql @nvrSQL,N'@nvrOutColumnValue NVARCHAR(MAX) OUTPUT,@bntMostRecentEntityIdent BIGINT,@bntToEntityIdent BIGINT',@nvrOutColumnValue=@nvrColumnValue OUTPUT,@bntMostRecentEntityIdent=@bntMostRecentEntityIdent,@bntToEntityIdent=@bntToEntityIdent

				END

			-- if we have a value, add it to the update table (which we will loop through and run an update for on the entity)
			INSERT INTO #tmpEntityUpdate(
				FieldName,
				FieldValue
			)
			SELECT
				@nvrColumnName,
				@nvrColumnValue
			WHERE
				@nvrColumnValue <> ''

			FETCH NEXT FROM profile_cursor
			INTO @nvrColumnName

		END -- end cursor
		
	CLOSE profile_cursor
	DEALLOCATE profile_cursor

	/**************************
		
		Now that we looped through the one-off columns, we need to handle a few data points by groups (i.e. address info)

	**************************/
	SET @bntMostRecentEntityIdentForManualCheck = 0

	SELECT TOP 1
		@bntMostRecentEntityIdentForManualCheck = EntityIdent
	FROM
		#tmpEntityEdits WITH (NOLOCK)
	WHERE
		FieldName IN ('PrimaryAddress1','PrimaryAddress2','PrimaryAddress3','PrimaryCity','PrimaryStateIdent','PrimaryZip','PrimaryCounty')
	ORDER BY
		EditDateTime DESC

	-- if there isnt info in the audit history
	IF (@bntMostRecentEntityIdentForManualCheck = 0)
		BEGIN
			-- get the most recent entity info
			SET @bntMostRecentEntityIdentForManualCheck = @bntMostRecentEntityIdent
		END

	INSERT INTO #tmpEntityUpdate(
		FieldName,
		FieldValue
	)
	SELECT
		'PrimaryAddress1',
		PrimaryAddress1
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(PrimaryAddress1) + LEN(PrimaryAddress2) + LEN(PrimaryAddress3) + LEN(PrimaryCity) + LEN(PrimaryZip)) > 0)
	UNION ALL
	SELECT
		'PrimaryAddress2',
		PrimaryAddress2
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(PrimaryAddress1) + LEN(PrimaryAddress2) + LEN(PrimaryAddress3) + LEN(PrimaryCity) + LEN(PrimaryZip)) > 0)
	UNION ALL
	SELECT
		'PrimaryAddress3',
		PrimaryAddress3
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(PrimaryAddress1) + LEN(PrimaryAddress2) + LEN(PrimaryAddress3) + LEN(PrimaryCity) + LEN(PrimaryZip)) > 0)
	UNION ALL
	SELECT
		'PrimaryCity',
		PrimaryCity
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(PrimaryAddress1) + LEN(PrimaryAddress2) + LEN(PrimaryAddress3) + LEN(PrimaryCity) + LEN(PrimaryZip)) > 0)
	UNION ALL
	SELECT
		'PrimaryStateIdent',
		CAST(PrimaryStateIdent AS NVARCHAR(MAX))
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(PrimaryAddress1) + LEN(PrimaryAddress2) + LEN(PrimaryAddress3) + LEN(PrimaryCity) + LEN(PrimaryZip)) > 0)
	UNION ALL
	SELECT
		'PrimaryZip',
		PrimaryZip
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(PrimaryAddress1) + LEN(PrimaryAddress2) + LEN(PrimaryAddress3) + LEN(PrimaryCity) + LEN(PrimaryZip)) > 0)
	UNION ALL
	SELECT
		'PrimaryCounty',
		PrimaryCounty
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(PrimaryAddress1) + LEN(PrimaryAddress2) + LEN(PrimaryAddress3) + LEN(PrimaryCity) + LEN(PrimaryZip)) > 0)
	UNION ALL
	SELECT
		'Latitude',
		CAST(Latitude AS NVARCHAR(MAX))
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(PrimaryAddress1) + LEN(PrimaryAddress2) + LEN(PrimaryAddress3) + LEN(PrimaryCity) + LEN(PrimaryZip)) > 0)
	UNION ALL
	SELECT
		'Longitude',
		CAST(Longitude AS NVARCHAR(MAX))
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(PrimaryAddress1) + LEN(PrimaryAddress2) + LEN(PrimaryAddress3) + LEN(PrimaryCity) + LEN(PrimaryZip)) > 0)
	UNION ALL
	SELECT
		'GeocodingStatusIdent',
		CAST(GeocodingStatusIdent AS NVARCHAR(MAX))
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(PrimaryAddress1) + LEN(PrimaryAddress2) + LEN(PrimaryAddress3) + LEN(PrimaryCity) + LEN(PrimaryZip)) > 0)

	
	/**************************
		
		Now do this again for the mailing address

	**************************/
	SET @bntMostRecentEntityIdentForManualCheck = 0

	SELECT TOP 1
		@bntMostRecentEntityIdentForManualCheck = EntityIdent
	FROM
		#tmpEntityEdits WITH (NOLOCK)
	WHERE
		FieldName IN ('MailingAddress1','MailingAddress2','MailingAddress3','MailingCity','MailingStateIdent','MailingZip','MailingCounty')
	ORDER BY
		EditDateTime DESC

	-- if there isnt info in the audit history
	IF (@bntMostRecentEntityIdentForManualCheck = 0)
		BEGIN
			-- get the most recent entity info
			SET @bntMostRecentEntityIdentForManualCheck = @bntMostRecentEntityIdent
		END

	INSERT INTO #tmpEntityUpdate(
		FieldName,
		FieldValue
	)
	SELECT
		'MailingAddress1',
		MailingAddress1
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(MailingAddress1) + LEN(MailingAddress2) + LEN(MailingAddress3) + LEN(MailingCity) + LEN(MailingZip)) > 0)
	UNION ALL
	SELECT
		'MailingAddress2',
		MailingAddress2
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(MailingAddress1) + LEN(MailingAddress2) + LEN(MailingAddress3) + LEN(MailingCity) + LEN(MailingZip)) > 0)
	UNION ALL
	SELECT
		'MailingAddress3',
		MailingAddress3
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(MailingAddress1) + LEN(MailingAddress2) + LEN(MailingAddress3) + LEN(MailingCity) + LEN(MailingZip)) > 0)
	UNION ALL
	SELECT
		'MailingCity',
		MailingCity
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(MailingAddress1) + LEN(MailingAddress2) + LEN(MailingAddress3) + LEN(MailingCity) + LEN(MailingZip)) > 0)
	UNION ALL
	SELECT
		'MailingStateIdent',
		CAST(MailingStateIdent AS NVARCHAR(MAX))
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(MailingAddress1) + LEN(MailingAddress2) + LEN(MailingAddress3) + LEN(MailingCity) + LEN(MailingZip)) > 0)
	UNION ALL
	SELECT
		'MailingZip',
		MailingZip
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(MailingAddress1) + LEN(MailingAddress2) + LEN(MailingAddress3) + LEN(MailingCity) + LEN(MailingZip)) > 0)
	UNION ALL
	SELECT
		'MailingCounty',
		MailingCounty
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(MailingAddress1) + LEN(MailingAddress2) + LEN(MailingAddress3) + LEN(MailingCity) + LEN(MailingZip)) > 0)

		
	/**************************
		
		Now do this again for the practice address

	**************************/
	SET @bntMostRecentEntityIdentForManualCheck = 0
	
	SELECT TOP 1
		@bntMostRecentEntityIdentForManualCheck = EntityIdent
	FROM
		#tmpEntityEdits WITH (NOLOCK)
	WHERE
		FieldName IN ('PracticeAddress1','PracticeAddress2','PracticeAddress3','PracticeCity','PracticeStateIdent','PracticeZip','PracticeCounty')
	ORDER BY
		EditDateTime DESC

	-- if there isnt info in the audit history
	IF (@bntMostRecentEntityIdentForManualCheck = 0)
		BEGIN
			-- get the most recent entity info
			SET @bntMostRecentEntityIdentForManualCheck = @bntMostRecentEntityIdent
		END

	INSERT INTO #tmpEntityUpdate(
		FieldName,
		FieldValue
	)
	SELECT
		'PracticeAddress1',
		PracticeAddress1
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(PracticeAddress1) + LEN(PracticeAddress2) + LEN(PracticeAddress3) + LEN(PracticeCity) + LEN(PracticeZip)) > 0)
	UNION ALL
	SELECT
		'PracticeAddress2',
		PracticeAddress2
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(PracticeAddress1) + LEN(PracticeAddress2) + LEN(PracticeAddress3) + LEN(PracticeCity) + LEN(PracticeZip)) > 0)
	UNION ALL
	SELECT
		'PracticeAddress3',
		PracticeAddress3
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(PracticeAddress1) + LEN(PracticeAddress2) + LEN(PracticeAddress3) + LEN(PracticeCity) + LEN(PracticeZip)) > 0)
	UNION ALL
	SELECT
		'PracticeCity',
		PracticeCity
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(PracticeAddress1) + LEN(PracticeAddress2) + LEN(PracticeAddress3) + LEN(PracticeCity) + LEN(PracticeZip)) > 0)
	UNION ALL
	SELECT
		'PracticeStateIdent',
		CAST(PracticeStateIdent AS NVARCHAR(MAX))
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(PracticeAddress1) + LEN(PracticeAddress2) + LEN(PracticeAddress3) + LEN(PracticeCity) + LEN(PracticeZip)) > 0)
	UNION ALL
	SELECT
		'PracticeZip',
		PracticeZip
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(PracticeAddress1) + LEN(PracticeAddress2) + LEN(PracticeAddress3) + LEN(PracticeCity) + LEN(PracticeZip)) > 0)
	UNION ALL
	SELECT
		'PracticeCounty',
		PracticeCounty
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(PracticeAddress1) + LEN(PracticeAddress2) + LEN(PracticeAddress3) + LEN(PracticeCity) + LEN(PracticeZip)) > 0)


	/**************************
		
		Now do this for the phone 1 fields

	**************************/
	SET @bntMostRecentEntityIdentForManualCheck = 0

	SELECT TOP 1
		@bntMostRecentEntityIdentForManualCheck = EntityIdent
	FROM
		#tmpEntityEdits WITH (NOLOCK)
	WHERE
		FieldName IN ('PrimaryPhone','PrimaryPhoneExtension')
	ORDER BY
		EditDateTime DESC

	-- if there isnt info in the audit history
	IF (@bntMostRecentEntityIdentForManualCheck = 0)
		BEGIN
			-- get the most recent entity info
			SET @bntMostRecentEntityIdentForManualCheck = @bntMostRecentEntityIdent
		END

	INSERT INTO #tmpEntityUpdate(
		FieldName,
		FieldValue
	)
	SELECT
		'PrimaryPhone',
		PrimaryPhone
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(PrimaryPhone) + LEN(PrimaryPhoneExtension)) > 0)
	UNION ALL
	SELECT
		'PrimaryPhoneExtension',
		PrimaryPhoneExtension
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(PrimaryPhone) + LEN(PrimaryPhoneExtension)) > 0)

	/**************************
		
		And then lastly for the phone 2 fields

	**************************/
	SET @bntMostRecentEntityIdentForManualCheck = 0

	SELECT TOP 1
		@bntMostRecentEntityIdentForManualCheck = EntityIdent
	FROM
		#tmpEntityEdits WITH (NOLOCK)
	WHERE
		FieldName IN ('PrimaryPhone2','PrimaryPhone2Extension')
	ORDER BY
		EditDateTime DESC

	-- if there isnt info in the audit history
	IF (@bntMostRecentEntityIdentForManualCheck = 0)
		BEGIN
			-- get the most recent entity info
			SET @bntMostRecentEntityIdentForManualCheck = @bntMostRecentEntityIdent
		END

	INSERT INTO #tmpEntityUpdate(
		FieldName,
		FieldValue
	)
	SELECT
		'PrimaryPhone2',
		PrimaryPhone2
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent
		AND ((LEN(PrimaryPhone2) + LEN(PrimaryPhone2Extension)) > 0)
	UNION ALL
	SELECT
		'PrimaryPhone2Extension',
		PrimaryPhone2Extension
	FROM
		#tmpEntity WITH (NOLOCK)
	WHERE
		Ident = @bntMostRecentEntityIdentForManualCheck 
		AND @bntMostRecentEntityIdentForManualCheck <> @bntToEntityIdent	
		AND ((LEN(PrimaryPhone2) + LEN(PrimaryPhone2Extension)) > 0)	

	--SELECT * FROM #tmpEntityUpdate
	/********************************

		OK, a bit of clean up, lets just make sure our referenced values are correct

	********************************/
	UPDATE
		tEU
	SET
		FieldValue = CAST(G.Ident AS NVARCHAR(MAX))
	FROM
		#tmpEntityUpdate tEU WITH (NOLOCK)
		INNER JOIN
		Gender G WITH (NOLOCK)
			ON G.Name1 = tEU.FieldValue
	WHERE
		tEU.FieldName = 'GenderIdent'

	UPDATE
		tEU
	SET
		FieldValue = CAST(S.Ident AS NVARCHAR(MAX))
	FROM
		#tmpEntityUpdate tEU WITH (NOLOCK)
		INNER JOIN
		States S WITH (NOLOCK)
			ON S.Name1 = tEU.FieldValue
	WHERE
		tEU.FieldName = 'PrimaryStateIdent'

	UPDATE
		tEU
	SET
		FieldValue = CAST(S.Ident AS NVARCHAR(MAX))
	FROM
		#tmpEntityUpdate tEU WITH (NOLOCK)
		INNER JOIN
		States S WITH (NOLOCK)
			ON S.Name1 = tEU.FieldValue
	WHERE
		tEU.FieldName = 'MailingStateIdent'
	
	UPDATE
		tEU
	SET
		FieldValue = CAST(S.Ident AS NVARCHAR(MAX))
	FROM
		#tmpEntityUpdate tEU WITH (NOLOCK)
		INNER JOIN
		States S WITH (NOLOCK)
			ON S.Name1 = tEU.FieldValue
	WHERE
		tEU.FieldName = 'PracticeStateIdent'
	
	/********************************

		Now we've determined which columns to update, lets get them
		setup in a SQL script then perform the update

	********************************/

	SET @nvrSQL = ''
	SET @nvrSQL = 'UPDATE Entity SET '
	
	-- loop through each project
	DECLARE profile_cursor CURSOR FOR

		SELECT
			FieldName,
			FieldValue
		FROM
			#tmpEntityUpdate

		OPEN profile_cursor
		
		FETCH NEXT FROM profile_cursor
		INTO @nvrColumnName,@nvrColumnValue

		WHILE @@FETCH_STATUS = 0
		BEGIN

			SET @nvrSQL = @nvrSQL + @nvrColumnName + ' = ''' + @nvrColumnValue + ''', '

			FETCH NEXT FROM profile_cursor
			INTO @nvrColumnName,@nvrColumnValue

		END -- end cursor
		
	CLOSE profile_cursor
	DEALLOCATE profile_cursor

	-- remove the last comma
	SET @nvrSQL = @nvrSQL + 'EditASUserIdent = @bntEditASUserIdent, EditDateTime = dbo.ufnGetMyDate() WHERE Ident = @bntToEntityIdent'

	EXEC sp_executesql @nvrSQL,N'@bntEditASUserIdent BIGINT, @bntToEntityIdent BIGINT',@bntEditASUserIdent=@bntEditASUserIdent,@bntToEntityIdent=@bntToEntityIdent

	--SELECT @nvrSQL

	DROP TABLE #tmpEntity
	DROP TABLE #tmpEntityEdits
	DROP TABLE #tmpEntityUpdate

GO