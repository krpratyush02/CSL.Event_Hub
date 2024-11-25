Import-Module "$PSScriptRoot/../External-modules/$CoreModuleName" -Version $CoreModuleVersion -Force

. $PSScriptRoot/validation/functions.ps1

Function Invoke-PreDeployment
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [Hashtable] $Configuration
    )

    New-IMCSLCommonLogger -projectName $configuration.projectName -libraryName $LibraryName

    Write-IMCSLMessage "Executing Pre-deployment ..."

    Approve-RequiredInputs -Configuration $Configuration
    #Clear context
    Clear-AzContext -Force -ErrorAction SilentlyContinue
    #Connect to Azure
    $ObjectId = Connect-ToAzure -subscriptionName $Configuration.subscriptionName
    $Configuration.ObjectId = $ObjectId

    Approve-Subscription -Configuration $Configuration
    Approve-ResourceGroupName -Configuration $Configuration
    Approve-EventHubNaming -Configuration $Configuration
    Approve-PrivateEndpointNaming -Configuration $Configuration
    Add-HiddenTags -Configuration $Configuration -moduleName $LibraryName

    <#
        Call any functions necessary for checks or configurations specific to your IMCSL library in this pre-deployment stage.
        Example of functions :
            Approve-VirtualMachineConfigurationAndNaming, Approve-OsSku, Approve-KeyvaultConfigurationAndNaming
     #>

    return $Configuration
}
