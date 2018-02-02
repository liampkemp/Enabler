Import-Module .\Enabler.psm1

Connect-NCService -Url (Read-Host -Prompt "N-Central URL")

Get-NCCustomerList | select parentid -Unique | foreach {Get-NCDeviceList -CustomerId $_.parentid | select customername,sitename,discoveredname,supportedoslabel} | export-csv -Path C:\temp\N-Central_devices.csv -NoClobber -NoTypeInformation