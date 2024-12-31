/******************************************************************************************
------------------------------------------------------------------
CREATE VIEWS AND FUNCTIONS TO ANALYZE METRICS
------------------------------------------------------------------
Create Date:        2021-09-07
Major changes:      2021-09-28
Author:             Henryk Telega
Description:        Create views to display and analyze metrics (insert and select)
******************************************************************************************/

USE [DataCloud2]
GO

IF OBJECT_ID('v_insert_detailed_metrics') IS NOT NULL
    DROP VIEW dbo.v_insert_detailed_metrics
GO
CREATE VIEW dbo.v_insert_detailed_metrics
AS
SELECT TOP 1000 -- This is only in order to use ORDER BY clause
    [type]
	,60/number_of_temperatures_per_record AS number_of_transmissions_per_hour
    ,number_of_temperatures_per_record 
    ,elapsed_time_ms
    ,avg_worker_time_ms AS worker_time_ms 
    ,total_logical_writes AS logical_writes,
    last_execution_time
FROM dbo.metrics_insert AS mi
WHERE   avg_worker_time_ms > 20
        AND last_execution_time > (SELECT MIN(last_execution_time) FROM dbo.metrics_insert AS mi2
                             WHERE mi.type_no = mi2.type_no 
							 AND mi.number_of_temperatures_per_record=mi2.number_of_temperatures_per_record)
ORDER BY [type], number_of_transmissions_per_hour, last_execution_time
GO

IF OBJECT_ID('v_insert_detailed_metrics_amp') IS NOT NULL
    DROP VIEW dbo.v_insert_detailed_metrics_amp
GO
CREATE VIEW dbo.v_insert_detailed_metrics_amp
AS
SELECT TOP 1000 -- This is only in order to use ORDER BY clause
    [type] , '&' as a1
	,number_of_transmissions_per_hour, '&' as a3
	,number_of_temperatures_per_record, '&' as a2
	,elapsed_time_ms, '&' as a4
	,worker_time_ms, '&' as a5
	,logical_writes, '&' as a6
FROM dbo.v_insert_detailed_metrics
ORDER BY [type], number_of_transmissions_per_hour, last_execution_time
GO

IF OBJECT_ID('v_insert_summary_metrics') IS NOT NULL
    DROP VIEW dbo.v_insert_summary_metrics
GO

CREATE VIEW dbo.v_insert_summary_metrics
AS
SELECT TOP 1000 -- This is only in order to use ORDER BY clause
	[type]
	, number_of_transmissions_per_hour
	, number_of_temperatures_per_record
	, COUNT(1) number_of_insert_tests
	, AVG(elapsed_time_ms) AS avg_elapsed_time_ms
	, MIN(elapsed_time_ms) AS min_elapsed_time_ms
	, MAX(elapsed_time_ms) AS max_elapsed_time_ms
	, AVG(worker_time_ms) AS avg_worker_time_ms
	, MIN(worker_time_ms) AS min_worker_time_ms
	, MAX(worker_time_ms) AS max_worker_time_ms
	, AVG(logical_writes) AS avg_logical_writes
FROM dbo.v_insert_detailed_metrics
GROUP BY [type], number_of_transmissions_per_hour, number_of_temperatures_per_record
ORDER BY [type], number_of_transmissions_per_hour
GO

IF OBJECT_ID('v_insert_summary_metrics_amp') IS NOT NULL
    DROP VIEW dbo.v_insert_summary_metrics_amp
GO

CREATE VIEW dbo.v_insert_summary_metrics_amp
AS
SELECT TOP 1000 -- This is only in order to use ORDER BY clause
	[type], '&' as a1
	, number_of_transmissions_per_hour, '&' as a2
	, number_of_temperatures_per_record, '&' as a3
	, COUNT(1) number_of_insert_tests, '&' as a4
	, AVG(elapsed_time_ms) AS avg_elapsed_time_ms, '&' as a5
	, MIN(elapsed_time_ms) AS min_elapsed_time_ms, '&' as a6
	, MAX(elapsed_time_ms) AS max_elapsed_time_ms, '&' as a7
	, AVG(worker_time_ms) AS avg_worker_time_ms, '&' as a8
	, MIN(worker_time_ms) AS min_worker_time_ms, '&' as a9
	, MAX(worker_time_ms) AS max_worker_time_ms, '&' as a10
	, AVG(logical_writes) AS avg_logical_writes, '&' as a11
FROM dbo.v_insert_detailed_metrics
GROUP BY [type], number_of_transmissions_per_hour, number_of_temperatures_per_record
ORDER BY [type], number_of_transmissions_per_hour
GO

IF OBJECT_ID('f_insert_detailed_metrics') IS NOT NULL
    DROP FUNCTION dbo.f_insert_detailed_metrics
GO
CREATE FUNCTION dbo.f_insert_detailed_metrics(@number_of_transmissions_per_hour TINYINT)
RETURNS TABLE
    RETURN (SELECT * FROM v_insert_detailed_metrics 
	        WHERE number_of_transmissions_per_hour = @number_of_transmissions_per_hour)
GO

IF OBJECT_ID('f_insert_detailed_metrics_amp') IS NOT NULL
    DROP FUNCTION dbo.f_insert_detailed_metrics_amp
GO
CREATE FUNCTION dbo.f_insert_detailed_metrics_amp(@number_of_transmissions_per_hour TINYINT)
RETURNS TABLE
    RETURN (SELECT * FROM v_insert_detailed_metrics_amp 
	        WHERE number_of_transmissions_per_hour = @number_of_transmissions_per_hour)
GO

IF OBJECT_ID('f_insert_summary_metrics') IS NOT NULL
    DROP FUNCTION dbo.f_insert_summary_metrics
GO
CREATE FUNCTION dbo.f_insert_summary_metrics(@number_of_transmissions_per_hour TINYINT)
RETURNS TABLE
    RETURN (SELECT * FROM v_insert_summary_metrics 
	        WHERE number_of_transmissions_per_hour = @number_of_transmissions_per_hour)
GO

IF OBJECT_ID('f_insert_summary_metrics_amp') IS NOT NULL
    DROP FUNCTION dbo.f_insert_summary_metrics_amp
GO
CREATE FUNCTION dbo.f_insert_summary_metrics_amp(@number_of_transmissions_per_hour TINYINT)
RETURNS TABLE
    RETURN (SELECT * FROM dbo.v_insert_summary_metrics_amp 
	        WHERE number_of_transmissions_per_hour = @number_of_transmissions_per_hour)
GO
--SELECT * FROM dbo.v_insert_detailed_metrics
--SELECT * FROM dbo.v_insert_detailed_metrics_amp
--SELECT * FROM dbo.v_insert_summary_metrics

--SELECT * FROM dbo.f_insert_detailed_metrics(1) 
--SELECT * FROM dbo.f_insert_detailed_metrics_amp(1) 

--SELECT * FROM dbo.f_insert_summary_metrics(1) 
--SELECT * FROM dbo.f_insert_summary_metrics_amp(1) 

IF OBJECT_ID('dbo.v_select_detailed_metrics') IS NOT NULL
	DROP VIEW dbo.v_select_detailed_metrics
GO

CREATE VIEW [dbo].[v_select_detailed_metrics]
AS
SELECT TOP 1000 -- This is only in order to use ORDER BY clause
type_no, 
[type], 
60/number_of_temperatures_per_record AS number_of_transmissions_per_hour, 
number_of_temperatures_per_record,
COUNT(1) AS number_of_tests,
AVG(number_of_records_read) as number_of_records_per_one_select,
AVG(avg_elapsed_time_ms) AS avg_elapsed_time_ms,
MIN(avg_elapsed_time_ms) AS min_elapsed_time_ms,
MAX(avg_elapsed_time_ms) AS max_elapsed_time_ms,
AVG(avg_worker_time_ms) AS avg_worker_time_ms,
MIN(min_worker_time_ms) AS min_worker_time_ms,
MAX(max_worker_time_ms) AS max_worker_time_ms,
AVG(total_logical_reads)/10 AS logical_reads_per_one_select,
MAX(last_execution_time) AS last_execution_time
FROM metrics_select
GROUP BY type_no, [type], number_of_temperatures_per_record, 
60/number_of_temperatures_per_record 
ORDER BY [type_no], number_of_temperatures_per_record, 
60/number_of_temperatures_per_record 
GO

IF OBJECT_ID('dbo.f_select_detailed_metrics') IS NOT NULL
	DROP FUNCTION dbo.f_select_detailed_metrics
GO

CREATE FUNCTION [dbo].[f_select_detailed_metrics]
(@number_of_transmissions_per_hour TINYINT)
RETURNS TABLE
AS
RETURN (SELECT TOP 1000 -- This is only in order to use ORDER BY clause
type_no, 
[type], 
60/number_of_temperatures_per_record AS number_of_transmissions_per_hour, 
number_of_temperatures_per_record,
COUNT(1) AS number_of_tests,
AVG(number_of_records_read) as number_of_records_per_one_select,
AVG(avg_elapsed_time_ms) AS avg_elapsed_time_ms,
MIN(avg_elapsed_time_ms) AS min_elapsed_time_ms,
MAX(avg_elapsed_time_ms) AS max_elapsed_time_ms,
AVG(avg_worker_time_ms) AS avg_worker_time_ms,
MIN(min_worker_time_ms) AS min_worker_time_ms,
MAX(max_worker_time_ms) AS max_worker_time_ms,
AVG(total_logical_reads)/10 AS logical_reads_per_one_select,
MAX(last_execution_time) AS last_execution_time
FROM metrics_select
WHERE number_of_temperatures_per_record = 60/@number_of_transmissions_per_hour
GROUP BY type_no, [type], number_of_temperatures_per_record, 
60/number_of_temperatures_per_record 
ORDER BY [type_no], number_of_temperatures_per_record, 
60/number_of_temperatures_per_record
)
GO

/*

SELECT * FROM f_select_detailed_metrics(1)

IF OBJECT_ID('dbo.v_select_summary_metrics') IS NOT NULL
	DROP VIEW dbo.v_select_summary_metrics
GO
CREATE VIEW dbo.v_select_summary_metrics
AS
SELECT TOP 1000 -- This is only in order to use ORDER BY clause
type_no, 
[type], 
60/number_of_temperatures_per_record AS number_of_transmissions_per_hour, 
number_of_temperatures_per_record,
COUNT(1) AS number_of_tests,
AVG(number_of_records_per_one_select) as number_of_records_per_one_select,
AVG(avg_elapsed_time_ms) AS avg_avg_elapsed_time_ms,
MIN(avg_elapsed_time_ms) AS avg_min_elapsed_time_ms,
MAX(avg_elapsed_time_ms) AS avg_max_elapsed_time_ms,
AVG(avg_worker_time_ms) AS avg_worker_time_ms,
MIN(min_worker_time_ms) AS avg_min_worker_time_ms,
MAX(max_worker_time_ms) AS avg_max_worker_time_ms,
AVG(logical_reads_per_one_select) AS logical_reads_per_one_select,
MAX(last_execution_time) AS last_execution_time
FROM v_select_detailed_metrics
GROUP BY type_no, [type], number_of_temperatures_per_record, 
60/number_of_temperatures_per_record 
ORDER BY [type], number_of_temperatures_per_record, 
60/number_of_temperatures_per_record 
GO

select * from v_select_detailed_metrics
select * from v_select_summary_metrics

select * from metrics_select

*/