Import-Module .\Enabler.psm1

Connect-NCService -Url (Read-Host -Prompt "N-Central URL")

$customers = Get-NCCustomerList

while($true)
{
    Start-Sleep 30
    $agentsOffline = Get-NCActiveIssueList -Customer $customers -Acknowledged $false -Failed -SearchBy "Agent Status"

    if($agentsOffline.Count -gt 0)
    {
        (New-Object Media.SoundPlayer "$pwd\Example Scripts\alarm.wav").PlaySync();
    }
}