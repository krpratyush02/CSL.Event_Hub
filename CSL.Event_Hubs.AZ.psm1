$cslConfig = @{
    CslLibraryName = "IMCSL-EVENTHUBS"
    CoreModule = @{
        Name    = "POWERSHELL.CORE-MODULES.AZ"
        Version = "1.9.9"
    }
    ExternalModules = @(
        ##Add list of external modules that you need
        
        @{
            Name    = "BICEP.Event_Hubs.AZ"
            Version = "1.0.2"
        }
        @{
            Name    = "BICEP.Private_Endpoint.AZ"
            Version = "1.1.1"
        }
    
        
    )
}

$CoreModuleName = $cslConfig.CoreModule.Name
$CoreModuleVersion = $cslConfig.CoreModule.Version
$LibraryName = $cslConfig.CslLibraryName

Function Import-ExternalModule
{
    param(
        [Parameter(Mandatory = $false, HelpMessage = 'Powershell repository name to set or register')]
        [string] $RepositoryName = "IMCSL",
        [Parameter(Mandatory = $false, HelpMessage = 'Azure Devops feed URL to use as repository source')]
        [string] $RepositorySourceLocation = "https://sdxcloud.pkgs.visualstudio.com/_packaging/IMCSL/nuget/v2",
        [Parameter(Mandatory = $true, HelpMessage = 'Module name')]
        [string] $ModuleName,
        [Parameter(Mandatory = $true, HelpMessage = 'Module version')]
        [string] $ModuleVersion,
        [Parameter(Mandatory = $false, HelpMessage = 'Feed packages endpoint')]
        [string] $packagesEndpoint = "https://feeds.dev.azure.com/sdxcloud/_apis/packaging/Feeds/22c003e2-e5e3-4c47-bb62-11649d82c74b/Packages"
    )
    try
    {
        #  Create PSCredential object to use for Azure DevOps Authentication
        if ([string]::IsNullOrEmpty($Env:IMCSL_AZURE_DEVOPS_USER) -and [string]::IsNullOrEmpty($Env:IMCSL_AZURE_DEVOPS_PAT))
        {
            Write-Host "Trying to get credentials from Azure DevOps system access token ..."

            if ( [string]::IsNullOrEmpty($ENV:SYSTEM_ACCESSTOKEN))
            {
                Write-Error "Azure DevOps system access token (SYSTEM_ACCESSTOKEN ENV VAR) is not available ! try to use Azure DevOps personal access token (PAT)"
            }
            else
            {
                $AZDOCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList @('buildagent', (ConvertTo-SecureString -String $ENV:SYSTEM_ACCESSTOKEN -AsPlainText -Force))
            }
        }
        else
        {
            Write-Host "Trying to get credentials from Azure DevOps personal access token (PAT) ..."
            $AZDOCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList @($Env:IMCSL_AZURE_DEVOPS_USER, (ConvertTo-SecureString -String $Env:IMCSL_AZURE_DEVOPS_PAT -AsPlainText -Force))
        }
        #  END Creating  PSCredential object

        # Checking IMCSL PowerShell module repository is registered or not

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

        Write-Verbose -Message "Searching for PowerShell module repository: $( $RepositoryName )"
        $PrivateRepository = Get-PSRepository -Name $RepositoryName -ErrorAction SilentlyContinue

        if ($null -eq $PrivateRepository)
        {
            Write-Verbose -Message "Registering repository name $RepositoryName  with SourceLocation: $RepositorySourceLocation"
            Register-PSRepository -Name $RepositoryName -SourceLocation $RepositorySourceLocation -InstallationPolicy Trusted -Credential $AZDOCredential
        }
        # End Checking IMCSL PowerShell module repository is registered or not

        #TODO check if module is already installed or not : Error if the module is already installed, log a message : uninstall system module and use external modules saved in External-modules ...
        #Module installation
        $Module = Find-Module -Repository $RepositoryName -AllVersions -name  $ModuleName -Credential $AZDOCredential | where { $_.Version -eq $ModuleVersion }
        if ($Module)
        {

            $Module | Save-Module -Path "$PSScriptRoot/External-modules" -Credential $AZDOCredential
            Write-Verbose -Message "Module $ModuleName ($ModuleVersion) was saved in $PSScriptRoot/External-modules"

            #Check if the module version is the latest or not
            $base64AuthInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$( $AZDOCredential.GetNetworkCredential().Password )"))
            $headers = @{ Authorization = ("Basic {0}" -f $base64AuthInfo) }

            $packagesResponse = Invoke-RestMethod -Uri $packagesEndpoint -Headers $headers -Method Get
            $packageId = $packagesResponse.value | Where-Object { $_.name -eq $ModuleName } | Select-Object -ExpandProperty id

            $versionsEndpoint = "$packagesEndpoint/$packageId/Versions"
            $versionsResponse = Invoke-RestMethod -Uri $versionsEndpoint -Headers $headers -Method Get
            $isLatestVersion = $versionsResponse.value | Where-Object { $_.version -eq $ModuleVersion } | Select-Object -ExpandProperty isLatest

            if ($isLatestVersion -eq $false)
            {
                Write-Warning -Message "Version ($ModuleVersion) is not the latest version of Module $ModuleName."
            }
        }
        else
        {
            Write-Error "Module $ModuleName ($ModuleVersion) does not exist !"
        }
    }
    catch
    {
        Write-Error "$( $_.Exception ) $( $_.ScriptStackTrace )"
    }
}

Function Save-Dependencies {
    $externalModules = $cslConfig.ExternalModules
    if (!(Test-Path ("Env:IMCSL_IGNORE_DOWNLOAD_EXTERNAL_MODULES")) -or $Env:IMCSL_IGNORE_DOWNLOAD_EXTERNAL_MODULES -eq $false) {
        Write-Host "Importing external modules ..."
        #Create External-modules folder if not existing
        $directoryName = "$PSScriptRoot/External-modules"
        if (!(Test-Path "$directoryName")) {
            New-Item -ItemType Directory -Path "$directoryName" | Out-Null
        }

        #Import Core Module
        Import-ExternalModule -ModuleName $CoreModuleName -ModuleVersion $CoreModuleVersion
        #Import other External modules
        $externalModules.ForEach({
                Import-ExternalModule -ModuleName $_.Name -ModuleVersion $_.Version
                Write-Host "External module : $( $_.Name )( version: $( $_.Version )) is ready"
            })

        Write-Host "All external modules are ready ..."
    }
}

Function New-IMCSLNaming
{
    Param (
        [Parameter(mandatory = $true)]
        [string] $projectName,
        [Parameter(mandatory = $true)]
        [string] $location,
        [Parameter(mandatory = $true)]
        [string] $subscriptionName
    )

    Write-Host "Generating naming ..."

    if (!(Test-Path ("Env:IMCSL_IGNORE_DOWNLOAD_EXTERNAL_MODULES")) -or $Env:IMCSL_IGNORE_DOWNLOAD_EXTERNAL_MODULES -eq $false){
        Import-ExternalModule -ModuleName $CoreModuleName -ModuleVersion $CoreModuleVersion
    }

    Import-Module "$PSScriptRoot/External-modules/$CoreModuleName" -Version $CoreModuleVersion -Force
    New-IMCSLCommonLogger -projectName $ProjectName -libraryName $LibraryName
    Connect-ToAzure -subscriptionName $SubscriptionName | Out-Null
    #Use Set-PublicPAASName to generate the naming depending on CSL resource type
    $eventHubName = Set-PublicPAASName -ResourceType 'EventHub' -Location $Location
    
    return $eventHubName
}

Function Invoke-Imcsl {
    [CmdletBinding()]
    Param (
        [Parameter(mandatory = $true)]
        [Hashtable] $Configuration,
        [Parameter(mandatory = $false)]
        [String] $ConfigurationJson = ""
    )

    Write-Host "Start invoking IMCSL Event Hub..."

    # Ingest json configuration file and convert to hastable variable
    if ($ConfigurationJson -ne "")
    {
        $jsonObj = Get-Content $ConfigurationJson | ConvertFrom-Json
        $Configuration = @{ }
        foreach ($property in $jsonObj.PSObject.Properties)
        {
            $Configuration[$property.Name] = $property.Value
        }
    }

    Save-Dependencies

    . $PSScriptRoot/Pre-deployment/main.ps1
    . $PSScriptRoot/Main-deployment/main.ps1
    . $PSScriptRoot/Post-deployment/main.ps1

    $preDeploymentOutputs = Invoke-PreDeployment -Configuration $Configuration
    $mainDeploymentOutputs = Invoke-MainDeployment -Configuration $preDeploymentOutputs
    $postDeploymentOutputs = Invoke-PostDeployment -preDeploymentOutputs $preDeploymentOutputs -mainDeploymentOutputs $mainDeploymentOutputs

    return $postDeploymentOutputs
}

Function Remove-IMCSLEH
{
    param(
        [Parameter(Mandatory = $true)]
        [string] $eventHubName,
        [Parameter(Mandatory = $true)]
        [string] $resourceGroupName,
        [Parameter(Mandatory = $true)]
        [string] $location
    )
    Write-Host "Removing Event Hub $($eventHubName)..."
    Remove-AzEventHub -Name $eventHubName -ResourceGroupName $resourceGroupName -Location $location -Force
}


Export-ModuleMember -Function *
