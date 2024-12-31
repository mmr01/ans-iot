/******************************************************************************************
------------------------------------------------------------------
CREATE TABLE metrics_insert and metric_select
------------------------------------------------------------------
Create Date:        2021-09-24
Author:             Henryk Telega
Description:        Create tables for metrics 
******************************************************************************************/

USE [DataCloud2]
GO

IF OBJECT_ID('dbo.metrics_insert') IS NOT NULL
	DROP TABLE dbo.metrics_insert

CREATE TABLE [dbo].[metrics_insert](
    [type_no] [int] NOT NULL,
	[type] [varchar](50) NOT NULL,
	[number_of_temperatures_per_record] INT NOT NULL,
	[sql_handle] [varbinary](64) NOT NULL,
	[text] [nvarchar](max) NULL,
	[execution_count] [bigint] NOT NULL,
	[last_execution_time] [datetime] NOT NULL,
	[total_worker_time_ms] [bigint] NULL,
	[avg_worker_time_ms] [bigint] NULL,
	[last_worker_time_ms] [bigint] NULL,
	[min_worker_time_ms] [bigint] NULL,
	[max_worker_time_ms] [bigint] NULL,
	[total_logical_reads] [bigint] NOT NULL,
	[avg_logical_reads] [bigint] NULL,
	[total_logical_writes] [bigint] NULL,
	[elapsed_time_ms] [bigint] NULL,
) ON [PRIMARY] 
GO

ALTER TABLE dbo.metrics_insert
ADD PRIMARY KEY([type_no], last_execution_time)


IF OBJECT_ID('dbo.metrics_select') IS NOT NULL
	DROP TABLE dbo.metrics_select

CREATE TABLE [dbo].[metrics_select](
    [type_no] [int] NOT NULL,
	[type] [varchar](15) NOT NULL,
	[number_of_temperatures_per_record] INT NOT NULL,
	[number_of_records_read] INT NOT NULL,
	[sql_handle] [varbinary](64) NOT NULL,
	[text] [nvarchar](max) NULL,
	[execution_count] [bigint] NOT NULL,
	[last_execution_time] [datetime] NOT NULL,
	[total_worker_time_ms] [bigint] NULL,
	[avg_worker_time_ms] [bigint] NULL,
	[last_worker_time_ms] [bigint] NULL,
	[min_worker_time_ms] [bigint] NULL,
	[max_worker_time_ms] [bigint] NULL,
	[total_logical_reads] [bigint] NOT NULL,
	[avg_logical_reads] [bigint] NULL,
	[avg_elapsed_time_ms] [bigint] NULL,
) ON [PRIMARY] 
GO

ALTER TABLE dbo.metrics_select
ADD PRIMARY KEY([type_no], last_execution_time)
GO
