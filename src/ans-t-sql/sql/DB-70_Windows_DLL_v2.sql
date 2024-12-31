USE master
GO
sp_configure 'clr enabled', 1
GO
RECONFIGURE
GO
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
EXEC sp_configure 'clr strict security', 0;
RECONFIGURE;

ALTER DATABASE DataCloud2 SET TRUSTWORTHY ON;
GO

USE DataCloud2
GO

IF OBJECT_ID('dbo.ANSEncode') IS NOT NULL
    DROP FUNCTION ANSEncode
GO
IF OBJECT_ID('dbo.ANSDecode') IS NOT NULL
    DROP FUNCTION ANSDecode
GO

IF EXISTS(SELECT * FROM sys.assemblies WHERE name = 'ANSDBDLL')
    DROP ASSEMBLY ANSDBDLL
GO

CREATE ASSEMBLY ANSDBDLL
FROM 'C:\ANS\art-ans\src\ans-cs\dbdll\bin\Debug\ANS_DBDLL.dll'
--FROM 'c:\ANSStudent\ans\MM\ans-cs\dbdll\Bin\Debug\ANS_DBDLL.dll'
--FROM 'c:\Users\htele\Desktop\ANSStudent\ans\MM\ans-cs\dbdll\bin\Debug\ANS_DBDLL.dll'
WITH PERMISSION_SET = SAFE
go

CREATE FUNCTION ANSEncode(@b VARBINARY(256))
RETURNS VARBINARY(256)
AS
EXTERNAL NAME ANSDBDLL.UserDefinedFunctions.ANSEncode;
GO


CREATE FUNCTION ANSDecode(@b VARBINARY(256) @n SMALLINT)
RETURNS VARBINARY(256)
AS
EXTERNAL NAME ANSDBDLL.UserDefinedFunctions.ANSDecode;
GO
/*
DECLARE @temperaturesToEncode VARBINARY(256) 
SET @temperaturesToEncode = 0x1C2C1C2C1C2C1D141D141D14;--1D14;
--SET @temperaturesToEncode = 0x1C2C1C2C1C2C1D141D141D141D14;1C2C1C2C1C2C1D141D141D141D14
--DECLARE @temperaturesToEncode VARBINARY(40) = 0x1020102010201020102010201020;
--DECLARE @temperaturesToEncode VARBINARY(40) = 0x2010201020102010201020102010;
DECLARE @howManyTemperatures TINYINT = 6;
SELECT @temperaturesToEncode AS Temperatures, @howManyTemperatures AS HowMany;
--SELECT dbo.ANSEncode(@temperaturesToEncode) AS Encoded
SELECT dbo.ANSDecode(dbo.ANSEncode(@temperaturesToEncode)) AS Decoded

*/





