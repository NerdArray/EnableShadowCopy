#######################################################################
# Name: EnableShadowCopy.ps1
# Description: Gets all local disks on the computer, then creates a
# scheduled task to take shadowcopy of each disk twice daily.
#######################################################################

# Run in local system context or specify a service account
$user = "NT AUTHORITY\SYSTEM"

# Get's all disks of type 'Local Disk' (3)
$drives = Get-WmiObject -Query "SELECT * from win32_logicaldisk where DriveType = '3'"

# Create an action that takes a shadow copy for each local disk.
$actions = foreach ($drive in $drives)
{
    New-ScheduledTaskAction -Execute "C:\Windows\System32\wbem\WMIC.exe" -Argument "shadowcopy call create Volume=$($drive.DeviceID)\"
}

# Modify AM/PM triggers to change the schedule.
$amTrigger = New-ScheduledTaskTrigger -Daily -At 7am
$pmTrigger = New-ScheduledTaskTrigger -Daily -At 7pm

# Add more triggers to the array if you want.
$triggers = @($amTrigger, $pmTrigger)

# Register the scheduled task.  Overwrite it if it already exists (-Force)
Register-ScheduledTask -Action $actions -Trigger $triggers -User $user -TaskName "Shadow Copy" -Description "Takes a shadowcopy of all local disks daily at 7am and 7pm." -Force