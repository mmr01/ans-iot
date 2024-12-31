/*************************************************************************************************
------------------------------------------------------------------
CREATE TABLES
------------------------------------------------------------------
Create Date:        2021-09-06
Author:             Henryk Telega
Description:        This script creates tables: 
                      t_readouts (temperatures are not compressed),
                      t_readouts_ans (the same temperatures are comressed with ANS),
					  t_readouts_compress (the same temperatures 
					                       are comressed with the standard COMPRESS function). 
                    If these tables already exist they are dropped first.
                    If there are appropriate filegroups in the database, 
                    the tables are created in separate filegroups.
                    Otherwise, they are created in the default filegroup (PRIMARY).
					If DataCloud database does not exist it is creted with NO filegroups.
**************************************************************************************************/

IF NOT EXISTS (SELECT name FROM master.sys.databases 
               WHERE name = 'DataCloud') 
	CREATE DATABASE DataCloud
GO
USE DataCloud;
GO

IF OBJECT_ID('t_readouts_source') IS NOT NULL
    DROP TABLE t_readouts_source;
GO 
CREATE TABLE t_readouts_source (
        rea_id INT IDENTITY (1,1) PRIMARY KEY,
		rea_sen_id TINYINT, /* 1 byte */
        rea_audit_cd DATETIME DEFAULT GETDATE(),
        --rea_sequence TINYINT, /* 0-255 */
        rea_temperatures VARBINARY(256),
        --rea_rssi SMALLINT /* 2 bytes with sign */
) ON [PRIMARY];

IF OBJECT_ID('t_readouts_raw') IS NOT NULL
    DROP TABLE t_readouts_raw;
GO 
IF EXISTS(SELECT 1 FROM sys.filegroups WHERE name = N'OriginalTemperaturesFG')
    CREATE TABLE t_readouts_raw (
        rea_id INT IDENTITY (1,1) PRIMARY KEY,
		rea_sen_id TINYINT, /* 1 byte */
        rea_audit_cd DATETIME DEFAULT GETDATE(),
        --rea_sequence TINYINT, /* 0-255 */
        rea_temperatures VARBINARY(256),
        --rea_rssi SMALLINT, /* 2 bytes with sign */
    ) ON OriginalTemperaturesFG;
ELSE
    CREATE TABLE t_readouts_raw (
        rea_id INT IDENTITY (1,1) PRIMARY KEY,
		rea_sen_id TINYINT, /* 1 byte */
        rea_audit_cd DATETIME DEFAULT GETDATE(),
        --rea_sequence TINYINT, /* 0-255 */
        rea_temperatures VARBINARY(256),
        --rea_rssi SMALLINT /* 2 bytes with sign */
    );


IF OBJECT_ID('t_readouts_compress') IS NOT NULL
    DROP TABLE t_readouts_compress;
GO 
IF EXISTS(SELECT 1 FROM sys.filegroups WHERE name = N'CompressTemperaturesFG')
    CREATE TABLE t_readouts_compress (
        rea_id INT IDENTITY (1,1) PRIMARY KEY,
        rea_sen_id TINYINT, /* 1 byte */
		rea_audit_cd DATETIME DEFAULT GETDATE(),
        --rea_sequence TINYINT, /* 0-255 */
        rea_temperatures VARBINARY(256),
        --rea_rssi SMALLINT /* 2 bytes with sign */
    ) ON CompressTemperaturesFG;
ELSE
    CREATE TABLE t_readouts_compress (
        rea_id INT IDENTITY (1,1) PRIMARY KEY,
		rea_sen_id TINYINT, /* 1 byte */
        rea_audit_cd DATETIME DEFAULT GETDATE(),
        --rea_sequence TINYINT, /* 0-255 */
        rea_temperatures VARBINARY(256),
        --rea_rssi SMALLINT /* 2 bytes with sign */
    );
GO
/*
Sensors are currently unable to send data compressed by Huffman
IF OBJECT_ID('t_readouts_raw_compress') IS NOT NULL
    DROP TABLE t_readouts_raw_compress;
GO 
IF EXISTS(SELECT 1 FROM sys.filegroups WHERE name = N'CompressTemperaturesFG')
    CREATE TABLE t_readouts_raw_compress (
        rea_id INT IDENTITY (1,1) PRIMARY KEY,
        rea_sen_id TINYINT, /* 1 byte */
		rea_audit_cd DATETIME DEFAULT GETDATE(),
        --rea_sequence TINYINT, /* 0-255 */
        rea_temperatures VARBINARY(256),
        --rea_rssi SMALLINT /* 2 bytes with sign */
    ) ON CompressTemperaturesFG;
ELSE
    CREATE TABLE t_readouts_raw_compress (
        rea_id INT IDENTITY (1,1) PRIMARY KEY,
		rea_sen_id TINYINT, /* 1 byte */
        rea_audit_cd DATETIME DEFAULT GETDATE(),
        --rea_sequence TINYINT, /* 0-255 */
        rea_temperatures VARBINARY(256),
        --rea_rssi SMALLINT /* 2 bytes with sign */
    );
--GO
*/
IF OBJECT_ID('t_readouts_ans_tsql') IS NOT NULL
    DROP TABLE t_readouts_ans_tsql;
GO 
IF EXISTS(SELECT 1 FROM sys.filegroups WHERE name = N'ANSTemperaturesFG')
    CREATE TABLE t_readouts_ans_tsql (
        rea_id INT IDENTITY (1,1) PRIMARY KEY,
        rea_sen_id TINYINT, /* 1 byte */
		rea_audit_cd DATETIME DEFAULT GETDATE(),
        --rea_sequence TINYINT, /* 0-255 */
        rea_temperatures VARBINARY(256),
        --rea_rssi SMALLINT /* 2 bytes with sign */
    ) ON ANSTemperaturesFG;
ELSE
    CREATE TABLE t_readouts_ans_tsql (
        rea_id INT IDENTITY (1,1) PRIMARY KEY,
		rea_sen_id TINYINT, /* 1 byte */
        rea_audit_cd DATETIME DEFAULT GETDATE(),
        --rea_sequence TINYINT, /* 0-255 */
        rea_temperatures VARBINARY(256),
        --rea_rssi SMALLINT /* 2 bytes with sign */
    );
GO

IF OBJECT_ID('t_readouts_ans_cs') IS NOT NULL
    DROP TABLE t_readouts_ans_cs;
GO 
IF EXISTS(SELECT 1 FROM sys.filegroups WHERE name = N'ANSTemperaturesFG')
    CREATE TABLE t_readouts_ans_cs (
        rea_id INT IDENTITY (1,1) PRIMARY KEY,
        rea_sen_id TINYINT, /* 1 byte */
		rea_audit_cd DATETIME DEFAULT GETDATE(),
        --rea_sequence TINYINT, /* 0-255 */
        rea_temperatures VARBINARY(256),
        --rea_rssi SMALLINT /* 2 bytes with sign */
    ) ON ANSTemperaturesFG;
ELSE
    CREATE TABLE t_readouts_ans_cs (
        rea_id INT IDENTITY (1,1) PRIMARY KEY,
		rea_sen_id TINYINT, /* 1 byte */
        rea_audit_cd DATETIME DEFAULT GETDATE(),
        --rea_sequence TINYINT, /* 0-255 */
        rea_temperatures VARBINARY(256),
        --rea_rssi SMALLINT /* 2 bytes with sign */
    );
GO

IF OBJECT_ID('t_readouts_raw_ans') IS NOT NULL
    DROP TABLE t_readouts_raw_ans;
GO 
IF EXISTS(SELECT 1 FROM sys.filegroups WHERE name = N'ANSTemperaturesFG')
    CREATE TABLE t_readouts_raw_ans (
        rea_id INT IDENTITY (1,1) PRIMARY KEY,
        rea_sen_id TINYINT, /* 1 byte */
		rea_audit_cd DATETIME DEFAULT GETDATE(),
        --rea_sequence TINYINT, /* 0-255 */
        rea_temperatures VARBINARY(256),
        --rea_rssi SMALLINT /* 2 bytes with sign */
    ) ON ANSTemperaturesFG;
ELSE
    CREATE TABLE t_readouts_raw_ans (
        rea_id INT IDENTITY (1,1) PRIMARY KEY,
		rea_sen_id TINYINT, /* 1 byte */
        rea_audit_cd DATETIME DEFAULT GETDATE(),
        --rea_sequence TINYINT, /* 0-255 */
        rea_temperatures VARBINARY(256),
        --rea_rssi SMALLINT /* 2 bytes with sign */
    );
GO


