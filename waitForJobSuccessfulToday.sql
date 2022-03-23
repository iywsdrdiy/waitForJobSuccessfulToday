USE [Monitor]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  procedure [jobs].[waitForJobSuccessfulToday] 
(@job_name nvarchar(128))
as
/*
Return advice on whether the calling task should proceed or wait, if it is dependent on
this job completing successfully today.

The advice consists of one of the flags 'Proceed', 'Wait' and 'Error'.
*/
set nocount on;


while jobs.getProceedIfJobSuccessfulToday(@job_name) != 'Proceed' waitfor delay '00:01:00'
;

--exec jobs.[waitForJobSuccessfulToday] 'Important_Job';
--it might might be worth writing a more complicated procedure instead of using the job step retry
-- e.g. https://www.mssqltips.com/sqlservertip/2167/custom-spstartjob-to-delay-next-task-until-sql-agent-job-has-completed/

GO
