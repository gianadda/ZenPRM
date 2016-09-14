IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ASApplicationVariable') and 
	OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE ASApplicationVariable
GO
CREATE TABLE ASApplicationVariable(
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	Name1 NVARCHAR(150) NULL ,
	Desc1 NVARCHAR(400) NULL ,
	Value1 NVARCHAR(MAX) NULL ,
	Active BIT NULL 
)
GO

CREATE UNIQUE CLUSTERED INDEX idx_ASApplicationVariable_Ident ON ASApplicationVariable(Ident) 
GO
CREATE INDEX idx_ASApplicationVariable_Name1 ON ASApplicationVariable(Name1) 
GO