
function Connect-NCService {
    [CmdletBinding()]
    Param
    (
        # Your NCentral URL. i.e. https://ncod95.n-able.com
        [Parameter(Mandatory = $true)]
        [String]$Url,
        
        # Your NCentral credentials as a PSCredential Object. NOTE: Accounts with 2FA will not work
        [Parameter(Mandatory = $true)]
        [pscredential]$Credential
    )

    [pscredential]$Script:Credential = $Credential
    $ApiUrl = "$Url/dms/services/ServerEI?wsdl"
    $Script:NameSpace = "NC" + ([guid]::NewGuid()).ToString().Substring(25)
    $Script:Ncentral = New-WebServiceProxy -Uri $ApiUrl -Namespace $Script:NameSpace -Credential $Credential

}

function Get-NCCustomerList {
    [CmdletBinding()]
    
    $Keypair = New-Object "$Script:NameSpace.T_KeyPair"
    $Keypair.Key = 'ListSOs'
    $Keypair.Value = 'false'
    
    $Username = $Script:Credential.GetNetworkCredential().UserName
    $Password = $Script:Credential.GetNetworkCredential().Password
    $Response = $Script:Ncentral.CustomerList($Username, $Password, $Keypair)


    $Customers = @()
    foreach ($i in $Response) {
        $props = @{}
        foreach ($item in $i.info) {
            $props.add($item.key.split('.')[1], $item.Value)
        }
        $obj = New-Object -TypeName psobject -Property $props
        $Customers += $obj
    }
    $Customers
}

function Get-NCDeviceList{
    [CmdletBinding()]
    Param(
        # Parameter help description
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [Alias('SiteId')]
        [int[]]$CustomerId
        
    )
    
    PROCESS{
        foreach($Customer in $CustomerId){
            $Keypair = New-Object "$Script:NameSpace.T_KeyPair"
            $Keypair.Key = 'CustomerId'
            $Keypair.Value = "$Customer"

            $Username = $Script:Credential.GetNetworkCredential().UserName
            $Password = $Script:Credential.GetNetworkCredential().Password
            $Response = $Script:Ncentral.DeviceList($Username, $Password, $Keypair)

            $Devices = @()
            foreach ($i in $Response) {
                $props = @{}
                foreach ($item in $i.info) {
                    $props.add($item.key.split('.')[1], $item.Value)
                }
                $obj = New-Object -TypeName psobject -Property $props
                $Devices += $obj
            }
            $Devices
        }
    }
    END{}
    
}

function Get-NCDeviceGet{
    [CmdletBinding()]
    Param(
        # Parameter help description
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [int[]]$DeviceId
    )
    
    PROCESS{
        foreach($Device in $DeviceId){
            $Keypair = New-Object "$Script:NameSpace.T_KeyPair"
            $Keypair.Key = 'deviceID'
            $Keypair.Value = "$Device"

            $Username = $Script:Credential.GetNetworkCredential().UserName
            $Password = $Script:Credential.GetNetworkCredential().Password
            $Response = $Script:Ncentral.DeviceGet($Username, $Password, $Keypair)

            $Devices = @()
            foreach ($i in $Response) {
                $props = @{}
                foreach ($item in $i.info) {
                    $props.add($item.key.split('.')[1], $item.Value)
                }
                $obj = New-Object -TypeName psobject -Property $props
                $Devices += $obj
            }
            $Devices
        }
    }
    END{}
    
}

function Get-NCServiceOrganisation {
    [CmdletBinding()]
    
    $Keypair = New-Object "$Script:NameSpace.T_KeyPair"
    $Keypair.Key = 'ListSOs'
    $Keypair.Value = 'true'
    
    $Username = $Script:Credential.GetNetworkCredential().UserName
    $Password = $Script:Credential.GetNetworkCredential().Password
    $Response = $Script:Ncentral.CustomerList($Username, $Password, $Keypair)


    
    foreach ($i in $Response) {
        $props = @{}
        foreach ($item in $i.info) {
            $props.add($item.key.split('.')[1], $item.Value)
        }
        $So = New-Object -TypeName psobject -Property $props
        $So
    }
    
}


function Get-NCDeviceAssetInfoExport{
    [CmdletBinding()]
    Param(
        # Parameter help description
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [int[]]$DeviceId,
        [string[]]$InformationCategoriesInclusion=@("asset.customer","asset.device","asset.computersystem","asset.os")
    )
    
    PROCESS{
        foreach($Device in $DeviceId){
            $keypairCol = @()
            
            $Keypair = New-Object "$Script:NameSpace.T_KeyValue"
            $Keypair.Key = 'TargetByDeviceID'
            $keypair.Value = $DeviceId
            $keypairCol += $Keypair
            $Keypair = New-Object "$Script:NameSpace.T_KeyValue"
            $Keypair.Key = 'InformationCategoriesInclusion'
            $keypair.Value = $InformationCategoriesInclusion
            $keypairCol += $Keypair

            $Username = $Script:Credential.GetNetworkCredential().UserName
            $Password = $Script:Credential.GetNetworkCredential().Password
            $Response = $Script:Ncentral.DeviceAssetInfoExport2("0.0", $Username, $Password, $KeypairCol)

            $Devices = @()
            foreach ($i in $Response) {
                $props = @{}
                foreach ($item in $i.info) {
                    $props.add($item.key, $item.Value)
                }
                $obj = New-Object -TypeName psobject -Property $props
                $Devices += $obj
            }
            $Devices
        }
    }
    END{}

}

function Get-NCDevicePropertyList{
    [CmdletBinding()]
    Param(
        # Parameter help description
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [object[]]$Device,
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [object]$Filter
    )
    
    PROCESS{
        foreach($D in $Device){

            $Username = $Script:Credential.GetNetworkCredential().UserName
            $Password = $Script:Credential.GetNetworkCredential().Password
            $Response = $Script:Ncentral.DevicePropertyList($Username,$Password,$D.deviceid,$D.longname,$Filter.filterid,$filter.longname,$false)

            $results = @()
            foreach($r in $Response)
            {
                foreach($i in $r.Properties)
                {
                    $D | Add-Member NoteProperty $i.Label $i.Value -Force
                }
                $results += $D
            }

            $results
        }
    }
    END{}

}




function Get-NCActiveIssueList{
    [CmdletBinding()]
    Param(
        # Parameter help description
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [object[]]$Customer,
        [bool]$Acknowledged,
        [switch]$NoData,
        [switch]$Stale,
        [switch]$Normal,
        [switch]$Warning,
        [switch]$Failed,
        [switch]$Misconfigured,
        [switch]$Disconnected,
        [string]$SearchBy
    )
    
    PROCESS{
        foreach($C in $Customer){

            $keypairCol = @()
            
            $Keypair = New-Object "$Script:NameSpace.T_KeyPair"
            $Keypair.Key = 'CustomerId'
            $keypair.Value = $C.customerid
            $keypairCol += $Keypair

            if($Acknowledged -eq $true)
            {$Keypair = New-Object "$Script:NameSpace.T_KeyPair"; $Keypair.Key = 'NOC_View_Notification_Acknowledgement_Filter'; $keypair.Value = "Acknowledged"; $keypairCol += $Keypair}
            elseif($Acknowledged -eq $false)
            {$Keypair = New-Object "$Script:NameSpace.T_KeyPair"; $Keypair.Key = 'NOC_View_Notification_Acknowledgement_Filter'; $keypair.Value = "Unacknowledged"; $keypairCol += $Keypair}

            if($NoData)
            {$Keypair = New-Object "$Script:NameSpace.T_KeyPair"; $Keypair.Key = 'NOC_View_Status_Filter'; $keypair.Value = "no data"; $keypairCol += $Keypair}

            if($Stale)
            {$Keypair = New-Object "$Script:NameSpace.T_KeyPair"; $Keypair.Key = 'NOC_View_Status_Filter'; $keypair.Value = "stale"; $keypairCol += $Keypair}

            if($Normal)
            {$Keypair = New-Object "$Script:NameSpace.T_KeyPair"; $Keypair.Key = 'NOC_View_Status_Filter'; $keypair.Value = "normal"; $keypairCol += $Keypair}

            if($Warning)
            {$Keypair = New-Object "$Script:NameSpace.T_KeyPair"; $Keypair.Key = 'NOC_View_Status_Filter'; $keypair.Value = "warning"; $keypairCol += $Keypair}

            if($Failed)
            {$Keypair = New-Object "$Script:NameSpace.T_KeyPair"; $Keypair.Key = 'NOC_View_Status_Filter'; $keypair.Value = "failed"; $keypairCol += $Keypair}

            if($Misconfigured)
            {$Keypair = New-Object "$Script:NameSpace.T_KeyPair"; $Keypair.Key = 'NOC_View_Status_Filter'; $keypair.Value = "misconfigured"; $keypairCol += $Keypair}

            if($Disconnected)
            {$Keypair = New-Object "$Script:NameSpace.T_KeyPair"; $Keypair.Key = 'NOC_View_Status_Filter'; $keypair.Value = "disconnected"; $keypairCol += $Keypair}

            if($SearchBy -ne "" -and $SearchBy -ne $null)
            {$Keypair = New-Object "$Script:NameSpace.T_KeyPair"; $Keypair.Key = 'searchBy'; $keypair.Value = "$SearchBy"; $keypairCol += $Keypair}


            $Username = $Script:Credential.GetNetworkCredential().UserName
            $Password = $Script:Credential.GetNetworkCredential().Password
            $Response = $Script:Ncentral.ActiveIssuesList($Username,$Password,$KeypairCol)

            $results = @()
            foreach($r in $Response)
            {
                
                $o = New-Object psobject

                foreach($i in $r.Issue)
                {$o | Add-Member NoteProperty $i.Key $i.Value}
                
                $results += $o
            }

            $results
        }
    }
    END{}

}

