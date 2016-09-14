IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'NavigationPermission') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE NavigationPermission
GO

CREATE TABLE NavigationPermission (
	Ident					BIGINT	IDENTITY(1,1)	NOT NULL ,
	SystemRoleIdent			BIGINT					NOT NULL, 
	NavigationIdent			BIGINT					NOT NULL,  
	Active					BIT		DEFAULT 0 		NULL 
)

CREATE UNIQUE CLUSTERED INDEX idx_NavigationPermission_Ident ON NavigationPermission(Ident) --NO FILL FACTOR FOR IDENTITY DATA TYPE
GO



			



