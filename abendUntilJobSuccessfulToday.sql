USE [Monitor]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create  procedure [jobs].[abendUntilJobSuccessfulToday] 
@job_name nvarchar(128)

as
/*
Return advice on whether the calling task should proceed or wait, if it is dependent on
this job completing successfully today.

The advice consists of one of the flags 'Proceed', 'Wait' and 'Error'.
*/
declare @status char(7)
set nocount on;
		select @status = Monitor.jobs.getProceedIfJobSuccessfulToday(@job_name)
		if @status='Error'	throw 50000, 'Error: the job is either unfound, failed or cancelled',1

		else if @status='Wait' throw 50000, 'Error: the job is either not started, retrying or in progress',1
		else select @status as status

	--exec [jobs].[abendUntilJobSuccessfulToday] 'Job being monitored'

GO
