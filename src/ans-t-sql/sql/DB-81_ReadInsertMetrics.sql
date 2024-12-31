/******************************************************************************************
------------------------------------------------------------------
RANDOM DATA GENERATION 
------------------------------------------------------------------
Create Date:        2021-09-23
Author:             Henryk Telega
Description:        Read insert metrics
******************************************************************************************/

USE DataCloud
GO

SELECT * FROM dbo.v_insert_detailed_metrics

SELECT * FROM dbo.v_insert_detailed_metrics_amp

SELECT * FROM dbo.v_insert_summary_metrics

SELECT * FROM dbo.v_insert_summary_metrics_amp

SELECT * FROM dbo.f_insert_detailed_metrics(1)
SELECT * FROM dbo.f_insert_detailed_metrics(2)
SELECT * FROM dbo.f_insert_detailed_metrics(3)
SELECT * FROM dbo.f_insert_detailed_metrics(4)
SELECT * FROM dbo.f_insert_detailed_metrics(5)
SELECT * FROM dbo.f_insert_detailed_metrics(6)

SELECT * FROM dbo.f_insert_detailed_metrics_amp(1)

SELECT * FROM dbo.f_insert_summary_metrics(1)
SELECT * FROM dbo.f_insert_summary_metrics(2)
SELECT * FROM dbo.f_insert_summary_metrics(3)
SELECT * FROM dbo.f_insert_summary_metrics(4)
SELECT * FROM dbo.f_insert_summary_metrics(5)
SELECT * FROM dbo.f_insert_summary_metrics(6)

SELECT * FROM dbo.f_insert_summary_metrics_amp(1)
SELECT * FROM dbo.f_insert_summary_metrics_amp(2)
SELECT * FROM dbo.f_insert_summary_metrics_amp(3)
SELECT * FROM dbo.f_insert_summary_metrics_amp(4)
SELECT * FROM dbo.f_insert_summary_metrics_amp(5)
SELECT * FROM dbo.f_insert_summary_metrics_amp(6)

/*
SELECT *
FROM metrics_insert;
*/
--delete from metrics_insert;


/*
select top 5 *, DATALENGTH(rea_temperatures) from t_readouts_ans_cs
select top 5 *,DATALENGTH(rea_temperatures) from t_readouts_ans_tsql
select top 5 *, DATALENGTH(rea_temperatures) from t_readouts_raw_ans 

*/
