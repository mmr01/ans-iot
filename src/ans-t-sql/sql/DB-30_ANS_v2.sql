/***************************************************************************************************
Function:           dbo.f_ans_decode
Create Date:        2021-07-15
Author:             Michal Markiewicz
Description:        Performs ANS decompression using embedded decoding tables
Call by:            -
Affected table(s):  -
Parameter(s):       @bitBuffer - Buffer consisting of compressed values
                    @howManySymbols - How many symbols should be decoded
Usage:              
                    DECLARE @temperaturesToEncode VARBINARY(40) = 0x1C2C1C2C1C2C1D141D141D141D14;
                    DECLARE @howManyTemperatures TINYINT = 7;
                    SELECT dbo.f_ans_decode(dbo.f_ans_encode(@temperaturesToEncode, @howManyTemperatures), @howManyTemperatures)
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------
2021-07-15          Michal Markiewicz  First version
2021-08-12          Michal Markiewicz  Optimized version (single function call)
2021-08-30			Kamil Bienek	   Optimized version (ignoring unnecessary bits)
****************************************************************************************************/

USE DataCloud2;
GO
IF OBJECT_ID('dbo.f_ans_decode') IS NOT NULL
	DROP FUNCTION dbo.f_ans_decode;
GO
IF OBJECT_ID('dbo.f_ans_encode') IS NOT NULL
	DROP FUNCTION dbo.f_ans_encode;
GO

CREATE FUNCTION dbo.f_ans_decode(
    @bitBuffer VARBINARY(256),
    @howManySymbols TINYINT) 
RETURNS VARBINARY(256)
AS
BEGIN
	DECLARE @i TINYINT = 0;
	DECLARE @bitsRead TINYINT;
	DECLARE @howManyBitsToRead TINYINT;
	DECLARE @bitsInBuffer INT = DATALENGTH(@bitBuffer) * 8;
    -- byte X = ReadBits(R_BIG, bitBuffer, ref bitsInBuffer);

	--Reading how many of next bits will be important
	SET @bitsInBuffer = @bitsInBuffer - 8 - (8 - ASCII(SUBSTRING(@bitBuffer, @bitsInBuffer/8, 1)));

	SET @howManyBitsToRead = 6;
	IF (@bitsInBuffer%8 >= @howManyBitsToRead)
	BEGIN
		SET @bitsRead = ((ASCII(SUBSTRING(@bitBuffer, @bitsInBuffer/8+1, 1))*POWER(2, (@bitsInBuffer%8)-@howManyBitsToRead)) & 255)/POWER(2,8-@howManyBitsToRead);
	END
	ELSE
	BEGIN
		SET @bitsRead = (ASCII(SUBSTRING(@bitBuffer, @bitsInBuffer/8+1, 1))/POWER(2,(8-(@bitsInBuffer%8)))) | ((ASCII(SUBSTRING(@bitBuffer, @bitsInBuffer/8, 1))*POWER(2,8-(@howManyBitsToRead-(@bitsInBuffer%8)))) & 255)/POWER(2,8-@howManyBitsToRead);
	END
	SET @bitsInBuffer = @bitsInBuffer - @howManyBitsToRead;
	--
    DECLARE @X TINYINT = @bitsRead;
	DECLARE @j TINYINT = 0;
	DECLARE @symbol TINYINT;
	DECLARE @decodedSymbols VARCHAR(256) = '';
    -- uint8_t decodingTableSymbol[L] = {2, 4, 3, 3, 3, 3, 3, 3, 2, 4, 3, 3, 3, 3, 3, 3, 3, 2, 4, 3, 3, 3, 3, 3, 3, 3, 2, 3, 4, 3, 3, 3, 3, 3, 3, 2, 3, 4, 3, 3, 3, 3, 3, 3, 2, 3, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 5, 1, 7, 6, 0};
    DECLARE @decodingTableSymbol BINARY(64) = 0x02040303030303030204030303030303030204030303030303030203040303030303030203040303030303030203040303030303030303030303030501070600;
	-- uint8_t decodingTableNBits[L] = {4, 4, 1, 1, 1, 1, 1, 1, 4, 4, 1, 1, 1, 1, 1, 1, 1, 3, 3, 1, 1, 1, 1, 0, 0, 0, 3, 0, 3, 0, 0, 0, 0, 0, 0, 3, 0, 3, 0, 0, 0, 0, 0, 0, 3, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 6, 6};
    DECLARE @decodingTableNBits BINARY(64) = 0x04040101010101010404010101010101010303010101010000000300030000000000000300030000000000000300030000000000000000000000000606060606
    -- uint8_t decodingTableNewX[L] = {32, 32, 30, 32, 34, 36, 38, 40, 48, 48, 42, 44, 46, 48, 50, 52, 54, 0, 0, 56, 58, 60, 62, 0, 1, 2, 8, 3, 8, 4, 5, 6, 7, 8, 9, 16, 10, 16, 11, 12, 13, 14, 15, 16, 24, 17, 24, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 0, 0, 0, 0, 0};
    DECLARE @decodingTableNewX BINARY(64) = 0x20201e202224262830302a2c2e303234360000383a3c3e000102080308040506070809100a100b0c0d0e0f1018111812131415161718191a1b1c1d0000000000;
	DECLARE @absoluteValueSymbol TINYINT = 7;
	DECLARE @temperaturesH VARCHAR(256) = '';
	DECLARE @temperaturesL VARCHAR(256) = ''; 
	DECLARE @temperaturesDecoded VARCHAR(256) = '';
	WHILE (@j < @howManySymbols)
	    BEGIN
		SET @symbol = SUBSTRING(@decodingTableSymbol, @X + 1, 1);
		IF (@symbol = @absoluteValueSymbol)
		    BEGIN
			SET @howManyBitsToRead = 6;
			-- ReadBits(6, bitBuffer, ref bitsInBuffer) & 0x3F) << 8
	        IF (@bitsInBuffer%8 >= @howManyBitsToRead)
			BEGIN
				SET @bitsRead = ((ASCII(SUBSTRING(@bitBuffer, @bitsInBuffer/8+1, 1))*POWER(2, (@bitsInBuffer%8)-@howManyBitsToRead)) & 255)/POWER(2,8-@howManyBitsToRead);
			END
			ELSE
			BEGIN
				SET @bitsRead = (ASCII(SUBSTRING(@bitBuffer, @bitsInBuffer/8+1, 1))/POWER(2,(8-(@bitsInBuffer%8)))) | ((ASCII(SUBSTRING(@bitBuffer, @bitsInBuffer/8, 1))*POWER(2,8-(@howManyBitsToRead-(@bitsInBuffer%8)))) & 255)/POWER(2,8-@howManyBitsToRead);
			END
	        SET @bitsInBuffer = @bitsInBuffer - @howManyBitsToRead;
            --
			SET @temperaturesH = @temperaturesH + CHAR(@bitsRead & 0x3F);
			SET @howManyBitsToRead = 8;
			-- ReadBits(8, bitBuffer, ref bitsInBuffer)
			IF (@bitsInBuffer%8 >= @howManyBitsToRead)
			BEGIN
				SET @bitsRead = ((ASCII(SUBSTRING(@bitBuffer, @bitsInBuffer/8+1, 1))*POWER(2, (@bitsInBuffer%8)-@howManyBitsToRead)) & 255)/POWER(2,8-@howManyBitsToRead);
			END
			ELSE
			BEGIN
				SET @bitsRead = (ASCII(SUBSTRING(@bitBuffer, @bitsInBuffer/8+1, 1))/POWER(2,(8-(@bitsInBuffer%8)))) | ((ASCII(SUBSTRING(@bitBuffer, @bitsInBuffer/8, 1))*POWER(2,8-(@howManyBitsToRead-(@bitsInBuffer%8)))) & 255)/POWER(2,8-@howManyBitsToRead);
			END
	        SET @bitsInBuffer = @bitsInBuffer - @howManyBitsToRead;
			--
			SET @temperaturesL = @temperaturesL + CHAR(@bitsRead);
			END
		SET @decodedSymbols = @decodedSymbols + CHAR(@symbol);
		SET @howManyBitsToRead = SUBSTRING(@decodingTableNBits, @X + 1, 1);
		-- ReadBits(decodingTableNBits[X], bitBuffer, ref bitsInBuffer))
		IF (@bitsInBuffer%8 >= @howManyBitsToRead)
		BEGIN
			SET @bitsRead = ((ASCII(SUBSTRING(@bitBuffer, @bitsInBuffer/8+1, 1))*POWER(2, (@bitsInBuffer%8)-@howManyBitsToRead)) & 255)/POWER(2,8-@howManyBitsToRead);
		END
		ELSE
		BEGIN
			SET @bitsRead = (ASCII(SUBSTRING(@bitBuffer, @bitsInBuffer/8+1, 1))/POWER(2,(8-(@bitsInBuffer%8)))) | ((ASCII(SUBSTRING(@bitBuffer, @bitsInBuffer/8, 1))*POWER(2,8-(@howManyBitsToRead-(@bitsInBuffer%8)))) & 255)/POWER(2,8-@howManyBitsToRead);
		END
	    SET @bitsInBuffer = @bitsInBuffer - @howManyBitsToRead;
		--
		SET @X = SUBSTRING(@decodingTableNewX, @X + 1, 1) + @bitsRead;
		SET @j = @j + 1;
		END
	SET @j = 0;
	DECLARE @absTempIdx TINYINT = DATALENGTH(@temperaturesH);
	DECLARE @maxTemperatureDifferenceForSymbol TINYINT = 3;
	DECLARE @lastTemperature INT = 0;
	WHILE (@j < @howManySymbols)
	    BEGIN
		SET @symbol = ASCII(SUBSTRING(@decodedSymbols, @howManySymbols - @j, 1));
		IF (@symbol = @absoluteValueSymbol)
		    BEGIN
			SET @lastTemperature = ASCII(SUBSTRING(@temperaturesH, @absTempIdx, 1)) * 256 + ASCII(SUBSTRING(@temperaturesL, @absTempIdx, 1));
			SET @absTempIdx = @absTempIdx - 1;
			END
		ELSE
			SET @lastTemperature = @lastTemperature - @maxTemperatureDifferenceForSymbol + @symbol;
		SET @temperaturesDecoded = @temperaturesDecoded + CHAR(@lastTemperature / (256 / 4)) + CHAR((@lastTemperature * 4) % 256);
		SET @j = @j + 1;
        END
	RETURN CAST(@temperaturesDecoded AS VARBINARY(256));
END
GO



/***************************************************************************************************
Function:           dbo.f_ans_encode
Create Date:        2021-07-15
Author:             Michal Markiewicz
Description:        Performs ANS compression using embedded encoding tables
Call by:            -
Affected table(s):  -
Parameter(s):       @temperaturesToEncode - Buffer consisting of temperature values read from sensors (16 bit values uint16_t)
                    @howManyTemperatures - How many bits are stored in the buffer
Usage:              DECLARE @temperaturesToEncode VARBINARY(40) = 0x1020102010201020102010201020;
                    DECLARE @howManyTemperatures TINYINT = 6;
                    SELECT dbo.f_ans_encode(@temperaturesToEncode, @howManyTemperatures)

****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------
2021-07-15          Michal Markiewicz  First version
2021-08-12          Michal Markiewicz  Optimized version (single function call)
2021-08-30			Kamil Bienek	   Optimized version (ignoring unnecessary bits)
****************************************************************************************************/
CREATE FUNCTION dbo.f_ans_encode(
    @temperaturesToEncode VARBINARY(256),
    @howManyTemperatures TINYINT) 
RETURNS 
VARBINARY(256) -- 2 x MAX_TEMPERATURES, cannot concatenate VARBINARY 
AS
BEGIN
    DECLARE @absoluteValueSymbol TINYINT = 7;
	DECLARE @tempCurr INT = 0;
	DECLARE @tempPrev INT;
	DECLARE @maxTemperatureDifferenceForSymbol TINYINT = 3;
	DECLARE @symbolsFromTemperatures VARCHAR(256) = ''; -- 2 x MAX_TEMPERATURES
	DECLARE @i INT = 0;
	WHILE @i < @howManyTemperatures -- MAX_TEMPERATURES
		BEGIN
		SET @i = @i + 1;
		SET @tempCurr = 
				(CAST(SUBSTRING(@temperaturesToEncode, 2 * @i - 1, 1) AS TINYINT) * (256/4)) +
				(CAST(SUBSTRING(@temperaturesToEncode, 2 * @i, 1) AS TINYINT) / 4);
		IF (@i = 1)
			SET @symbolsFromTemperatures = CHAR(@absoluteValueSymbol);
		ELSE
			BEGIN
			DECLARE @DIFF INT = @tempCurr - @tempPrev;
			IF (ABS(@DIFF) <= @maxTemperatureDifferenceForSymbol)
				SET @symbolsFromTemperatures = @symbolsFromTemperatures + CHAR(CAST(@DIFF + @maxTemperatureDifferenceForSymbol AS TINYINT));
			ELSE
				SET @symbolsFromTemperatures = @symbolsFromTemperatures + CHAR(@absoluteValueSymbol);
			END;
		SET @tempPrev = @tempCurr;
		END
	DECLARE @x TINYINT = 64;
	DECLARE @nbBits TINYINT;
	DECLARE @symbolToEncode TINYINT;
	-- uint16_t nb[SYMBOLS] = {704, 704, 416, 34, 416, 704, 704, 704};
	DECLARE @nbL BINARY(8) = 0xc0c0a022a0c0c0c0;
	DECLARE @nbH BINARY(8) = 0x0202010001020202;
	-- int16_t start[SYMBOLS] = {-1, 0, -4, -39, 49, 60, 61, 62};
	DECLARE @startShiftToAvoidZero SMALLINT = 40;
	DECLARE @start BINARY(8) = 0x2728240159646566;
	-- uint8_t encodingTable[L] = {127, 124, 64, 72, 81, 90, 99, 108, 66, 67, 68, 69, 70, 71, 74, 75, 76, 77, 78, 79, 80, 83, 84, 85, 86, 87, 88, 89, 91, 93, 94, 95, 96, 97, 98, 100, 102, 103, 104, 105, 106, 107, 109, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 65, 73, 82, 92, 101, 110, 123, 126, 125};
	DECLARE @encodingTable BINARY(64) = 0X7f7c4048515a636c4243444546474a4b4c4d4e4f50535455565758595b5d5e5f60616264666768696a6b6d6f707172737475767778797a4149525c656e7b7e7d;
	DECLARE @currentBitInsideByte SMALLINT = 7;
	DECLARE @howManyBitsToWrite SMALLINT;
	DECLARE @bitsToWrite TINYINT;
	DECLARE @oldBitsToWrite TINYINT = 0x00;
	DECLARE @oldBitsSize INT = 0;
	DECLARE @bufferInput TINYINT = 0x00;
	DECLARE @bitsInBuffer INT = 0;
	DECLARE @bitBuffer VARCHAR(256) = '';
	DECLARE @temperature SMALLINT;
	DECLARE @j SMALLINT = 0;
	WHILE @j < @howManyTemperatures -- MAX_TEMPERATURES
		BEGIN
		SET @j = @j + 1;
		SET @symbolToEncode = ASCII(SUBSTRING(@symbolsFromTemperatures, @j, 1));
		SET @nbBits = (@x + 256 * SUBSTRING(@nbH, @symbolToEncode + 1, 1) + SUBSTRING(@nbL, @symbolToEncode + 1, 1)) / 128;
		-- appendNBits(nbBits, x);
		SET @bitsToWrite = @x;
		SET @howManyBitsToWrite = @nbBits;

		SET @bitsToWrite = ((@bitsToWrite*POWER(2,8-@howManyBitsToWrite)) & 255)/POWER(2,8-@howManyBitsToWrite);
		IF (@howManyBitsToWrite+@oldBitsSize >= 8)
		BEGIN
			SET @bufferInput = (@oldBitsToWrite*POWER(2, 8-@oldBitsSize)) | (@bitsToWrite/POWER(2,@oldBitsSize+@howManyBitsToWrite-8));
			SET @bitBuffer = @bitBuffer + CHAR(@bufferInput);
			SET @oldBitsToWrite = (@bitsToWrite*POWER(2,8-(@oldBitsSize+@howManyBitsToWrite-8)) & 255)/POWER(2,8-(@oldBitsSize+@howManyBitsToWrite-8));
			SET @bitsInBuffer = @bitsInBuffer + 8;
			SET @oldBitsSize = @howManyBitsToWrite+@oldBitsSize-8;
		END
		ELSE
		BEGIN
			SET @oldBitsToWrite = (@oldBitsToWrite*POWER(2, @howManyBitsToWrite)) | (@bitsToWrite);
			SET @oldBitsSize = @oldBitsSize + @howManyBitsToWrite
		END
		--
		IF (@symbolToEncode = @absoluteValueSymbol)
			BEGIN
			SET @temperature = 
				(CAST(SUBSTRING(@temperaturesToEncode, 2 * @j - 1, 1) AS TINYINT) * (256/4)) +
				(CAST(SUBSTRING(@temperaturesToEncode, 2 * @j, 1) AS TINYINT) / 4);
			-- appendNBits(8, (temperaturesToEncode[i] >> SHIFT_16_BITS_VALUE_TO_14_BITS) & 0xFF);
			SET @howManyBitsToWrite = 8;
			SET @bitsToWrite = @temperature & 0xFF;

			SET @bitsToWrite = ((@bitsToWrite*POWER(2,8-@howManyBitsToWrite)) & 255)/POWER(2,8-@howManyBitsToWrite);
			IF (@howManyBitsToWrite+@oldBitsSize >= 8)
			BEGIN
				SET @bufferInput = (@oldBitsToWrite*POWER(2, 8-@oldBitsSize)) | (@bitsToWrite/POWER(2,@oldBitsSize+@howManyBitsToWrite-8));
				SET @bitBuffer = @bitBuffer + CHAR(@bufferInput);
				SET @oldBitsToWrite = (@bitsToWrite*POWER(2,8-(@oldBitsSize+@howManyBitsToWrite-8)) & 255)/POWER(2,8-(@oldBitsSize+@howManyBitsToWrite-8));
				SET @bitsInBuffer = @bitsInBuffer + 8;
				SET @oldBitsSize = @howManyBitsToWrite+@oldBitsSize-8;
			END
			ELSE
			BEGIN
				SET @oldBitsToWrite = (@oldBitsToWrite*POWER(2, @howManyBitsToWrite)) | (@bitsToWrite);
				SET @oldBitsSize = @oldBitsSize + @howManyBitsToWrite
			END
			--
			-- appendNBits(6, ((temperaturesToEncode[i] >> SHIFT_16_BITS_VALUE_TO_14_BITS) >> 8) & 0x3F);
			SET @howManyBitsToWrite = 6;
			SET @bitsToWrite = (@temperature / 256) & 0x3F;

			SET @bitsToWrite = ((@bitsToWrite*POWER(2,8-@howManyBitsToWrite)) & 255)/POWER(2,8-@howManyBitsToWrite);
			IF (@howManyBitsToWrite+@oldBitsSize >= 8)
			BEGIN
				SET @bufferInput = (@oldBitsToWrite*POWER(2, 8-@oldBitsSize)) | (@bitsToWrite/POWER(2,@oldBitsSize+@howManyBitsToWrite-8));
				SET @bitBuffer = @bitBuffer + CHAR(@bufferInput);
				SET @oldBitsToWrite = (@bitsToWrite*POWER(2,8-(@oldBitsSize+@howManyBitsToWrite-8)) & 255)/POWER(2,8-(@oldBitsSize+@howManyBitsToWrite-8));
				SET @bitsInBuffer = @bitsInBuffer + 8;
				SET @oldBitsSize = @howManyBitsToWrite+@oldBitsSize-8;
			END
			ELSE
			BEGIN
				SET @oldBitsToWrite = (@oldBitsToWrite*POWER(2, @howManyBitsToWrite)) | (@bitsToWrite);
				SET @oldBitsSize = @oldBitsSize + @howManyBitsToWrite
			END
			--
			END
		SET @x = SUBSTRING(@encodingTable, 1 + CAST(@x / (POWER(2, @nbBits)) AS TINYINT) + (CAST(SUBSTRING(@start, @symbolToEncode + 1, 1) AS SMALLINT) - @startShiftToAvoidZero), 1);
		
		END

	-- appendNBits(6, x & 0x3F);
	SET @howManyBitsToWrite = 6;
	SET @bitsToWrite = @x & 0x3F;

	SET @bitsToWrite = ((@bitsToWrite*POWER(2,8-@howManyBitsToWrite)) & 255)/POWER(2,8-@howManyBitsToWrite);
	IF (@howManyBitsToWrite+@oldBitsSize >= 8)
	BEGIN
		SET @bufferInput = (@oldBitsToWrite*POWER(2, 8-@oldBitsSize)) | (@bitsToWrite/POWER(2,@oldBitsSize+@howManyBitsToWrite-8));
		SET @bitBuffer = @bitBuffer + CHAR(@bufferInput);
		SET @oldBitsToWrite = (@bitsToWrite*POWER(2,8-(@oldBitsSize+@howManyBitsToWrite-8)) & 255)/POWER(2,8-(@oldBitsSize+@howManyBitsToWrite-8));
		SET @bitsInBuffer = @bitsInBuffer + 8;
		SET @oldBitsSize = @howManyBitsToWrite+@oldBitsSize-8;
	END
	ELSE
	BEGIN
		SET @oldBitsToWrite = (@oldBitsToWrite*POWER(2, @howManyBitsToWrite)) | (@bitsToWrite);
		SET @oldBitsSize = @oldBitsSize + @howManyBitsToWrite;
	END

	IF (@oldBitsSize <> 0)
	BEGIN
		SET @bitBuffer = @bitBuffer + CHAR(@oldBitsToWrite*POWER(2, 8-@oldBitsSize));
	END
	SET @bitsInBuffer = @bitsInBuffer + @oldBitsSize;
	SET @oldBitsToWrite = 0x00;

	--Additional byte's value represents number of important bits in previous byte(which is last byte with information)

	IF (@oldBitsSize <> 0) 
		SET @bitBuffer = @bitBuffer + CHAR(@oldBitsSize);
	ELSE
		SET @bitBuffer = @bitBuffer + CHAR(8);
	--
	RETURN CAST(@bitBuffer AS VARBINARY(256));
END
GO

/*
THIS PART IS FOR TESTS ONLY:
DECLARE @temperaturesToEncode VARBINARY(40) = 0x1C2C1C2C1C2C1D141D141D141D14;
--DECLARE @temperaturesToEncode VARBINARY(40) = 0x1020102010201020102010201020;
--DECLARE @temperaturesToEncode VARBINARY(40) = 0x2010201020102010201020102010;
DECLARE @howManyTemperatures TINYINT = 7;
--DECLARE @howManyBitsInBuffer INT = 49;
SELECT @temperaturesToEncode AS Temperatures, @howManyTemperatures AS HowMany;
SELECT dbo.f_ans_encode(@temperaturesToEncode, @howManyTemperatures) AS Encoded
SELECT dbo.f_ans_decode(dbo.f_ans_encode(@temperaturesToEncode, @howManyTemperatures), @howManyTemperatures) AS Decoded
SELECT CAST(@temperaturesToEncode AS VARBINARY(256)) AS Original,  CAST(dbo.f_ans_decode(dbo.f_ans_encode(@temperaturesToEncode, @howManyTemperatures), @howManyTemperatures) AS VARBINARY(256)) AS DecodedAfterEncoding
*/