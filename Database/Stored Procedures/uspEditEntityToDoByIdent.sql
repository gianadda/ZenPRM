IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspEditEntityToDoByIdent') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
  DROP PROCEDURE uspEditEntityToDoByIdent
 GO
/* uspEditEntityToDoByIdent
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspEditEntityToDoByIdent]

	@intIdent BIGINT, 
	@intToDoInitiatorTypeIdent BIGINT = 0, 
	@intToDoTypeIdent BIGINT = 0, 
	@intToDoStatusIdent BIGINT = 0, 
	@intRegardingEntityIdent BIGINT = 0, 
	@intAssigneeEntityIdent BIGINT = 0, 
	@nvrTitle NVARCHAR(MAX) = '', 
	@nvrDesc1 NVARCHAR(MAX) = '', 
	@sdtStartDate NVARCHAR(MAX), 
	@sdtDueDate NVARCHAR(MAX), 
	@ncrCategoryIdentCSV NVARCHAR(MAX), 
	@ncrNewCategoryCSV NVARCHAR(MAX), 
	@intEditASUserIdent BIGINT, 
	@bitActive BIT

AS

	SET NOCOUNT ON

	DECLARE @bntEntityIdent BIGINT 

	SELECT 
		@bntEntityIdent = EntityIdent 
	FROM	
		EntityToDo (NOLOCK)
	WHERE 
		Ident = @intIdent



	MERGE INTO EntityToDoCategory AS target
	USING dbo.ufnSplitString(@ncrNewCategoryCSV, ',') AS source
		ON target.EntityIdent = @bntEntityIdent
			AND LTRIM(RTRIM(source.Value)) = target.Name1
			AND @ncrNewCategoryCSV <> ''
	WHEN MATCHED THEN 
		--if we found one already, mark it as active and who updated it.
		UPDATE 
			SET 
				target.EditASUserIdent = @intEditASUserIdent,
				target.EditDateTime = GETDATE(),
				target.Active = 1

	WHEN NOT MATCHED BY TARGET THEN
		-- Put in the new answer
		INSERT (
		EntityIdent,
		Name1,
		IconClass,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
		)
		VALUES  (
			@bntEntityIdent,
			LTRIM(RTRIM(source.Value)),
			'',
			@intEditASUserIdent,
			GETDATE(),
			0,
			'1/1/1900',
			1
		);


	UPDATE EntityToDo
	SET 
		ToDoInitiatorTypeIdent = @intToDoInitiatorTypeIdent,
		ToDoTypeIdent = @intToDoTypeIdent, 
		ToDoStatusIdent = @intToDoStatusIdent,
		RegardingEntityIdent = @intRegardingEntityIdent,
		AssigneeEntityIdent = @intAssigneeEntityIdent,
		Title = @nvrTitle, 
		Desc1 = @nvrDesc1, 
		StartDate = @sdtStartDate,
		DueDate = @sdtDueDate, 
		EditASUserIdent = @intEditASUserIdent, 
		EditDateTime = dbo.ufnGetMyDate(), 
		Active = @bitActive
	WHERE
		Ident = @intIdent
		

	UPDATE ETETCX
	SET 
		Active = 0,
		EditASUserIdent = @intEditASUserIdent,
		EditDateTime = dbo.ufnGetMyDate()
	FROM
		EntityToDoEntityToDoCategoryXRef ETETCX 
		INNER JOIN
		EntityToDo ET WITH (NOLOCK)
			ON ET.Ident = ETETCX.EntityToDoIdent
	WHERE 
		ET.Ident = @intIdent
		

	INSERT INTO EntityToDoEntityToDoCategoryXRef (
		EntityToDoIdent,
		EntityToDoCategoryIdent,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT 
		EntityToDoIdent = @intIdent,
		EntityToDoCategoryIdent = SS.Value,
		AddASUserIdent = @intEditASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1
	FROM			
		dbo.ufnSplitString(@ncrCategoryIdentCSV, ',') SS
	WHERE 
		ISNUMERIC(SS.Value) > 0
		AND SS.Value <> 0


	--Add the newly created categoties
	INSERT INTO EntityToDoEntityToDoCategoryXRef (
		EntityToDoIdent,
		EntityToDoCategoryIdent,
		AddASUserIdent,
		AddDateTime,
		EditASUserIdent,
		EditDateTime,
		Active
	)
	SELECT 
		EntityToDoIdent = @intIdent,
		EntityToDoCategoryIdent = ETC.Ident,
		AddASUserIdent = @intEditASUserIdent,
		AddDateTime = dbo.ufnGetMyDate(),
		EditASUserIdent = 0,
		EditDateTime = '1/1/1900',
		Active = 1
	FROM		
		dbo.ufnSplitString(@ncrNewCategoryCSV, ',') SS
		INNER JOIN
		EntityToDoCategory ETC (NOLOCK)
			ON LTRIM(RTRIM(SS.Value)) = ETC.Name1
	WHERE 
		Active = 1



	SELECT @intIdent as [Ident]
GO