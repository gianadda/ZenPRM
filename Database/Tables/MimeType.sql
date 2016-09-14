IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'MimeType') 
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE MimeType
GO

CREATE TABLE MimeType (
	Ident BIGINT IDENTITY(1,1) NOT NULL ,
	Name1 NVARCHAR(250) NULL ,
	Extension NVARCHAR(5) NULL,
	IconClass NVARCHAR(250) NULL ,
	AddASUserIdent BIGINT NULL ,
	AddDateTime SMALLDATETIME NULL ,
	EditASUserIdent BIGINT NULL ,	
	EditDateTime SMALLDATETIME NULL ,
	Active BIT NULL
)

CREATE UNIQUE CLUSTERED INDEX idx_MimeType_Ident ON MimeType(Ident) --NO FILL FACTOR FOR IDENTITY DATA TYPE
GO
CREATE NONCLUSTERED INDEX idx_MimeType_Name1 ON MimeType(Name1) 
GO

SET IDENTITY_INSERT [dbo].[MimeType] ON 

INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (1, N'image/bmp', N'.bmp', N'fa fa-file-image-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (2, N'application/csv', N'.csv', N'fa fa-file-text-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (3, N'text/csv', N'.csv', N'fa fa-file-text-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (4, N'application/msword', N'.doc', N'fa fa-file-word-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (5, N'application/vnd.openxmlformats-officedocument.wordprocessingml.document', N'.docx', N'fa fa-file-word-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (6, N'image/gif', N'.gif', N'fa fa-file-image-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (7, N'text/html', N'.html', N'fa fa-file-text-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (8, N'image/x-icon', N'.ico', N'fa fa-file-image-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (9, N'image/jpeg', N'.jpg', N'fa fa-file-image-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (10, N'application/pdf', N'.pdf', N'fa fa-file-pdf-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (11, N'image/png', N'.png', N'fa fa-file-image-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (12, N'application/powerpoint', N'.ppt', N'fa fa-files-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (13, N'application/x-rtf', N'.rtf', N'fa fa-file-text-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (14, N'text/richtext', N'.rtf', N'fa fa-file-text-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (15, N'application/plain', N'.txt', N'fa fa-file-text-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (16, N'text/plain', N'.txt', N'fa fa-file-text-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (17, N'image/tiff', N'.tiff', N'fa fa-file-image-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (18, N'image/x-tiff', N'.tiff', N'fa fa-file-image-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (19, N'application/vnd.ms-excel', N'.xls', N'fa fa-file-excel-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (20, N'application/x-excel', N'.xls', N'fa fa-file-excel-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (21, N'application/x-msexcel', N'.xls', N'fa fa-file-excel-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (22, N'application/xml', N'.xml', N'fa fa-file-text-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (23, N'text/xml', N'.xml', N'fa fa-file-text-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (24, N'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', N'.xlsx', N'fa fa-file-excel-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (25, N'application/x-compressed', N'.zip', N'fa fa-file-archive-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (26, N'application/x-zip-compressed', N'.zip', N'fa fa-file-archive-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (27, N'application/zip', N'.zip', N'fa fa-file-archive-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
INSERT [dbo].[MimeType] ([Ident], [Name1], [Extension], [IconClass], [AddASUserIdent], [AddDateTime], [EditASUserIdent], [EditDateTime], [Active]) VALUES (28, N'multipart/x-zip', N'.zip', N'fa fa-file-archive-o', 0, CAST(N'2015-10-23 09:55:00' AS SmallDateTime), 0, CAST(N'1900-01-01 00:00:00' AS SmallDateTime), 1)
SET IDENTITY_INSERT [dbo].[MimeType] OFF

GO