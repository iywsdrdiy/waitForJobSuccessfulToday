USE [Monitor]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  function [jobs].[getProceedIfJobSuccessfulToday] (@job_name nvarchar(128))
returns char(7)
as
/*
Return advice on whether the calling task should proceed or wait, if it is dependent on
this job completing successfully today.

The advice consists of one of the flags 'Proceed', 'Wait' and 'Error'.
*/
begin
	return 
		case (select jobs.getJobExecutionStatusToday(@job_name))
			when	-2	then 'Error'	--Not Found
			when	 0	then 'Error'	--Failed
			when	 3	then 'Error'	--Canceled
			when	-1	then 'Wait'		--No Started
			when	 2	then 'Wait'		--Retry
			when	 4	then 'Wait'		--In Progress
			when	 1	then 'Proceed'	--Succeeded
		end
	--select jobs.getProceedIfJobSuccessfulToday('BB WEEKLY_BB_DATA_PW_');
end

GO
