IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetEntityHierarchyListByEntityIdent') and xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION ufnGetEntityHierarchyListByEntityIdent
GO

/* ufnGetEntityHierarchyListByEntityIdent
 *
 *	Returns a string of the organizations that an entity is tied to, within the customers EntityHierarchy
 *
 */
CREATE FUNCTION ufnGetEntityHierarchyListByEntityIdent(@bntEntityIdent BIGINT, @bntToEntityIdent BIGINT)

	RETURNS NVARCHAR(MAX)

AS

	BEGIN
		
		DECLARE @nvrOrganizationList NVARCHAR(MAX)
		SELECT
			@nvrOrganizationList = COALESCE(@nvrOrganizationList + ', ','') + E.FullName
		FROM 
			EntityHierarchy EH WITH (NOLOCK)
			INNER JOIN
			Entity E WITH (NOLOCK)
				ON E.Ident = EH.FromEntityIdent
		WHERE 
			EH.EntityIdent = @bntEntityIdent
			AND EH.ToEntityIdent = @bntToEntityIdent
			AND EH.Active = 1

		SELECT 
			@nvrOrganizationList = COALESCE(@nvrOrganizationList,  '')


		RETURN RTRIM(LTRIM(@nvrOrganizationList))

	END
	
GO

-- SELECT dbo.ufnGetEntityHierarchyListByEntityIdent(306485, 780744)