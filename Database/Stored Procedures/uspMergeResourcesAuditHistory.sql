IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspMergeResourcesAuditHistory') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspMergeResourcesAuditHistory
GO
/********************************************************													
 *
 *	uspMergeResourcesAuditHistory 
 *
 ********************************************************/
 
CREATE PROCEDURE uspMergeResourcesAuditHistory

	@bntFromEntityIdent BIGINT,
	@bntToEntityIdent BIGINT,
	@bntASUserIdent BIGINT,
	@bntEditASUserIdent BIGINT

AS

	DECLARE @bntIdent BIGINT
	DECLARE @bntActivityASUserIdent BIGINT
	DECLARE @bntActivityTypeIdent BIGINT
	DECLARE @dteActivityDateTime DATETIME
	DECLARE @nvrActivityDescription NVARCHAR(MAX)
	DECLARE @nvrClientIPAddress NVARCHAR(50)
	DECLARE @bntRecordIdent BIGINT
	DECLARE @bntCustomerEntityIdent BIGINT

	DECLARE @bntNewIdent BIGINT

	-- loop through each audit record and move to the new entity
	DECLARE audit_cursor CURSOR FOR

		SELECT
			Ident,
			ASUserIdent,
			ActivityTypeIdent,
			ActivityDateTime,
			ActivityDescription,
			ClientIPAddress,
			RecordIdent,
			CustomerEntityIdent
		FROM
			ASUserActivity WITH (NOLOCK)
		WHERE
			UpdatedEntityIdent = @bntFromEntityIdent

		OPEN audit_cursor

		FETCH NEXT FROM audit_cursor
		INTO @bntIdent,@bntActivityASUserIdent,@bntActivityTypeIdent,@dteActivityDateTime,@nvrActivityDescription,@nvrClientIPAddress,@bntRecordIdent,@bntCustomerEntityIdent

		WHILE @@FETCH_STATUS = 0
		BEGIN

			SET @bntNewIdent = 0

			INSERT INTO ASUserActivity(
				ASUserIdent,
				ActivityTypeIdent,
				ActivityDateTime,
				ActivityDescription,
				ClientIPAddress,
				RecordIdent,
				CustomerEntityIdent,
				UpdatedEntityIdent
			)
			SELECT
				ASUserIdent = @bntActivityASUserIdent,
				ActivityTypeIdent = @bntActivityTypeIdent,
				ActivityDateTime = @dteActivityDateTime,
				ActivityDescription = @nvrActivityDescription,
				ClientIPAddress = @nvrClientIPAddress,
				RecordIdent = @bntRecordIdent,
				CustomerEntityIdent = @bntCustomerEntityIdent,
				UpdatedEntityIdent = @bntToEntityIdent

			SET @bntNewIdent = SCOPE_IDENTITY()

			INSERT INTO ASUserActivityDetail(
				ASUserActivityIdent,
				FieldName,
				OldValue,
				NewValue
			)
			SELECT
				ASUserActivityIdent = @bntNewIdent,
				FieldName = AD.FieldName,
				OldValue = AD.OldValue,
				NewValue = AD.NewValue
			FROM
				ASUserActivityDetail AD WITH (NOLOCK)
			WHERE
				AD.ASUserActivityIdent = @bntIdent
		
			FETCH NEXT FROM audit_cursor
			INTO @bntIdent,@bntActivityASUserIdent,@bntActivityTypeIdent,@dteActivityDateTime,@nvrActivityDescription,@nvrClientIPAddress,@bntRecordIdent,@bntCustomerEntityIdent

		END -- end cursor
		
		CLOSE audit_cursor
		DEALLOCATE audit_cursor
	

GO