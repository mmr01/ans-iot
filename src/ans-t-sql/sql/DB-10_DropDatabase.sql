/******************************************************************************************
------------------------------------------------------------------
DROP DATABASE DataCloud
------------------------------------------------------------------
Create Date:        2021-09-06
Author:             Henryk Telega
Description:        This script drops database DataCloud. 
                    All running transactions are rolled back first
					and then all current users are disconnected.
******************************************************************************************/
USE tempdb;
GO
DECLARE @SQL nvarchar(1000);
IF EXISTS (SELECT 1 FROM sys.databases WHERE [name] = N'DataCloud')
BEGIN
    SET @SQL = N'USE [DataCloud];

                 ALTER DATABASE DataCloud SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
                 USE [tempdb];

                 DROP DATABASE DataCloud;';
    EXEC (@SQL);
END;
