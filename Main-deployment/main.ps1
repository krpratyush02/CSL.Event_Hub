Function Invoke-MainDeployment
{
    Param
    (
        [Parameter(Mandatory = $true)]
        [Hashtable] $Configuration
    )

    Write-IMCSLMessage "Executing Main-deployment ..."

    # Build Deployment Parameters
    $deploymentName = "IMCSL_deploy_Event_Hub_" + $Configuration.eventHubName

    Write-IMCSLMessage "Deploying Event Hub $($Configuration.eventHubName) : deployment name : $deploymentName ..."
    # Add needed parameters for debug depending on IMCSL library
    Write-IMCSLVerboseMessage "Location : $($Configuration.location)"
    Write-IMCSLVerboseMessage "Resource Group: $($Configuration.resourceGroupName)"

    # Asset deployment
    $deployParams = @{
        eventHubName          = $Configuration.eventHubName
        location              = $Configuration.location
        tags                  = $Configuration.tags
        skuName               = $Configuration.skuName
        capacity              = $Configuration.capacity
        enableLocalAuth       = $Configuration.enableLocalAuth
        autoInflate           = $Configuration.autoInflate
        zoneRedundancy        = $Configuration.zoneRedundancy
        networkConfiguration  = $Configuration.networkConfiguration

        # Add needed parameters for deployment depending on IMCSL library
    }

    # TODO enable/disable Whatif
    # Show in logs the difference
    New-AzResourceGroupDeployment -Whatif -Name $deploymentName -ResourceGroupName $Configuration.resourceGroupName `
    -TemplateParameterObject $deployParams -TemplateFile "$PSScriptRoot\bicep\main.bicep"

    Write-IMCSLVerboseMessage "Get whatIf result object ..."
    ## Get the difference in object
    $results = Get-AzResourceGroupDeploymentWhatIfResult -DeploymentName $deploymentName -ResourceGroupName $Configuration.resourceGroupName `
    -TemplateParameterObject $deployParams -TemplateFile "$PSScriptRoot\bicep\main.bicep" -ResultFormat "FullResourcePayloads"

    # TODO how to manage and show changes
    foreach ($change in $results.Changes)
    {
        Write-IMCSLVerboseMessage $change.Delta
        Write-IMCSLVerboseMessage $change.ChangeType
    }

    $out = New-AzResourceGroupDeployment -Name $deploymentName -ResourceGroupName $Configuration.resourceGroupName `
           -TemplateParameterObject $deployParams -TemplateFile "$PSScriptRoot\bicep\main.bicep"
    $VerbosePreference = $lastVerbosePreference

    $mainDeploymentOutputs = @{
        "Outputs" = $out.outputs
    }

    Write-IMCSLMessage "Main-deployment Executed..."

    return $mainDeploymentOutputs
}

