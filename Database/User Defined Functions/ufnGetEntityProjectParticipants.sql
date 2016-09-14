IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnGetEntityProjectParticipants') 
	AND OBJECTPROPERTY(id, N'IsTableFunction') = 1)
DROP FUNCTION ufnGetEntityProjectParticipants
GO


/* ufnGetEntityProjectParticipants
 *
 * Returns list of project participants based on input parameters
 *
 *
*/
CREATE FUNCTION ufnGetEntityProjectParticipants(@bntEntityIdent AS BIGINT, @bntEntityProjectIdent AS BIGINT)
RETURNS @tblResults TABLE
(
	Ident BIGINT,
	EntityIdent BIGINT,
	EntityProjectIdent BIGINT
)
AS

	BEGIN

		INSERT INTO @tblResults(
			Ident,
			EntityIdent,
			EntityProjectIdent
		)
		SELECT 
			EPE.Ident,
			EPE.EntityIdent,
			EPE.EntityProjectIdent
		FROM
			EntityProjectEntity EPE WITH (NOLOCK)
			INNER JOIN
			EntityProject EP WITH (NOLOCK)
				ON EP.Ident = EPE.EntityProjectIdent
		WHERE 
			(EP.Ident = @bntEntityProjectIdent OR @bntEntityProjectIdent = 0)
			AND (EP.EntityIdent = @bntEntityIdent OR @bntEntityIdent = 0)
			AND EP.Active = 1
			AND EP.IncludeEntireNetwork = 0
			AND EPE.Active = 1
		GROUP BY
			EPE.Ident,
			EPE.EntityIdent,
			EPE.EntityProjectIdent
		UNION ALL
		SELECT 
			COALESCE(EPE.Ident,0),
			EN.ToEntityIdent,
			EP.Ident
		FROM
			EntityNetwork EN WITH (NOLOCK)
			INNER JOIN
			EntityProject EP WITH (NOLOCK)
				ON EP.EntityIdent = EN.FromEntityIdent
			LEFT OUTER JOIN
			EntityProjectEntity EPE WITH (NOLOCK)
				ON EPE.EntityProjectIdent = @bntEntityProjectIdent
				AND EPE.EntityIdent = EN.ToEntityIdent
				AND EPE.Active = 1
		WHERE 
			(EP.Ident = @bntEntityProjectIdent OR @bntEntityProjectIdent = 0)
			AND (EP.EntityIdent = @bntEntityIdent OR @bntEntityIdent = 0)
			AND EP.Active = 1
			AND EP.IncludeEntireNetwork = 1
			AND EN.Active = 1
		GROUP BY
			EPE.Ident,
			EN.ToEntityIdent,
			EP.Ident

		RETURN

	END
	
GO
