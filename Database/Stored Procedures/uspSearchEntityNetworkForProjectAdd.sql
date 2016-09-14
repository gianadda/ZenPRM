IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspSearchEntityNetworkForProjectAdd') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspSearchEntityNetworkForProjectAdd
GO

/* uspSearchEntityNetworkForProjectAdd
 *
 *
 *
 *
*/
CREATE PROCEDURE uspSearchEntityNetworkForProjectAdd

	@bntEntityIdent BIGINT,
	@bntEntityProjectIdent BIGINT,
	@nvrKeyword NVARCHAR(500)

AS

	SET NOCOUNT ON

	DECLARE @bitEntityIsACustomer AS BIT
	SET @bitEntityIsACustomer = 0
	
	SELECT 
		@bitEntityIsACustomer = 1
	FROM
		Entity E WITH (NOLOCK)
	WHERE 
		E.Ident = @bntEntityIdent
		AND E.Customer = 1
		AND E.Active = 1

	SET @nvrKeyword = '%' + @nvrKeyword + '%'
	
	CREATE TABLE #tmpEntityIdents(
		Ident BIGINT,
		IsInProject BIT
	)
	
	INSERT INTO #tmpEntityIdents (
		Ident,
		IsInProject
	)
	SELECT DISTINCT
		E.Ident ,
		IsInProject = 0
	FROM
		Entity E WITH (NOLOCK)
		INNER JOIN
		EntityNetwork EN WITH (NOLOCK)
			ON EN.FromEntityIdent = @bntEntityIdent
				AND EN.ToEntityIdent = E.Ident
	WHERE 
		E.Active = 1
		AND E.FullName <> ''
		--AND E.NPI <> ''
		AND (RTRIM(LTRIM(E.FullName)) like @nvrKeyword OR E.NPI like @nvrKeyword)	
		AND @bitEntityIsACustomer = 1

	UPDATE
		tEI
	SET
		IsInProject = 1
	FROM
		#tmpEntityIdents tEI WITH (NOLOCK)
		INNER JOIN
		EntityProjectEntity EPE WITH (NOLOCK)
			ON EPE.EntityIdent = tEI.Ident
	WHERE
		EPE.EntityProjectIdent = @bntEntityProjectIdent
		AND EPE.Active = 1

	SELECT DISTINCT
		tEI.Ident,
		E.FullName
	FROM
		#tmpEntityIdents tEI WITH (NOLOCK)
		INNER JOIN
		Entity E WITH (NOLOCK)
			ON tEI.Ident = E.Ident
	WHERE
		tEI.IsInProject = 0
	ORDER BY 
		FullName ASC

	DROP TABLE #tmpEntityIdents

GO