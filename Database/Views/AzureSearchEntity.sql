--Create view with schemabinding.
IF OBJECT_ID ('AzureSearchEntity', 'view') IS NOT NULL
DROP VIEW AzureSearchEntity ;
GO
CREATE VIEW AzureSearchEntity
WITH SCHEMABINDING
AS
    SELECT 
		E.Ident,
		E.FullName,
		E.Latitude, 
		E.Longitude,
		E.EntityTypeIdent,
		ET.Name1 AS EntityTypeName1,
		ET.IncludeInCNP as [IncludeInCNP],
		ET.Person as [Person],
		E.Registered,
		E.SoleProvider,
		E.AcceptingNewPatients,
		E.GenderIdent,
		G.Name1 AS GenderName1,
		'["' + STUFF(
				(
				SELECT DISTINCT 
					',"' + CONVERT(VARCHAR,t.Ident)  + '"'
				FROM 
					dbo.Language1 t
					INNER JOIN
					dbo.EntityLanguage1XRef tx
						ON E.Ident = tx.EntityIdent
				WHERE 
					t.Ident = tx.Language1Ident
					AND t.Active = 1 
					AND tx.Active = 1
					AND t.Ident <> 0
				FOR XML PATH('')
				)
			 , 1, 2, '') + ']' AS [Language],
		dbo.ufnGetEntityLanguageListByEntityIdent(E.Ident) as [LanguageList],
		'["' + STUFF(
				(
				SELECT DISTINCT 
					',"' + CONVERT(VARCHAR,t.Ident)   + '"'
				FROM 
					dbo.Degree t
					INNER JOIN
					dbo.EntityDegreeXRef tx
						ON E.Ident = tx.EntityIdent
				WHERE 
					t.Ident = tx.DegreeIdent
					AND t.Active = 1 
					AND tx.Active = 1
					AND t.Ident <> 0
				FOR XML PATH('')
				)
			 , 1, 2, '') + ']' AS [Degree],
		dbo.ufnGetEntityDegreeListByEntityIdent(E.Ident) as [DegreeList],
		'["' + STUFF(
				(
				SELECT DISTINCT 
					',"' + CONVERT(VARCHAR,t.Ident)   + '"'
				FROM 
					dbo.Payor t
					INNER JOIN
					dbo.EntityPayorXRef tx
						ON E.Ident = tx.EntityIdent
				WHERE 
					t.Ident = tx.PayorIdent
					AND t.Active = 1
					AND tx.Active = 1
					AND t.Ident <> 0
				FOR XML PATH('')
				)
			 , 1, 2, '') + ']' AS [Payor],
		dbo.ufnGetEntityPayorListByEntityIdent(E.Ident) as [PayorList],
		'["' + STUFF(
				(
				SELECT DISTINCT
					',"' + CONVERT(VARCHAR,t.Ident)   + '"'
				FROM 
					dbo.Speciality t
					INNER JOIN
					dbo.EntitySpecialityXRef tx
						ON E.Ident = tx.EntityIdent
				WHERE 
					t.Ident = tx.SpecialityIdent
					AND t.Active = 1
					AND tx.Active = 1
					AND t.Ident <> 0
				FOR XML PATH('')
				)
			 , 1, 2, '') + ']' AS [Specialty],
		dbo.ufnGetEntitySpecialtyListByEntityIdent(E.Ident) as [SpecialtyList],
		'["' + STUFF(
				(
				SELECT DISTINCT
					',"' + CONVERT(VARCHAR,toE.Ident)  + '"'
				FROM 
					dbo.ConnectionType CT
					INNER JOIN
					dbo.EntityConnection EC 
						ON CT.Ident = EC.ConnectionTypeIdent
					INNER JOIN
					dbo.Entity toE
						ON EC.ToEntityIdent = toE.Ident
							AND CT.ToEntityTypeIdent = toE.EntityTypeIdent
				WHERE 
					EC.FromEntityIdent = E.Ident
					AND CT.IncludeInNetwork = 0 -- Don't include network links
					AND CT.Delegate = 0 -- Don't include Delegate links
					AND toE.Ident <> 0
					AND toE.Active = 1
					AND EC.Active = 1
					AND CT.Active = 1
				FOR XML PATH('')
				)
			 , 1, 2, '') + ']' AS [Connection],
		'["' + STUFF(
				(
				SELECT DISTINCT
					',"' + CONVERT(VARCHAR,EN.FromEntityIdent)   + '"'
				FROM 
					dbo.EntityNetwork EN 
				WHERE 
					EN.ToEntityIdent = E.Ident
				FOR XML PATH('')
				)
			 , 1, 2, '') + ']' AS [InNetworkOf],
		E.Active,
		E.EditDateTime,
		E.GeoLocation
	FROM
		dbo.Entity E 
		INNER JOIN
		dbo.EntityType ET 
			ON ET.Ident = E.EntityTypeIdent
		INNER JOIN 
		dbo.Gender G
			ON E.GenderIdent = G.Ident

GO


select top 100 * from AzureSearchEntity WHERE not InNetworkOf is null

