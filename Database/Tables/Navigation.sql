IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'Navigation') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE Navigation
GO

CREATE TABLE Navigation 
(
	Ident				BIGINT			IDENTITY(1,1)		NOT NULL,
	ParentIdent			BIGINT			DEFAULT 0			NULL,
	DisplayName			NVARCHAR(MAX)	DEFAULT ''			NULL,
	Sref				NVARCHAR(MAX)	DEFAULT ''			NULL,
	IconClasses			NVARCHAR(MAX)	DEFAULT ''			NULL,
	ClassName			NVARCHAR(MAX)	DEFAULT ''			NULL,
	Sequence			INTEGER			DEFAULT 0			NULL, 
	Active				BIT				DEFAULT 1			NULL 
)

CREATE UNIQUE CLUSTERED INDEX idx_Navigation_Ident ON Navigation(Ident) --NO FILL FACTOR FOR IDENTITY DATA TYPE
GO
