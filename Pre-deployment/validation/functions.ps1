#Rename your function depending on your IMCSL library. Example: Approve-RequiredVmInputs
Function Approve-RequiredInputs
{
    param (
        [Parameter(Mandatory = $true)]
        [Hashtable] $Configuration
    )

    Write-IMCSLVerboseMessage "Checking that all required variables are not null or empty ..."
    #Add requited parameters depending on your IMCSL library needs
    $requiredInputs = @("projectName", "subscriptionName", "resourceGroupName", "location", "networkConfiguration", "skuName")

    foreach ($inputName in $requiredInputs)
    {
        $inputValue = $Configuration[$inputName]
        # Check that input value is not null or empty
        if ( [string]::IsNullOrEmpty($inputValue))
        {
            Write-IMCSLError "Input parameter '$inputName' cannot be null or empty."
        }

        if ($inputName -eq "networkConfiguration")
        {
            $serviceEndpoint = $inputValue['serviceEndpoint']
            $privateEndpoint = $inputValue['privateEndpoint']

            if (($null -eq $serviceEndpoint -and $null -eq $privateEndpoint) -or
                    ($null -ne $serviceEndpoint -and $null -ne $privateEndpoint))
            {
                Write-IMCSLError "Either serviceEndpoint or privateEndpoint must be provided in networkConfiguration"
            }

            if ($null -ne $serviceEndpoint)
            {
                $subnetResourceIds = $serviceEndpoint['subnetResourceIds']
                if ($null -eq $subnetResourceIds -or -not $subnetResourceIds -is [array] -or $subnetResourceIds.Count -eq 0)
                {
                    Write-IMCSLError "subnetResourceIds property in serviceEndpoint must be provided and must be a non null array of subnet Ids."
                }
            }

            if ($null -ne $privateEndpoint)
            {
                $subnetResourceId = $privateEndpoint['subnetResourceId']
                if ($null -eq $subnetResourceId -or $subnetResourceId.Count -eq 0)
                {
                    Write-IMCSLError "subnetResourceId in privateEndpoint must be provided."
                }
            }
        }
    }
}

Function Approve-EventHubNaming
{
    param (
        [Parameter(Mandatory = $true)]
        [Hashtable] $Configuration
    )

    if ($Configuration.eventHubName)
    {
        Write-IMCSLMessage  "Checking Event Hub Name..."
        $eventHub = Get-AzEventHubNamespace -Name $Configuration.eventHubName -ResourceGroupName $Configuration.resourceGroupName -ErrorAction SilentlyContinue
        if (!$eventHub)
        {
            # Checking Naming convention
            Approve-PublicPAASName -ResourceName $Configuration.eventHubName -ResourceType 'EventHubs' -Location $Configuration.location
        }
    }
    else
    {
        Write-IMCSLMessage  "Event Hub  name was not provided, generating new one ..."
        $eventHubName = Set-PublicPAASName -ResourceType 'EventHubs' -Location $Configuration.location
        $Configuration.eventHubName = $eventHubName
    }
}

Function Approve-PrivateEndpointNaming
{
    param (
        [Parameter(Mandatory = $true)]
        [Hashtable] $Configuration
    )
    $privateEndpoint = $Configuration['networkConfiguration']['privateEndpoint']
    $privateEndpointName = $privateEndpoint.privateEndpointName

    if ($null -ne $privateEndpoint)
    {
        if (![string]::IsNullOrEmpty($privateEndpointName))
        {
            Write-IMCSLMessage  "Checking Private Endpoint Name..."
            $privateEndpoint = Get-AzPrivateEndpoint -Name $privateEndpointName -ResourceGroupName $Configuration.resourceGroupName -ErrorAction SilentlyContinue
            if (!$privateEndpoint)
            {
                # Checking Naming convention
                Approve-PublicPAASName -ResourceName $privateEndpointName -ResourceType 'PrivateEndpoint' -Location $Configuration.location
            }
        }
        else
        {
            Write-IMCSLMessage  "Private Endpoint name was not provided, generating new one ..."
            $privateEndpointName = Set-PublicPAASName -ResourceType 'PrivateEndpoint' -Location $Configuration.location
            $Configuration.networkConfiguration.privateEndpoint.privateEndpointName = $privateEndpointName
        }
    }

}
<#
  Add any functions necessary for checks or configurations specific to your IMCSL library in this pre-deployment stage.
  Example of functions :
    Approve-VirtualMachineConfigurationAndNaming, Approve-OsSku, Approve-KeyvaultConfigurationAndNaming
#>
