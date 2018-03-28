Import-Module .\Enabler.psm1

Connect-NCService -Url (Read-Host -Prompt "N-Central URL")

$customers = Get-NCCustomerList

clear
while($true)
{
    $agentsOffline = Get-NCActiveIssueList -Customer $customers -Acknowledged $false -Failed -SearchBy "Agent Status"
    $agentsOffline += Get-NCActiveIssueList -Customer $customers -Acknowledged $false -Failed -SearchBy "Connectivity (VMware)"

    if($agentsOffline.Count -gt 0)
    {
        clear
        $agentsOffline | select 'activeissue.customername','activeissue.devicename','activeissue.deviceclass','activeissue.servicename','activeissue.transitiontime' -Unique | ft
        (New-Object Media.SoundPlayer "$pwd\Example Scripts\alarm.wav").PlaySync();
    }
    else
    {
        clear
        Write-Host "No issues detected!" -ForegroundColor Green
        Start-Sleep 30
    }
}