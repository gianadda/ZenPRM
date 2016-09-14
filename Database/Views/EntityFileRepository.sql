IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityFileRepository') 
	AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP View EntityFileRepository
GO

CREATE VIEW EntityFileRepository

AS 

	SELECT DISTINCT EntityIdent, ProjectIdent, ProjectName, PrivateProject, AnswerIdent, Active, AddDateTime, [FileName],[FileSize],[MimeType],[FileKey]
	FROM 
	(SELECT
		EPE.EntityIdent as [EntityIdent] ,
		EP.Ident as [ProjectIdent],
		EP.Name1 as [ProjectName],
		EP.PrivateProject,
		EPEA.Ident as [AnswerIdent],
		EPEA.Active,
		EPEAV.Name1, 
		EPEAV.Value1 ,
		EPEAV.AddDateTime
	FROM
		EntityProjectEntityAnswerValue EPEAV WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntityAnswer EPEA WITH (NOLOCK)
			ON EPEA.Ident = EPEAV.EntityProjectEntityAnswerIdent
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.Ident = EPEA.EntityProjectEntityIdent
		INNER JOIN
		EntityProject EP WITH (NOLOCK)
			ON EP.Ident = EPE.EntityProjectIdent
		INNER JOIN
		EntityProjectRequirement EPR WITH (NOLOCK)
			ON EPR.Ident = EPEA.EntityProjectRequirementIdent
		INNER JOIN
		RequirementType RT WITH (NOLOCK)
			ON RT.Ident = EPR.RequirementTypeIdent
	WHERE
		EPE.Active = 1
		AND EP.Active = 1
		AND EPR.Active = 1
		AND RT.Active = 1
		AND RT.IsFileUpload = 1
		AND EPEAV.Value1 <> '') p
	PIVOT
	(
	MAX (Value1)
	FOR Name1 IN
	( [FileName],[FileSize],[MimeType],[FileKey])
	) AS pvt

GO