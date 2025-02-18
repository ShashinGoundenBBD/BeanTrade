-- Ideally we would've liked to use this job to set the status of expired orders when the expiry date of the order was reached
-- Unfortunately SQL Server Express does not support jobs
USE [msdb]
GO

--Check if the job exists
IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'Update Expired Orders Status')
BEGIN
    EXEC msdb.dbo.sp_delete_job @job_name = N'Update Expired Orders Status', @delete_unused_schedule = 1;
END
GO

-- Create SQL Server Job
EXEC msdb.dbo.sp_add_job  
    @job_name = N'Update Expired Orders Status',
    @enabled = 1,  
    @notify_level_eventlog = 0,  
    @notify_level_email = 0,  
    @notify_level_netsend = 0,  
    @notify_level_page = 0,  
    @delete_level = 0,  
    @category_name = N'[Uncategorized (Local)]',
    @owner_login_name = N'sa';  
GO

-- Update the expired orders
EXEC msdb.dbo.sp_add_jobstep  
    @job_name = N'Update Expired Orders Status',
    @step_name = N'Update Status for Expired Orders',  
    @subsystem = N'TSQL',  
    @command = N'
        UPDATE Orders
        SET StatusId = 4
        WHERE ExpiryDate = CAST(GETDATE() AS DATE);
    ',  
    @on_success_action = 1,  
    @on_fail_action = 2;
GO

-- Run the job daily at midnight
EXEC msdb.dbo.sp_add_schedule  
    @schedule_name = N'Daily at Midnight',  
    @freq_type = 4,  -- Daily
    @freq_interval = 1,  -- Every day
    @active_start_time = 0;  -- 00:00:00
GO

-- Attach the schedule to the job
EXEC msdb.dbo.sp_attach_schedule  
    @job_name = N'Update Expired Orders Status',  
    @schedule_name = N'Daily at Midnight';
GO

-- Add the job to the SQL Server Agent
EXEC msdb.dbo.sp_add_jobserver  
    @job_name = N'Update Expired Orders Status';
GO
