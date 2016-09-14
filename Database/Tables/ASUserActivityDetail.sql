IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ASUserActivityDetail') and 
	OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE ASUserActivityDetail
go
CREATE TABLE ASUserActivityDetail(
	Ident BIGINT IDENTITY(1,1) NOT NULL,
	ASUserActivityIdent BIGINT NULL,
	FieldName NVARCHAR(MAX) NULL,
	OldValue NVARCHAR(MAX) NULL,
	NewValue NVARCHAR(MAX) NULL
)
GO

CREATE UNIQUE CLUSTERED INDEX idx_ASUserActivityDetail_Ident ON ASUserActivityDetail(Ident)
GO
CREATE INDEX idx_ASUserActivityDetail_ASUserActivityIdent ON ASUserActivityDetail(ASUserActivityIdent) 
GO