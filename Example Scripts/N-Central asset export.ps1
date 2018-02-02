Import-Module .\Enabler.psm1

Connect-NCService -Url (Read-Host -Prompt "N-Central URL")


$customerName = Read-Host "Customer name"

Get-NCCustomerList | where {$_.customername -eq $customerName} | foreach {Get-NCDeviceList -CustomerId $_.customerid | select longname,deviceid} | Get-NCDeviceAssetInfoExport