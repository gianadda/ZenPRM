IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspGetEntityInteractionByIdent') 
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspGetEntityInteractionByIdent
GO

/* uspGetEntityInteractionByIdent 506, 1
 *
 *
 *
 *
*/
CREATE PROCEDURE [dbo].[uspGetEntityInteractionByIdent]

	@bntFromEntityIdent BIGINT,
	@bntToEntityIdent BIGINT,
	@bntASUserIdent BIGINT

AS

	SET NOCOUNT ON

	SELECT
		EI.Ident,
		EI.FromEntityIdent,
		EI.ToEntityIdent,
		EI.InteractionText,
		EI.Important,
		EI.AddASUserIdent,
		CONVERT(VARCHAR(10),EI.AddDateTime,101) as [AddDateTime],
		EI.AddDateTime as [AddDateTimeFull],
		EI.EditASUserIdent,
		COALESCE(editU.FullName,'') as [EditUsername],
		EI.EditDateTime,
		EI.Active,
		U.FullName as [Username]
	FROM
		EntityInteraction EI WITH (NOLOCK)
		INNER JOIN
		ASUser U WITH (NOLOCK)
			ON EI.AddASUserIdent = U.Ident
		LEFT OUTER JOIN
		ASUser editU WITH (NOLOCK)
			ON EI.EditASUserIdent = editU.Ident
	WHERE 
		EI.FromEntityIdent = @bntFromEntityIdent
		AND EI.ToEntityIdent = @bntToEntityIdent
		AND EI.Active = 1
	ORDER BY 
		EI.AddDateTime  DESC 

GO

--EXEC uspGetEntityInteractionByIdent 306485, 306495, 1
