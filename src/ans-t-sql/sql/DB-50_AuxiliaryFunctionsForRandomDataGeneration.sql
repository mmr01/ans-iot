/*
------------------------------------------------------------------
AUXILIARY FUNCTIONS FOR RANDOM DATA GENERATION
------------------------------------------------------------------
Create Date:        2021-08-(?)
Author:             Micha³ Markiewicz
Description:        This script creates auxiliary function for random temperatures generation
                    and for tests.
*/
USE  DataCloud;
GO

IF OBJECT_ID('dbo.f_ans_generate') IS NOT NULL
	DROP FUNCTION dbo.f_ans_generate;
GO
IF OBJECT_ID('dbo.f_ans_unpack') IS NOT NULL
	DROP FUNCTION dbo.f_ans_unpack;
GO
IF OBJECT_ID('dbo.f_ans_random') IS NOT NULL
	DROP VIEW dbo.f_ans_random
GO

CREATE VIEW dbo.f_ans_random
AS
SELECT RAND() AS Value
GO

CREATE FUNCTION dbo.f_ans_generate(
	@howManyTemps TINYINT)
RETURNS VARBINARY(256)
AS
BEGIN
	DECLARE @i SMALLINT = 0;
	DECLARE @howMany TINYINT = @howManyTemps;
	DECLARE @buffer VARBINARY(256) = 0x;
	DECLARE @tempL TINYINT = 65;
	DECLARE @tempH TINYINT = 66;
    DECLARE @tempCurr INT = 0;
	DECLARE @tempPrev INT;
	DECLARE @minTemp REAL = 25.0;
	DECLARE @maxTemp REAL = 35.0;

	DECLARE @rnd REAL;
	DECLARE @symbol SMALLINT;
	DECLARE @absoluteValue TINYINT = 7;
	
	WHILE @i < @howMany
        BEGIN
        SET @i = @i + 1;
	    SET @rnd = (SELECT Value FROM dbo.f_ans_random);
		
		IF (@rnd < 0.0025) SET @symbol = -3;
		ELSE IF (@rnd < 0.0171) SET @symbol = -2;
		ELSE IF (@rnd < 0.1332) SET @symbol = -1;
		ELSE IF (@rnd < 0.8565) SET @symbol = -0;
		ELSE IF (@rnd < 0.9760) SET @symbol = +1;
		ELSE IF (@rnd < 0.9924) SET @symbol = +2;
		ELSE IF (@rnd < 0.9955) SET @symbol = +3;
		ELSE SET @symbol = @absoluteValue;
		
		IF (@symbol = @absoluteValue) OR (@i = 1)
		    BEGIN
			DECLARE @tempReal REAL = (SELECT Value FROM dbo.f_ans_random) * (@maxTemp - @minTemp) + @minTemp;
			SET @tempCurr = CAST((@tempReal + 46.85) * (65536.0 / 175.72) AS INT) & 0xFFFC;
			END
		ELSE
			SET @tempCurr = (@tempPrev + @symbol)  & 0xFFFC;
	    SET @tempPrev = @tempCurr
		SET @tempL = @tempCurr % 256
		SET @tempH = @tempCurr / 256
		SET @buffer = @buffer + CAST(CHAR(@tempH) AS BINARY(1)) + CAST(CHAR(@tempL) AS BINARY(1))
		
		END
    RETURN @buffer
END
GO

CREATE FUNCTION dbo.f_ans_unpack(
@inputBuffer VARCHAR(256)
)
RETURNS VARCHAR(256)
AS
BEGIN
	DECLARE @i SMALLINT = 1;
	DECLARE @howMany TINYINT = len(@inputBuffer) / 2;
	DECLARE @buffer VARCHAR(256) = '';
    DECLARE @tempL TINYINT;
	DECLARE @tempH TINYINT;
	DECLARE @tempCurr INT;
	DECLARE @tempReal NUMERIC(5, 2);
	WHILE @i < @howMany
        BEGIN
	    SET @tempL = ASCII(SUBSTRING(@inputBuffer, @i, 1));
		SET @tempH = ASCII(SUBSTRING(@inputBuffer, @i + 1, 1));
		SET @tempCurr = @tempH * 256 + @tempL;
		SET @tempReal = (@tempCurr / 65536.0) * 175.72 - 46.85;
		SET @buffer = @buffer + CAST(@tempReal AS VARCHAR(50)) + ' ';
        SET @i = @i + 2;
        END
	RETURN @buffer;
END
GO
/*
--THIS PART IS FOR TESTS ONLY: 
DECLARE @inputBuffer VARCHAR(256)
--SET @inputBuffer = (SELECT dbo.f_ans_generate(50))
--SELECT @inputBuffer 
--SELECT dbo.f_ans_unpack(@inputBuffer)

DECLARE @temperaturesToEncode VARBINARY(256)
DECLARE @howManyTemperatures INT = DATALENGTH(@temperaturesToEncode)/2

DECLARE @i INT = 1
DECLARE @j INT = 0

WHILE @i <= 100
BEGIN
	--SET @inputBuffer = (SELECT dbo.f_ans_generate(@i))
	SET @temperaturesToEncode = (SELECT dbo.f_ans_generate(@i))
	/*
	SET @j = 0
	WHILE @j < @i/2
	BEGIN
		SET @temperaturesToEncode = @temperaturesToEncode + CAST((ASCII(SUBSTRING(@inputBuffer, @i+1, 1)) & 0xFFFC) AS VARBINARY(2))
		SET @j = @j + 1
	END
	*/
	SET @howManyTemperatures = DATALENGTH(@temperaturesToEncode)/2

	SELECT @temperaturesToEncode AS Temperatures, @howManyTemperatures AS HowMany;
	SELECT dbo.f_ans_encode(@temperaturesToEncode, @howManyTemperatures) AS Encoded
	SELECT CAST(dbo.f_ans_decode(dbo.f_ans_encode(@temperaturesToEncode, @howManyTemperatures), @howManyTemperatures) AS VARBINARY(256)) AS Decoded, DATALENGTH(dbo.f_ans_decode(dbo.f_ans_encode(@temperaturesToEncode, @howManyTemperatures), @howManyTemperatures))/2 AS HowMany
	SELECT CAST(@temperaturesToEncode AS VARBINARY(256)) AS Original,  CAST(dbo.f_ans_decode(dbo.f_ans_encode(@temperaturesToEncode, @howManyTemperatures), @howManyTemperatures) AS VARBINARY(256)) AS DecodedAfterEncoding
	SET @i = @i + 1
END

--DECLARE @minTemp REAL = 25.0;
--DECLARE @maxTemp REAL = 35.0;
--SELECT (CAST((47 + (SELECT Value FROM dbo.f_ans_random) * (@maxTemp - @minTemp) + @minTemp) * 373 AS REAL) / 65536*175.72) -46.85;

--DECLARE @tempReal NUMERIC(4, 2) = 25.67;
--SELECT CAST(@tempReal AS VARCHAR(5)) 
*/