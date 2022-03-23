USE [Monitor]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [jobs].[getJobExecutionStatusToday] (@job_name nvarchar(128))
returns int
as
/*
Return the job execution status for a single job since midnight this morning
The result is for the latest execution of the job, using the values for run_status
from https://docs.microsoft.com/en-us/sql/relational-databases/system-tables/dbo-sysjobhistory-transact-sql?view=sql-server-ver15 :

	run_status	int	Status of the job execution:
	0 = Failed
	1 = Succeeded
	2 = Retry
	3 = Canceled
	4 = In Progress

There are two extra cases we have to handle:

	-1 = No Started
	-2 = Not Found

All credit for initial understanding to https://social.technet.microsoft.com/Forums/en-US/5b8da7ff-1a6a-4fb0-9279-aa8c44bc3328/how-do-i-see-when-package-last-ran-in-ssis?forum=sqlintegrationservices

	SELECT TOP 1 j.name as JobName, jh.message, jh.run_status,
	LastRunDateTime = CONVERT(DATETIME, CONVERT(CHAR(8), run_date, 112) + ' '  + STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), run_time), 6), 5, 0, ':'), 3, 0, ':'), 121)
	FROM msdb..sysjobs j INNER JOIN msdb..sysjobhistory jh ON j.job_id = jh.job_id 
	WHERE CONVERT(DATETIME, CONVERT(CHAR(8), run_date, 112) + ' ' + STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), run_time), 6), 5, 0, ':'), 3, 0, ':'), 121) > DATEADD(d,0,DATEDIFF(d,0,GETDATE())) 
	AND jh.step_id = 0 AND j.name = '<JOB-NAME>'
	ORDER BY LastRunDateTime desc
*/
begin
	--1. Test a job by that name exists
	declare @job_exists char(5);
	select @job_exists =  isnull((select cast('True' as char(5)) from msdb..sysjobs where name = @job_name),'False');
	--print @job_exists;

	--2. Test if there is /any/ run history today:
	declare @job_started_today char(5);
	select @job_started_today = iif(1 <= (
		SELECT count (jh.run_status)
		FROM msdb..sysjobs j inner JOIN msdb..sysjobhistory jh ON j.job_id = jh.job_id
		where CONVERT(DATETIME, CONVERT(CHAR(8), run_date, 112) + ' ' + STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), run_time), 6), 5, 0, ':'), 3, 0, ':'), 121) > DATEADD(d,0,DATEDIFF(d,0,GETDATE())) 
		and jh.step_id = 0
		and 
		--j.name = 'BB WEEKLY_BB_DATA_PW'
		j.name = @job_name
	),'True','False')
	;
	--print @job_started_today;

	--3. get the latest status for today
	declare @latest_status int;
	set @latest_status = (
		SELECT TOP 1 jh.run_status
		FROM msdb..sysjobs j INNER JOIN msdb..sysjobhistory jh ON j.job_id = jh.job_id 
		WHERE CONVERT(DATETIME, CONVERT(CHAR(8), run_date, 112) + ' ' + STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), run_time), 6), 5, 0, ':'), 3, 0, ':'), 121) > DATEADD(d,0,DATEDIFF(d,0,GETDATE())) 
		AND jh.step_id = 0 AND j.name = @job_name--'BB WEEKLY_BB_DATA_PW'
		--ORDER BY LastRunDateTime desc
		order by run_date desc
	);
	--print @latest_status;


	declare @result int;
	if @job_exists='False'
		set @result = -2; --no such job name
	else
		begin
			if @job_started_today='False'
				set @result = -1 --it's not run yet today
			else
				set @result = @latest_status --the status for the latest run/running job
		end
	return @result
	;
--select jobs.getJobExecutionStatusToday('Job of interest');
end
GO
