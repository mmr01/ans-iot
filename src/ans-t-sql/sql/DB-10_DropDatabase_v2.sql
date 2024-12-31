/******************************************************************************************
------------------------------------------------------------------
DROP DATABASE DataCloud2
------------------------------------------------------------------
Create Date:        2021-09-24
Author:             Henryk Telega
Description:        This script drops database DataCloud. 
                    All running transactions are rolled back first
					and then all current users are disconnected.
******************************************************************************************/
USE tempdb;
GO
DECLARE @SQL nvarchar(1000);
IF EXISTS (SELECT 1 FROM sys.databases WHERE [name] = N'DataCloud2')
BEGIN
    SET @SQL = N'USE [DataCloud2];

                 ALTER DATABASE DataCloud2 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
                 USE [tempdb];

                 DROP DATABASE DataCloud2;';
    EXEC (@SQL);
END;
