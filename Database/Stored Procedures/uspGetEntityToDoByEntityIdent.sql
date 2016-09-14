IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityToDoByEntityIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityToDoByEntityIdent
GO


/* uspGetEntityToDoByEntityIdent @intEntityIdent=2, @bitIncludeClosed=1,@intNumberOfDays=-1, @intAddEditASUserIdent=306487
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetEntityToDoByEntityIdent]

	@intEntityIdent BIGINT,
	@bitIncludeClosed BIT , 
	@intNumberOfDays BIGINT,
	@intAddEditASUserIdent BIGINT -- Logged in User (ie. Office Manager)

AS

	SET NOCOUNT ON

	DECLARE @sdtGETDATE AS SMALLDATETIME = GETDATE()

	DECLARE @bntToDoStatusClosedIdent BIGINT

	SET @bntToDoStatusClosedIdent = dbo.ufnToDoStatusClosedIdent()


	SELECT DISTINCT
		ETD.Ident,
		ETD.EntityIdent,
		ETD.ToDoInitiatorTypeIdent,
		TDIT.Name1 as [ToDoInitiatorType],
		TDIT.IconClass as [ToDoInitiatorTypeIconClass],
		ETD.ToDoTypeIdent,
		TDT.Name1 as [ToDoType],
		TDT.IconClass as [ToDoTypeIconClass],
		ETD.ToDoStatusIdent,
		TDS.Name1 as [ToDoStatus],
		TDS.IconClass as [ToDoStatusIconClass],
		ETD.RegardingEntityIdent, 
		RE.FullName as [Regarding],
		RE.ProfilePhoto as [RegardingEntityProfilePhoto],
		ETD.AssigneeEntityIdent,
		E.FullName as [Assignee],
		E.ProfilePhoto as [AssigneeProfilePhoto],
		ETD.Title,
		ETD.Desc1,
		CASE CONVERT(VARCHAR(20),ETD.StartDate, 101) WHEN '01/01/1900' THEN '' ELSE CONVERT(VARCHAR(20),ETD.StartDate, 101) END as [StartDate], 
		CASE CONVERT(VARCHAR(20),ETD.DueDate, 101) WHEN '01/01/1900' THEN '' ELSE CONVERT(VARCHAR(20),ETD.DueDate, 101) END as [DueDate], 
		ETD.AddASUserIdent,
		CASE CONVERT(VARCHAR(20),ETD.AddDateTime, 101) WHEN '01/01/1900' THEN '' ELSE CONVERT(VARCHAR(20),ETD.AddDateTime, 101) END as [AddDateTime], 
		ETD.EditASUserIdent,
		CASE CONVERT(VARCHAR(20),ETD.EditDateTime, 101) WHEN '01/01/1900' THEN '' ELSE CONVERT(VARCHAR(20),ETD.EditDateTime, 101) END as [EditDateTime], 
		CASE 
			WHEN ETD.ToDoStatusIdent = @bntToDoStatusClosedIdent AND ETD.EditDateTime = '1/1/1900' THEN CONVERT(VARCHAR(20),ETD.AddDateTime, 101)
			WHEN ETD.ToDoStatusIdent = @bntToDoStatusClosedIdent AND ETD.EditDateTime <> '1/1/1900' THEN CONVERT(VARCHAR(20),ETD.EditDateTime, 101)
			ELSE ''
		END as [CompletedDateTime],
		ETD.Active
	FROM
		EntityToDo ETD WITH (NOLOCK)
		INNER JOIN
		ToDoType TDT WITH (NOLOCK)
			ON ETD.ToDoTypeIdent = TDT.Ident
		INNER JOIN
		ToDoInitiatorType TDIT WITH (NOLOCK)
			ON ETD.ToDoInitiatorTypeIdent = TDIT.Ident
		INNER JOIN
		ToDoStatus TDS WITH (NOLOCK)
			ON ETD.ToDoStatusIdent = TDS.Ident
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON ETD.AssigneeEntityIdent = E.Ident 
		INNER JOIN
		Entity RE WITH (NOLOCK)
			ON ETD.RegardingEntityIdent = RE.Ident 
	WHERE 
		ETD.Active = 1
		AND ETD.EntityIdent = @intEntityIdent
		AND (TDS.Ident <> @bntToDoStatusClosedIdent OR @bitIncludeClosed = 1)
		AND ((@intNumberOfDays = -1) OR 
				DATEDIFF(dd,ETD.StartDate, @sdtGETDATE) <= @intNumberOfDays OR 
				DATEDIFF(dd,ETD.DueDate, @sdtGETDATE) <= @intNumberOfDays OR 
				DATEDIFF(dd,ETD.AddDateTime, @sdtGETDATE) <= @intNumberOfDays OR 
				DATEDIFF(dd,ETD.EditDateTime, @sdtGETDATE) <= @intNumberOfDays)
	ORDER BY 
		CASE CONVERT(VARCHAR(20),ETD.DueDate, 101) WHEN '01/01/1900' THEN '' ELSE CONVERT(VARCHAR(20),ETD.DueDate, 101) END ASC


	SELECT 
		ETETCX.Ident,
		ETETCX.EntityToDoIdent,
		ETETCX.EntityToDoCategoryIdent,
		ETETCX.AddASUserIdent,
		ETETCX.AddDateTime,
		ETETCX.EditASUserIdent,
		ETETCX.EditDateTime,
		ETETCX.Active
	FROM
		EntityToDoEntityToDoCategoryXRef ETETCX WITH (NOLOCK)
		INNER JOIN
		EntityToDo ETD WITH (NOLOCK)
			ON ETD.Ident = ETETCX.EntityToDoIdent
		INNER JOIN
		ToDoStatus TDS WITH (NOLOCK)
			ON ETD.ToDoStatusIdent = TDS.Ident
	WHERE 
		--ETD.Active = 1 -- still show inactive Categories
		ETETCX.Active = 1
		AND ETD.EntityIdent = @intEntityIdent
		AND (TDS.Ident <> @bntToDoStatusClosedIdent OR @bitIncludeClosed = 1)
		AND ((@intNumberOfDays = -1) OR 
				DATEDIFF(dd,ETD.StartDate, @sdtGETDATE) <= @intNumberOfDays OR 
				DATEDIFF(dd,ETD.DueDate, @sdtGETDATE) <= @intNumberOfDays OR 
				DATEDIFF(dd,ETD.AddDateTime, @sdtGETDATE) <= @intNumberOfDays OR 
				DATEDIFF(dd,ETD.EditDateTime, @sdtGETDATE) <= @intNumberOfDays)


	SELECT 
		ETDC.Ident,
		ETDC.EntityToDoIdent,
		ETDC.CommentText,
		ETDC.AddASUserIdent,
		CONVERT(VARCHAR(20),ETD.AddDateTime, 101) as [AddDateTime], 
		CE.FullName as [Commenter],
		CE.ProfilePhoto as [CommenterProfilePhoto],
		ETDC.Active
	FROM
		EntityToDoComment ETDC WITH (NOLOCK)
		INNER JOIN
		EntityToDo ETD WITH (NOLOCK)
			ON ETD.Ident = ETDC.EntityToDoIdent
		INNER JOIN
		ToDoStatus TDS WITH (NOLOCK)
			ON ETD.ToDoStatusIdent = TDS.Ident
		INNER JOIN
		Entity CE WITH (NOLOCK)
			ON CE.Ident = ETDC.AddASUserIdent
	WHERE 
		ETD.Active = 1
		AND ETDC.Active = 1
		AND ETD.EntityIdent = @intEntityIdent
		AND (TDS.Ident <> @bntToDoStatusClosedIdent OR @bitIncludeClosed = 1)
		AND ((@intNumberOfDays = -1) OR 
				DATEDIFF(dd,ETD.StartDate, @sdtGETDATE) <= @intNumberOfDays OR 
				DATEDIFF(dd,ETD.DueDate, @sdtGETDATE) <= @intNumberOfDays OR 
				DATEDIFF(dd,ETD.AddDateTime, @sdtGETDATE) <= @intNumberOfDays OR 
				DATEDIFF(dd,ETD.EditDateTime, @sdtGETDATE) <= @intNumberOfDays)


GO

--uspGetEntityToDoByEntityIdent 2, 1,30, 2
