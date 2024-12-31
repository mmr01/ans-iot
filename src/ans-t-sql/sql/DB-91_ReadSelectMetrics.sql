/******************************************************************************************
------------------------------------------------------------------
Read select metrics
------------------------------------------------------------------
Create Date:        2021-09-23
Author:             Henryk Telega
Description:        Read select metrics
******************************************************************************************/

USE DataCloud
GO

/*
--delete from dbo.metrics_select
*/

SELECT * FROM dbo.v_select_detailed_metrics

SELECT * FROM dbo.f_select_detailed_metrics(1)
SELECT * FROM dbo.f_select_detailed_metrics(2)
SELECT * FROM dbo.f_select_detailed_metrics(3)
SELECT * FROM dbo.f_select_detailed_metrics(4)
SELECT * FROM dbo.f_select_detailed_metrics(5)
SELECT * FROM dbo.f_select_detailed_metrics(6)

SET STATISTICS IO, TIME ON
SELECT * FROM t_readouts_compress
SET STATISTICS IO, TIME OFF


SELECT [type],number_of_transmissions_per_hour, number_of_temperatures_per_record,
number_of_records_per_one_select, number_of_tests,
avg_elapsed_time_ms, avg_worker_time_ms, logical_reads_per_one_select/10 AS logical_reads_per_one_select
FROM dbo.f_select_detailed_metrics(1)
ORDER BY type_no

SELECT [type],number_of_transmissions_per_hour, number_of_temperatures_per_record,
number_of_records_per_one_select, number_of_tests,
avg_elapsed_time_ms, avg_worker_time_ms, logical_reads_per_one_select/10 AS logical_reads_per_one_select
FROM dbo.f_select_detailed_metrics(2)
ORDER BY type_no

SELECT [type],number_of_transmissions_per_hour, number_of_temperatures_per_record,
number_of_records_per_one_select, number_of_tests,
avg_elapsed_time_ms, avg_worker_time_ms, logical_reads_per_one_select/10 AS logical_reads_per_one_select
FROM dbo.f_select_detailed_metrics(3)
ORDER BY type_no

SELECT [type],number_of_transmissions_per_hour, number_of_temperatures_per_record,
number_of_records_per_one_select, number_of_tests,
avg_elapsed_time_ms, avg_worker_time_ms, logical_reads_per_one_select/10 AS logical_reads_per_one_select
FROM dbo.f_select_detailed_metrics(4)
ORDER BY type_no

SELECT [type],number_of_transmissions_per_hour, number_of_temperatures_per_record,
number_of_records_per_one_select, number_of_tests,
avg_elapsed_time_ms, avg_worker_time_ms, logical_reads_per_one_select/10 AS logical_reads_per_one_select
FROM dbo.f_select_detailed_metrics(5)
ORDER BY type_no

SELECT [type],number_of_transmissions_per_hour, number_of_temperatures_per_record,
number_of_records_per_one_select, number_of_tests,
avg_elapsed_time_ms, avg_worker_time_ms, logical_reads_per_one_select/10 AS logical_reads_per_one_select
FROM dbo.f_select_detailed_metrics(6)
ORDER BY type_no
