IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'EntityProjectMeasureLocationXref') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE EntityProjectMeasureLocationXref
GO

CREATE TABLE EntityProjectMeasureLocationXref (
	Ident BIGINT IDENTITY (1,1) ,
	EntityProjectMeasureIdent BIGINT ,
	MeasureLocationIdent BIGINT ,
	AddASUserIdent BIGINT,
	AddDateTime SMALLDATETIME,
	EditASUserIdent BIGINT,	
	EditDateTime SMALLDATETIME,
	Active BIT
)	

CREATE UNIQUE CLUSTERED INDEX idx_EntityProjectMeasureLocationXref_Ident ON dbo.EntityProjectMeasureLocationXref(Ident) 
GO

CREATE NONCLUSTERED INDEX idx_EntityProjectMeasureLocationXref_EntityProjectMeasureIdent ON dbo.EntityProjectMeasureLocationXref(EntityProjectMeasureIdent)
GO

CREATE NONCLUSTERED INDEX idx_EntityProjectMeasureLocationXref_MeasureLocationIdent ON dbo.EntityProjectMeasureLocationXref(MeasureLocationIdent) 
GO

INSERT INTO EntityProjectMeasureLocationXref(
	EntityProjectMeasureIdent,
	MeasureLocationIdent,
	AddASUserIdent,
	AddDateTime,
	EditASUserIdent,
	EditDateTime,
	Active
)
SELECT
	EntityProjectMeasureIdent = EPM.Ident,
	MeasureLocationIdent = ML.Ident,
	AddASUserIdent = 0,
	AddDateTime = dbo.ufnGetMyDate(),
	EditASUserIdent = 0,
	EditDateTime = '1/1/1900',
	Active = 2
FROM
	EntityProjectMeasure EPM WITH (NOLOCK),
	MeasureLocation ML WITH (NOLOCK)
WHERE
	EPM.Active = 1
	AND ML.Active = 1

GO