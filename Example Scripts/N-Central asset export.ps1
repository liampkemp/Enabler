Import-Module .\Enabler.psm1

Connect-NCService -Url (Read-Host -Prompt "N-Central URL")


$customerName = Read-Host "Customer name"

$device = @()
foreach($customer in (Get-NCCustomerList | where {$_.customername -eq $customerName}))
{
    $device += Get-NCDeviceList -CustomerId $customer.customerid | select deviceid,longname,lastloggedinuser,deviceclass |`
    ForEach-Object {
        $assetData = Get-NCDeviceAssetInfoExport -DeviceId $_.deviceid -InformationCategoriesInclusion "asset.computersystem","asset.os"
        $o = New-Object -TypeName psobject
        $o | Add-Member NoteProperty clientName -Value $customer.customername
        $o | Add-Member NoteProperty computerName -Value $_.longname
        $o | Add-Member NoteProperty deviceClass -Value $_.deviceclass
        $o | Add-Member NoteProperty lastLoggedInUser -Value $_.lastloggedinuser
        $o | Add-Member NoteProperty manufacturer -Value $assetData.'asset.computersystem.manufacturer'
        $o | Add-Member NoteProperty model -Value $assetData.'asset.computersystem.model'
        $o | Add-Member NoteProperty serialNumber -Value $assetData.'asset.computersystem.serialnumber'
        $o | Add-Member NoteProperty lastBootupTime -Value $assetData.'asset.os.lastbootuptime'

        $o 
    }
}

$device | ft