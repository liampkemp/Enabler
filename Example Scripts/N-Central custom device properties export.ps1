$exportPath = C:\temp\N-Central_customproperties.csv

$filter = New-Object psobject
$filter | Add-Member NoteProperty filterid 1257762814
$filter | Add-Member NoteProperty longname "No Workstations"

Connect-NCService

$customers = Get-NCCustomerList
$devices = foreach($c in $customers){Get-NCDeviceList -CustomerId $c.customerid | where {$_.deviceclass -ne "Laptop - Windows" -and $_.deviceclass -ne "Workstations - Windows"}}

$results = Get-NCDevicePropertyList -Device $devices -Filter $filter

$results | Export-Csv $exportPath -NoClobber -NoTypeInformation