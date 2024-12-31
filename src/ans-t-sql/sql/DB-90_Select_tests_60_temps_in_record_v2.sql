/******************************************************************************************
------------------------------------------------------------------
SELECT TESTS
Version 2
------------------------------------------------------------------
Create Date:        2021-09-24
Author:             Henryk Telega
Description:        Tests
******************************************************************************************/

USE DataCloud2
GO
/**************************************************************************************
---------------------------------------------------------------------------------------
-- SELECT TEST 
---------------------------------------------------------------------------------------
**************************************************************************************/
--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET STATISTICS IO, TIME OFF
SET NOCOUNT ON

--DELETE FROM dbo.metrics_select;

/*
	t_readouts_raw: version with uncompressed data
*/
--Clear query plan cache:
DBCC FREEPROCCACHE;
GO

DECLARE @numberOfExecutions INT = 10;
DECLARE @currentRecord INT = 1;

DECLARE @t1 DATETIME;
DECLARE @t2 DATETIME;
DECLARE @elapsedTime_ms INT = 0;

SET @t1 = GETDATE();
WHILE @currentRecord <= @numberOfExecutions
BEGIN
	SELECT  
	rea_id,
	rea_sen_no,
	rea_audit_cd, 
	--rea_sequence,
	rea_temperatures
	,rea_rssi
	--,rea_voltage,
	FROM dbo.t_readouts_raw OPTION (MAXDOP 1);
	SET @currentRecord += 1;
END
SET @t2 = GETDATE();
SET @elapsedTime_ms += DATEDIFF(millisecond,@t1,@t2);
--Display metrics:
INSERT INTO dbo.metrics_select 
SELECT 1, 'Not compressed',60, (SELECT COUNT(1) FROM dbo.t_readouts_raw), 
qs.[sql_handle], [text], 
execution_count, last_execution_time, 
total_worker_time/1000 AS total_worker_time_ms,
total_worker_time/execution_count/1000 AS avg_worker_time_ms,
last_worker_time/1000 AS last_worker_time_ms, 
min_worker_time/1000 AS min_worker_time_ms, 
max_worker_time/1000 AS max_worker_time_ms, 
total_logical_reads,
total_logical_reads/execution_count AS avg_logical_reads,
@elapsedTime_ms/@numberOfExecutions AS avg_elapsed_time_ms
FROM sys.dm_exec_query_stats AS qs CROSS APPLY sys.dm_exec_sql_text(qs.[sql_handle]) AS qt
WHERE execution_count > 3
GO

/*
	t_readouts_raw_compress 
*/
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET STATISTICS IO, TIME OFF
SET NOCOUNT ON

DBCC FREEPROCCACHE;
GO

DECLARE @numberOfExecutions INT = 10;
DECLARE @currentRecord INT = 1;

DECLARE @t1 DATETIME;
DECLARE @t2 DATETIME;
DECLARE @elapsedTime_ms INT = 0;
SET @t1 = GETDATE();
WHILE @currentRecord <= @numberOfExecutions
BEGIN
	SELECT 
	rea_id,
	rea_sen_no,
	rea_audit_cd, 
	--rea_sequence,
	DECOMPRESS(rea_temperatures) AS rea_temperatures
	,rea_rssi
	--,rea_voltage  
	FROM t_readouts_compress OPTION (MAXDOP 1);
	SET @currentRecord += 1;
END
SET @t2 = GETDATE();
SET @elapsedTime_ms += DATEDIFF(millisecond,@t1,@t2);

--Display metrics:
INSERT INTO dbo.metrics_select 
SELECT 2,'DECOMPRESS',60, (SELECT COUNT(1) FROM dbo.t_readouts_compress),
qs.[sql_handle], [text], 
execution_count, last_execution_time, 
total_worker_time/1000 AS total_worker_time_ms,
total_worker_time/execution_count/1000 AS avg_worker_time_ms,
last_worker_time/1000 AS last_worker_time_ms, 
min_worker_time/1000 AS min_worker_time_ms, 
max_worker_time/1000 AS max_worker_time_ms, 
total_logical_reads,
total_logical_reads/execution_count AS avg_logical_reads,
@elapsedTime_ms/@numberOfExecutions AS avg_elapsed_time_ms
FROM sys.dm_exec_query_stats AS qs CROSS APPLY sys.dm_exec_sql_text(qs.[sql_handle]) AS qt
WHERE execution_count > 3
GO

/*
	t_readouts_raw_ans 
*/

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET STATISTICS IO, TIME OFF
SET NOCOUNT ON

--Clear query plan cache:
DBCC FREEPROCCACHE
GO

DECLARE @numberOfExecutions INT = 10;
DECLARE @currentRecord INT = 1;

DECLARE @t1 DATETIME;
DECLARE @t2 DATETIME;
DECLARE @elapsedTime_ms INT = 0;
SET @t1 = GETDATE();
WHILE @currentRecord <= @numberOfExecutions
BEGIN
	SELECT  
	rea_id,
	rea_sen_no,
	rea_audit_cd, 
	--rea_sequence,
	dbo.f_ans_decode(rea_temperatures,60) AS rea_temperatures
	,rea_rssi
	--,rea_voltage
	FROM t_readouts_raw_ans OPTION (MAXDOP 1);
	SET @currentRecord += 1;
END
SET @t2 = GETDATE();
SET @elapsedTime_ms += DATEDIFF(millisecond,@t1,@t2);

--Display metrics:
INSERT INTO dbo.metrics_select 
SELECT 3, 'ANS_TSQL',60, (SELECT COUNT(1) FROM dbo.t_readouts_raw_ans),
qs.[sql_handle], [text], 
execution_count, last_execution_time, 
total_worker_time/1000 AS total_worker_time_ms,
total_worker_time/execution_count/1000 AS avg_worker_time_ms,
last_worker_time/1000 AS last_worker_time_ms, 
min_worker_time/1000 AS min_worker_time_ms, 
max_worker_time/1000 AS max_worker_time_ms, 
total_logical_reads,
total_logical_reads/execution_count AS avg_logical_reads,
@elapsedTime_ms/@numberOfExecutions AS avg_elapsed_time_ms
FROM sys.dm_exec_query_stats AS qs CROSS APPLY sys.dm_exec_sql_text(qs.[sql_handle]) AS qt
WHERE execution_count > 3
GO

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET STATISTICS IO, TIME OFF
SET NOCOUNT ON

--Clear query plan cache:
DBCC FREEPROCCACHE
GO

DECLARE @numberOfExecutions INT = 10;
DECLARE @currentRecord INT = 1;

DECLARE @t1 DATETIME;
DECLARE @t2 DATETIME;
DECLARE @elapsedTime_ms INT = 0;
SET @t1 = GETDATE();
WHILE @currentRecord <= @numberOfExecutions
BEGIN
	SELECT 
	rea_id,
	rea_sen_no,
	rea_audit_cd, 
	--rea_sequence,
	dbo.ANSDecode(rea_temperatures) AS rea_temperatures
	,rea_rssi
	--,rea_voltage
	FROM t_readouts_raw_ans OPTION (MAXDOP 1);
	SET @currentRecord += 1;
END
SET @t2 = GETDATE();
SET @elapsedTime_ms += DATEDIFF(millisecond,@t1,@t2);

--Display metrics:
INSERT INTO dbo.metrics_select 
SELECT 4, 'ANS_C#',60, (SELECT COUNT(1) FROM dbo.t_readouts_raw_ans),
qs.[sql_handle], [text], 
execution_count, last_execution_time, 
total_worker_time/1000 AS total_worker_time_ms,
total_worker_time/execution_count/1000 AS avg_worker_time_ms,
last_worker_time/1000 AS last_worker_time_ms, 
min_worker_time/1000 AS min_worker_time_ms, 
max_worker_time/1000 AS max_worker_time_ms, 
total_logical_reads,
total_logical_reads/execution_count AS avg_logical_reads,
@elapsedTime_ms/@numberOfExecutions AS avg_elapsed_time_ms
FROM sys.dm_exec_query_stats AS qs CROSS APPLY sys.dm_exec_sql_text(qs.[sql_handle]) AS qt
WHERE execution_count > 3
GO

/*
SELECT * FROM metrics_select
ORDER BY type_no, last_execution_time

SELECT type, last_execution_time, 
number_of_temperatures_per_record,
number_of_records_read,
avg_worker_time_ms , avg_elapsed_time_ms,
avg_logical_reads as logical_reads,
min_worker_time_ms, max_worker_time_ms
FROM metrics_select
ORDER BY type_no, last_execution_time

SELECT type, last_execution_time, 
number_of_temperatures_per_record,
number_of_records_read,
avg_worker_time_ms , avg_elapsed_time_ms,
avg_logical_reads as logical_reads,
min_worker_time_ms, max_worker_time_ms
FROM metrics_old
ORDER BY type_no, last_execution_time

*/

--delete from dbo.metrics_select

select * from dbo.v_metrics_select

/*
SELECT TOP 1 *, dbo.ANSDecode(rea_temperatures) AS rea_temperatures 
FROM t_readouts_ans
SELECT ta.*, t.rea_temperatures AS rea_temperatures,
dbo.f_ans_decode(ta.rea_temperatures,60) as decodedTSQL, 
dbo.ANSDecode(ta.rea_temperatures) as decodedCS 
FROM t_readouts_ans ta JOIN t_readouts t on ta.rea_id = t.rea_id
where t.rea_id = 1

SELECT *
FROM t_readouts  
where rea_id = 2
SELECT *
FROM t_readouts_ans  
where rea_id = 2
SELECT ta.*, 
dbo.f_ans_decode(ta.rea_temperatures,60) as decodedTSQL
FROM t_readouts_ans ta 
where ta.rea_id = 2
SELECT ta.*, 
dbo.ANSDecode(ta.rea_temperatures) as decodedCS 
FROM t_readouts_ans ta 
where ta.rea_id = 2

*/


/*
Other, earlier tests (August 2021)
---------------------------------------------------------------------------------------
-- Compare t_readouts_compressed vs t_readouts_ans

dbcc freeproccache
go
set nocount off
set statistics io, time on 

select top 100000 *, dbo.f_ans_unpack(DECOMPRESS(rea_temperatures))
from t_readouts_compressed
go 5

select top 100000 *, dbo.f_ans_unpack(rea_temperatures)
from t_readouts
go 5

set statistics io, time off

select qs.sql_handle, text, 
execution_count, last_execution_time, 
total_worker_time/1000 as total_worker_time_ms,
total_worker_time/execution_count/1000 as avg_worker_time_ms,
last_worker_time/1000 as last_worker_time_ms, 
min_worker_time/1000 as min_worker_time_ms, 
max_worker_time/1000 as max_worker_time_ms, 
total_logical_reads
from sys.dm_exec_query_stats as qs cross apply sys.dm_exec_sql_text(qs.sql_handle) as qt
where execution_count > 3
go

set statistics io, time off
---------------------------------------------------------------------------------------
-- IN MEMORY TABLE

select d.compatibility_level
from sys.databases AS d
where d.name = Db_Name();

alter database current
set compatibility_level = 130;

use master
go
alter database DataCloud 
add filegroup InMemoryDataCloud CONTAINS MEMORY_OPTIMIZED_DATA

alter database DataCloud 
add file (name='InMemoryDataCloud', filename='c:\tmp\InMemoryDataCloud') 
to filegroup InMemoryDataCloud

use DataCloud
go

create table dbo.t_readouts_inmemory
(
    [rea_id] [int] NOT NULL primary key nonclustered,
	[rea_audit_cd] [datetime] NULL,
	[rea_sequence] [tinyint] NULL,
	[rea_temperatures] [varchar](100) NULL,
	[rea_rssi] [smallint] NULL,
	[rea_voltage] [real] NULL,
)
    with
    (memory_optimized = on, durability = SCHEMA_AND_DATA);

insert into t_readouts_inmemory
select * from t_readouts_ans

-- !!! The express edition is limited to 325 MB per in-memory table !!!

---------------------------------------------------------------------------------------
--COLUMSTORE index version 1
set nocount on
if OBJECT_ID('t_readouts_columnstore1') IS NOT NULL
	drop table t_readouts_columnstore1
go

select * into t_readouts_columnstore1
FROM t_readouts

create nonclustered columnstore index cl_columstore on t_readouts_columnstore1(
rea_temperatures);

create unique nonclustered index cl on t_readouts_columnstore1(rea_id);


dbcc freeproccache
go

set statistics io, time on

select top 100000 * from t_readouts_columnstore1
go 10


select top 10000 rea_id, rea_audit_cd, rea_sequence, dbo.f_ans_unpack(rea_temperatures),
rea_rssi, rea_voltage
from t_readouts_columnstore1
go 10


select top 100000 *, dbo.f_ans_unpack(rea_temperatures)
from t_readouts_columnstore1
go 10

set statistics io, time off

select qs.sql_handle, text, 
execution_count, last_execution_time, 
total_worker_time/1000 as total_worker_time_ms,
total_worker_time/execution_count/1000 as avg_worker_time_ms,
last_worker_time/1000 as last_worker_time_ms, 
min_worker_time/1000 as min_worker_time_ms, 
max_worker_time/1000 as max_worker_time_ms, 
total_logical_reads
from sys.dm_exec_query_stats as qs cross apply sys.dm_exec_sql_text(qs.sql_handle) as qt
where execution_count > 3
go

------------------
--COLUMSTORE index version 2
set nocount on


drop table t_readouts_columnstore2
go

select * into t_readouts_columnstore2
from t_readouts_ans

create clustered columnstore index cl_columstore on t_readouts_columnstore2

create unique nonclustered index cl on t_readouts_columnstore2(rea_id);

dbcc freeproccache
go
select * from t_readouts_columnstore2
where rea_id = 1555555
go 200

select rea_id, rea_audit_cd, rea_sequence, dbo.f_ans_unpack(rea_temperatures),
rea_rssi, rea_voltage
from t_readouts_columnstore2
where rea_id = 1555555
go 200


select *, dbo.f_ans_unpack(rea_temperatures)
from t_readouts_columnstore2
where rea_id = 1555555
GO 200

select qs.sql_handle, text, 
execution_count, last_execution_time, 
total_worker_time/1000 as total_worker_time_ms,
total_worker_time/execution_count/1000 as avg_worker_time_ms,
last_worker_time/1000 as last_worker_time_ms, 
min_worker_time/1000 as min_worker_time_ms, 
max_worker_time/1000 as max_worker_time_ms, 
total_logical_reads
from sys.dm_exec_query_stats as qs cross apply sys.dm_exec_sql_text(qs.sql_handle) as qt
where execution_count > 3
go
*/
