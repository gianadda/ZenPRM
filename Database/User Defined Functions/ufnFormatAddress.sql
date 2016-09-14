IF EXISTS (select * from dbo.sysobjects where id = object_id(N'ufnFormatAddress') 
	AND OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
DROP FUNCTION ufnFormatAddress
GO
/* ufnFormatAddress
 *
 *	Formats the address into a readable string, i.e.
 *	Address 1, Address 2, Address 3, City, State, Zip
 *
 */
CREATE FUNCTION ufnFormatAddress(@bntEntityProjectEntityAnswerIdent AS BIGINT)

	RETURNS NVARCHAR(MAX)
	
 BEGIN

	DECLARE @nvrOutput NVARCHAR(MAX)
	DECLARE @nvrAddress1 NVARCHAR(MAX)
	DECLARE @nvrAddress2 NVARCHAR(MAX)
	DECLARE @nvrCity NVARCHAR(MAX)
	DECLARE @nvrStateName NVARCHAR(MAX)
	DECLARE @nvrZip NVARCHAR(MAX)

	SET @nvrOutput = ''

	DECLARE @tblValues TABLE(
		Name1 NVARCHAR(MAX),
		Value1 NVARCHAR(MAX)
	)

	-- first, get a list of all the current answers for the address, we will work through each one individually
	INSERT INTO @tblValues(
		Name1,
		Value1
	)
	SELECT
		Name1,
		Value1
	FROM
		EntityProjectEntityAnswerValue WITH (NOLOCK)
	WHERE
		EntityProjectEntityAnswerIdent = @bntEntityProjectEntityAnswerIdent
		AND Active = 1

	SELECT
		@nvrAddress1 = Value1
	FROM
		@tblValues
	WHERE
		Name1 = 'Address1'

	SELECT
		@nvrAddress2 = Value1
	FROM
		@tblValues
	WHERE
		Name1 = 'Address2'

	SELECT
		@nvrCity = Value1
	FROM
		@tblValues
	WHERE
		Name1 = 'City'

	SELECT
		@nvrStateName = Value1
	FROM
		@tblValues
	WHERE
		Name1 = 'StateName'
		
	SELECT
		@nvrZip = Value1
	FROM
		@tblValues
	WHERE
		Name1 = 'Zip'

	SET @nvrOutput = LTRIM(RTRIM(@nvrAddress1 + ',' + @nvrAddress2 + ',' + @nvrCity + ',' + @nvrStateName + ',' + @nvrZip))
	SET @nvrOutput = REPLACE(@nvrOutput, ',,',',') -- if there is any missing data, remove that blank entry
	SET @nvrOutput = REPLACE(@nvrOutput, ',',', ') -- and then pad

	IF (RIGHT(@nvrOutput,1) = ',') -- remove any trailing commas
		BEGIN
			SET @nvrOutput = LEFT(@nvrOutput, (LEN(@nvrOutput) - 1))
		END

	RETURN @nvrOutput

 END

GO
