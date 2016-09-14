IF EXISTS (select * from dbo.sysobjects where id = object_id(N'uspAddASMessageLog') 
	and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE uspAddASMessageLog
GO

/* uspAddASMessageLog
 *
 *	Adds a record into MessageLog table and returns ident of new record
 *
 */
CREATE PROCEDURE uspAddASMessageLog

	@bntASUserIdent BIGINT ,
	@ncrMessageDescription NVARCHAR(MAX) ,
	@ncrExceptionToString NVARCHAR(MAX) ,
	@ncrClientComputerName NVARCHAR(100) ,
	@ncrServerComputerName NVARCHAR(100) ,
	@ncrGeneratingMethod NVARCHAR(500) ,
	@ncrParentMethod NVARCHAR(500) ,
	@ncrUserName NVARCHAR(400) ,
	@datMessageTime DATETIME,
	@ncrMessageURL NVARCHAR(MAX) = '',
	@ncrCause NVARCHAR(MAX) = ''

AS

	SET NOCOUNT ON

	INSERT INTO ASMessageLog(
		ASUserIdent,
		MessageDescription,
		ExceptionToString,
		ClientComputerName,
		ServerComputerName,
		GeneratingMethod,
		ParentMethod,
		UserName,
		MessageTime,
		MessageURL,
		Cause
	)
	SELECT
		ASUserIdent = @bntASUserIdent,
		MessageDescription = @ncrMessageDescription,
		ExceptionToString = @ncrExceptionToString,
		ClientComputerName = @ncrClientComputerName,
		ServerComputerName = @ncrServerComputerName,
		GeneratingMethod = @ncrGeneratingMethod,
		ParentMethod = @ncrParentMethod,
		UserName = @ncrUserName,
		MessageTime = @datMessageTime,
		MessageURL = @ncrMessageURL,
		Cause = @ncrCause 

	SELECT SCOPE_IDENTITY() AS [Ident]

GO