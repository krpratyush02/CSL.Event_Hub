Import-Module "$PSScriptRoot/CSL.Event_Hubs.AZ.psm1"

<# To execute CSL in local context, you need to declare the following environment variables #>
<#
    $Env:IMCSL_AZURE_DEVOPS_USER = ""
    $Env:IMCSL_AZURE_DEVOPS_PAT = ""
    $Env:IMCSL_AZURE_IDENTITY = "User"
    $Env:IMCSL_CONTEXT = "DEV"
    $Env:IMCSL_IGNORE_DOWNLOAD_EXTERNAL_MODULES = $false
#>

################################
#      GLOBAL PWSH CONFIG      #
################################
$ErrorActionPreference = "Stop"
$ErrorView = "NormalView"

<#
    It's the main configuration for deployment according to the section "Features & Parameters" in README.
    Users can customize the parameters as needed to deploy different asset configurations.
#>
$Configuration = @{
    ##################-Mandatory parameters-##################
    projectName = "Accelerate Squad"
    subscriptionName = "SDX DEV/TEST"
    resourceGroupName = "IST-GLB-IENO-DELIVERY-DEV-RG09"
    location = "northeurope"
    #eventHubName = "aziesd1stf428"
    networkConfiguration = @{
        <#serviceEndpoint = @{
            subnetResourceIds = @(/
            "/subscriptions/c0978b9d-b809-45f4-aa76-391ceb2cfdba/resourceGroups/IST-GLB-IENO-COMMON-DEV-RG01/providers/Microsoft.Network/virtualNetworks/IST-GLB-IENO-APPLIC-DEV-VN01/subnets/IST-GLB-IENO-APPSBACK-DEV-SN01"
            )
        }#>
        privateEndpoint = @{
                #privateEndpointName = "aziepe1vhr695"
                subnetResourceId = "/subscriptions/c0978b9d-b809-45f4-aa76-391ceb2cfdba/resourceGroups/IST-GLB-IENO-COMMON-DEV-RG01/providers/Microsoft.Network/virtualNetworks/IST-GLB-IENO-PVTPNT-DEV-VN01/subnets/IST-GLB-IENO-PVTPNT-DEV-SN01"
            }
    }

    skuName = "Standard"
    zoneRedundancy = $false
    enableLocalAuth = $true
    autoInflate = $false
    capacity = 1
    ##################-Optional parameters-##################
    <#
    tags = @{
        "applicationName" = "IST.GLB.GLB.DataFactory_24HCloudFormation"
        "applicationOwner" = "IMCSL"
    }
    #>
}

try
{
    
    Invoke-IMCSLEH -Configuration $Configuration
}
catch
{
    Write-Error "$( $_.Exception ) $( $_.ScriptStackTrace )"
}

Remove-Module -Name CSL.Event_Hubs.AZ -Force
