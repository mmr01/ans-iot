/******************************************************************************************
------------------------------------------------------------------
RANDOM DATA GENERATION 
------------------------------------------------------------------
Create Date:        2021-09-24
Author:             Henryk Telega
Description:        This script truncates all three tables and generates 
                    and inserts new rows to each table.
NOTE:               The number of packets sent from sensors to the database server 
                    per hour is passed as an SQLCMD parameter 
					DO NOT RUN THIS SCRIPT IN SSMS !!!! It should be executed by SQLCMD !!!!
******************************************************************************************/

USE DataCloud
GO

TRUNCATE TABLE dbo.t_readouts_source;
GO

TRUNCATE TABLE dbo.t_readouts_raw;
GO

TRUNCATE TABLE dbo.t_readouts_ans_tsql;
GO

TRUNCATE TABLE dbo.t_readouts_ans_cs;
GO

TRUNCATE TABLE dbo.t_readouts_raw_ans;
GO

TRUNCATE TABLE dbo.t_readouts_compress;
GO

--TRUNCATE TABLE t_readouts_raw_compress;
--GO

------------------------------------------------------------------------------------------------
--NOTE!!! Set the number packets per hour (how many times data are sent from sensors - per hour)
--        and the number of sensors 

DECLARE @numberOfPacketsPerHour TINYINT = $(varNumberOfPacketsPerHour)
DECLARE @numberOfTemperaturesInOneRow INT = 60/@numberOfPacketsPerHour;
DECLARE @numberOfSensors TINYINT = 9;
DECLARE @numberOfRows INT = 24 * @numberOfPacketsPerHour * 365 *@numberOfSensors;
DECLARE @currentRowNumber INT = 1;

SET IMPLICIT_TRANSACTIONS ON 
SET NOCOUNT ON
		
WHILE  @currentRowNumber <= @numberOfRows
BEGIN
    
	INSERT INTO t_readouts_source(
	    rea_sen_id,
	    --rea_sequence,
	    rea_temperatures
	    --,rea_rssi
		)
    SELECT 
		@currentRowNumber % 9,
	    --0 ,
   	    dbo.f_ans_generate(@numberOfTemperaturesInOneRow)
	    --,-90 

    SET @currentRowNumber += 1
END

COMMIT 

SET IMPLICIT_TRANSACTIONS OFF

SET IDENTITY_INSERT t_readouts_raw ON

-- Read t_readouts_source to RAM
--SELECT * FROM t_readouts_source
GO

DBCC FREEPROCCACHE;
GO

DECLARE @numberOfPacketsPerHour TINYINT = $(varNumberOfPacketsPerHour)
DECLARE @numberOfTemperaturesInOneRow INT = 60/@numberOfPacketsPerHour;
DECLARE @t1 DATETIME;
DECLARE @t2 DATETIME;
DECLARE @elapsedTime_ms INT = 0;

SET @t1 = GETDATE();

INSERT INTO t_readouts_raw(
    rea_id, 
	rea_sen_id,
	rea_audit_cd, 
	--rea_sequence,
    rea_temperatures
    --,rea_rssi
	)
    SELECT rea_id, 
	rea_sen_id, 
	rea_audit_cd, 
	--rea_sequence,
    rea_temperatures
	--, rea_rssi
	FROM t_readouts_source
SET @t2 = GETDATE();
SET @elapsedTime_ms += DATEDIFF(millisecond,@t1,@t2);

--Display metrics:
INSERT INTO dbo.metrics_insert 
SELECT 1, 'SensorRaw -> SQLServer',@numberOfTemperaturesInOneRow, 
qs.[sql_handle], [text], 
execution_count, last_execution_time, 
total_worker_time/1000 AS total_worker_time_ms,
total_worker_time/execution_count/1000 AS avg_worker_time_ms,
last_worker_time/1000 AS last_worker_time_ms, 
min_worker_time/1000 AS min_worker_time_ms, 
max_worker_time/1000 AS max_worker_time_ms, 
total_logical_reads,
total_logical_reads/execution_count AS avg_logical_reads,
total_logical_writes,
@elapsedTime_ms AS elapsed_time_ms
FROM sys.dm_exec_query_stats AS qs CROSS APPLY sys.dm_exec_sql_text(qs.[sql_handle]) AS qt
WHERE total_logical_writes > 0
GO


SET IDENTITY_INSERT t_readouts_raw OFF

SET IDENTITY_INSERT t_readouts_compress ON

DBCC FREEPROCCACHE;
GO
DECLARE @numberOfPacketsPerHour TINYINT = $(varNumberOfPacketsPerHour)
DECLARE @numberOfTemperaturesInOneRow INT = 60/@numberOfPacketsPerHour;
DECLARE @t1 DATETIME;
DECLARE @t2 DATETIME;
DECLARE @elapsedTime_ms INT = 0;


SET @t1 = GETDATE();
INSERT INTO t_readouts_compress(
    rea_id, 
	rea_sen_id,
	rea_audit_cd, 
	--rea_sequence,
    rea_temperatures 
    --,rea_rssi
	)
    SELECT rea_id, 
	rea_sen_id, 
	rea_audit_cd, 
	--rea_sequence,
    COMPRESS(rea_temperatures) 
    --,rea_rssi
	FROM t_readouts_source
SET @t2 = GETDATE();
SET @elapsedTime_ms += DATEDIFF(millisecond,@t1,@t2);

--Display metrics:
INSERT INTO dbo.metrics_insert 
SELECT 2, 'SensorRaw -> SQLServer -> COMPRESS',@numberOfTemperaturesInOneRow, 
qs.[sql_handle], [text], 
execution_count, last_execution_time, 
total_worker_time/1000 AS total_worker_time_ms,
total_worker_time/execution_count/1000 AS avg_worker_time_ms,
last_worker_time/1000 AS last_worker_time_ms, 
min_worker_time/1000 AS min_worker_time_ms, 
max_worker_time/1000 AS max_worker_time_ms, 
total_logical_reads,
total_logical_reads/execution_count AS avg_logical_reads,
total_logical_writes,
@elapsedTime_ms AS elapsed_time_ms
FROM sys.dm_exec_query_stats AS qs CROSS APPLY sys.dm_exec_sql_text(qs.[sql_handle]) AS qt
WHERE total_logical_writes > 0
GO


SET IDENTITY_INSERT t_readouts_compress OFF
/*
Sensors are currently unable to send data compressed by Huffman
SET IDENTITY_INSERT t_readouts_raw_compress ON

INSERT INTO t_readouts_raw_compress(
    rea_id, 
	rea_sen_id,
	rea_audit_cd, 
	--rea_sequence,
    rea_temperatures 
    --,rea_rssi
	)
    SELECT rea_id, 
	rea_sen_id, 
	rea_audit_cd, 
	--rea_sequence,
    rea_temperatures 
    --,rea_rssi
	FROM t_readouts_compress

SET IDENTITY_INSERT t_readouts_raw_compress OFF
*/

SET IDENTITY_INSERT t_readouts_ans_tsql ON

DBCC FREEPROCCACHE;
GO

DECLARE @numberOfPacketsPerHour TINYINT = $(varNumberOfPacketsPerHour)
DECLARE @numberOfTemperaturesInOneRow INT = 60/@numberOfPacketsPerHour;
DECLARE @t1 DATETIME;
DECLARE @t2 DATETIME;
DECLARE @elapsedTime_ms INT = 0;


SET @t1 = GETDATE();
INSERT INTO t_readouts_ans_tsql(
    rea_id,
	rea_sen_id,
	rea_audit_cd, 
	--rea_sequence,
    rea_temperatures 
    --,rea_rssi
	)
    SELECT rea_id, rea_sen_id, rea_audit_cd, 
	--rea_sequence,
    dbo.f_ans_encode(rea_temperatures,@numberOfTemperaturesInOneRow) 
    --,rea_rssi
    FROM t_readouts_source
SET @t2 = GETDATE();
SET @elapsedTime_ms += DATEDIFF(millisecond,@t1,@t2);

--Display metrics:
INSERT INTO dbo.metrics_insert 
SELECT 3, 'SensorRaw -> SQLServer -> ANS_TSQL',@numberOfTemperaturesInOneRow, 
qs.[sql_handle], [text], 
execution_count, last_execution_time, 
total_worker_time/1000 AS total_worker_time_ms,
total_worker_time/execution_count/1000 AS avg_worker_time_ms,
last_worker_time/1000 AS last_worker_time_ms, 
min_worker_time/1000 AS min_worker_time_ms, 
max_worker_time/1000 AS max_worker_time_ms, 
total_logical_reads,
total_logical_reads/execution_count AS avg_logical_reads,
total_logical_writes,
@elapsedTime_ms AS elapsed_time_ms
FROM sys.dm_exec_query_stats AS qs CROSS APPLY sys.dm_exec_sql_text(qs.[sql_handle]) AS qt
WHERE total_logical_writes > 0
GO


SET IDENTITY_INSERT t_readouts_ans_tsql OFF

SET IDENTITY_INSERT t_readouts_ans_cs ON

DBCC FREEPROCCACHE;
GO

DECLARE @numberOfPacketsPerHour TINYINT = $(varNumberOfPacketsPerHour)
DECLARE @numberOfTemperaturesInOneRow INT = 60/@numberOfPacketsPerHour;
DECLARE @t1 DATETIME;
DECLARE @t2 DATETIME;
DECLARE @elapsedTime_ms INT = 0;
SET @t1 = GETDATE();

INSERT INTO t_readouts_ans_cs(
    rea_id,
	rea_sen_id,
	rea_audit_cd, 
	--rea_sequence,
    rea_temperatures 
    --,rea_rssi
	)
    SELECT rea_id, rea_sen_id, rea_audit_cd, 
	--rea_sequence,
	dbo.ANSEncode(rea_temperatures) 
    --,rea_rssi
    FROM t_readouts_source
SET @t2 = GETDATE();
SET @elapsedTime_ms += DATEDIFF(millisecond,@t1,@t2);

--Display metrics:
INSERT INTO dbo.metrics_insert 
SELECT 4, 'SensorRaw -> SQLServer -> ANS_CS',@numberOfTemperaturesInOneRow, 
qs.[sql_handle], [text], 
execution_count, last_execution_time, 
total_worker_time/1000 AS total_worker_time_ms,
total_worker_time/execution_count/1000 AS avg_worker_time_ms,
last_worker_time/1000 AS last_worker_time_ms, 
min_worker_time/1000 AS min_worker_time_ms, 
max_worker_time/1000 AS max_worker_time_ms, 
total_logical_reads,
total_logical_reads/execution_count AS avg_logical_reads,
total_logical_writes,
@elapsedTime_ms AS elapsed_time_ms
FROM sys.dm_exec_query_stats AS qs CROSS APPLY sys.dm_exec_sql_text(qs.[sql_handle]) AS qt
WHERE total_logical_writes > 0
GO


SET IDENTITY_INSERT t_readouts_ans_cs OFF

SET IDENTITY_INSERT t_readouts_raw_ans ON

DBCC FREEPROCCACHE;
GO

DECLARE @numberOfPacketsPerHour TINYINT = $(varNumberOfPacketsPerHour)
DECLARE @numberOfTemperaturesInOneRow INT = 60/@numberOfPacketsPerHour;
DECLARE @t1 DATETIME;
DECLARE @t2 DATETIME;
DECLARE @elapsedTime_ms INT = 0;
SET @t1 = GETDATE();

INSERT INTO t_readouts_raw_ans(
    rea_id,
	rea_sen_id,
	rea_audit_cd, 
	--rea_sequence,
    rea_temperatures 
    --,rea_rssi
	)
    SELECT rea_id, rea_sen_id, rea_audit_cd, 
	--rea_sequence,
    rea_temperatures 
    --,rea_rssi
    FROM t_readouts_ans_tsql;
SET @t2 = GETDATE();
SET @elapsedTime_ms += DATEDIFF(millisecond,@t1,@t2);

--Display metrics:
INSERT INTO dbo.metrics_insert 
SELECT 5, 'SensorANS -> SQLServer',@numberOfTemperaturesInOneRow, 
qs.[sql_handle], [text], 
execution_count, last_execution_time, 
total_worker_time/1000 AS total_worker_time_ms,
total_worker_time/execution_count/1000 AS avg_worker_time_ms,
last_worker_time/1000 AS last_worker_time_ms, 
min_worker_time/1000 AS min_worker_time_ms, 
max_worker_time/1000 AS max_worker_time_ms, 
total_logical_reads,
total_logical_reads/execution_count AS avg_logical_reads,
total_logical_writes ,
@elapsedTime_ms AS elapsed_time_ms
FROM sys.dm_exec_query_stats AS qs CROSS APPLY sys.dm_exec_sql_text(qs.[sql_handle]) AS qt
WHERE total_logical_writes > 0
GO


SET IDENTITY_INSERT t_readouts_raw_ans OFF

SET IMPLICIT_TRANSACTIONS OFF
SET NOCOUNT OFF



/*
select type_no, [type], --text, 
last_execution_time, total_worker_time_ms, 
total_logical_reads, total_logical_writes, elapsed_time_ms
from metrics_insert;

delete from metrics_insert;



*/

/*
select top 5 *, DATALENGTH(rea_temperatures) from t_readouts_ans_cs
select top 5 *,DATALENGTH(rea_temperatures) from t_readouts_ans_tsql
select top 5 *, DATALENGTH(rea_temperatures) from t_readouts_raw_ans 

*/
