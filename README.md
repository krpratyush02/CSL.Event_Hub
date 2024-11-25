# Build status

| Status | Description                              |
| --- |------------------------------------------|
| [![Build Status](https://dev.azure.com/sdxcloud/IST.GLB.GLB.GCCC_IMCSL/_apis/build/status/Template.CSL.AZ.ADO.iNi.001?repoName=Template.CSL.AZ.ADO.iNi.001&branchName=main)](https://dev.azure.com/sdxcloud/IST.GLB.GLB.GCCC_IMCSL/_build/latest?definitionId=3121&repoName=Template.CSL.AZ.ADO.iNi.001&branchName=main) | Build status of the CSL Template         |
| [![Build Status](https://sdxcloud.visualstudio.com/IST.GLB.GLB.GCCC_IMCSL/_apis/build/status%2FRelease%20Factory?repoName=PIPELINES.YML.AZ.ADO.cLD.983&branchName=develop)](https://sdxcloud.visualstudio.com/IST.GLB.GLB.GCCC_IMCSL/_build/latest?definitionId=3857&repoName=PIPELINES.YML.AZ.ADO.cLD.983&branchName=develop)| Build status of the Release Factory  | 
| [![Build Status](https://sdxcloud.visualstudio.com/IST.GLB.GLB.GCCC_IMCSL/_apis/build/status%2FVM.CSL.AZ.ADO.urN.834?repoName=VM.CSL.AZ.ADO.urN.834&branchName=develop)](https://sdxcloud.visualstudio.com/IST.GLB.GLB.GCCC_IMCSL/_build/latest?definitionId=3931&repoName=VM.CSL.AZ.ADO.urN.834&branchName=develop)| Build status of the CSL VM     |
| [![Build Status](https://sdxcloud.visualstudio.com/IST.GLB.GLB.GCCC_IMCSL/_apis/build/status%2FNEW%20IMCSL%20REPOSITORY?branchName=develop)](https://sdxcloud.visualstudio.com/IST.GLB.GLB.GCCC_IMCSL/_build/latest?definitionId=3898&branchName=develop) | Build status of the new IMCSL repository |
# Table of Contents

<!-- toc -->

- [Introduction](#introduction)
- [Requirements](#requirements)
- [Documentation notice ](#documentation-notice)
- [How to use IMCSL EventHub](#how-to-use-imcsl)
- [Contributions are welcome](#contributions-are-welcome)

<!-- tocstop -->


# Introduction

The CSL EventHub library aims to achieve the following objectives:
* Standardization: By providing a centralized repository, we ensure that all EventHub deployed within the organization follow predefined standards and configurations.
* Rapid Deployment: Leveraging the CSL EventHub project, users can quickly deploy new EventHub, eliminating the need to start from scratch for each deployment...
* Compliance and Security: The CSL EventHub aligns with Sodexo's security regulations (AZ-RQ)...


Cloud Shared Library deploys a EventHub with :
- [X] Private Endpoint (optional)
- [X] Service Endpoint (optional)




#### Repository : [CSL.EventHub.AZ](https://sdxcloud.visualstudio.com/IST.GLB.GLB.GCCC_IMCSL/_git/CSL.Event_Hubs.AZ)
#### Last artifact :  [![CSL.EventHub.AZ package in IMCSL feed in Azure Artifacts]()
> Notice: Don't hesitate to fork the repository to start to collaborate with us improving the CSL VM via Pull Requests

[Back to ToC](#table-of-contents)




# Requirements
In order to use the CSL EventHub, you need to have the following prerequisites:
 * The following packages installed in your environment:

| Name                                                                               | Version
|------------------------------------------------------------------------------------|-----|
| <a name="requirement_bicep"></a> [bicep](#requirement\_bicep)	                     | latest|
| <a name="requirement_powershell"></a> [powershell core](#requirement\_powershell)	 | =7.3.4|
| <a name="requirement_azcli"></a> [azcli](#requirement\_azcli)	                     | =2.38|
| <a name="requirement_Az Module"></a> [azmodule](#requirement\_azmodule)	            | =5.9.0|

[Back to ToC](#table-of-contents)


## Features & Parameters

| Parameter                                | Description                                                                                                                                                                   | **Type**      | **Mandatory** | Accepted values                                                                                                                    | Example                                                                                                                                                                                                          |
|------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|---------------|------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `projectName`                            | Display Name of the project for logs                                                                                                                                          | **String**    | **Yes**       | Any valid string                                                                                                                   | "CSL-Project"                                                                                                                                                                                                    |
| `subscriptionName`                       | Name of the Azure subscription                                                                                                                                                | **String**    | **Yes**       | Any valid subscription Name                                                                                                        | "SDX DEV/TEST"                                                                                                                                                                                                   |
| `resourceGroupName`                      | Name of the resource group                                                                                                                                                    | **String**    | **Yes**       | Any valid resource group Name                                                                                                      | "IST-GLB-IENO-CSL-DEV-RG01"                                                                                                                                                                                      |
| `EventHubName`                     | Name of the Azure EventHub                                                                                                                                            | **String**    | **No**        | Any valid EventHub name                                                                                                     | aziesd1stf428                                                                                                                                                                                                    |
| `location`                               | Azure location for the EventHub                                                                                                                                               | **String**    | **Yes**       | Any valid Azure region                                                                                                             | "northeurope"                                                                                                                                                                                                    |
| `EventHubSku`                      | Sku of the EventHub                                                                                                                                                  | **String**    | **Yes**       | "Premium", "Standard" | "Standard"                                                                                                                                                                                                   |                                                                                                                                                                         |		
| `networkConfiguration`                   | Configuration for network-related settings                                                                                                                                    | **Hashtable** | **Yes**       | Object with either `serviceEndpoint` **OR** `privateEndpoint` properties.                                                          | See sub-parameters below                                                                                                                                                                                         |
| └─ `serviceEndpointSubnetIds`   | Array of subnet resource IDs linked to the service endpoint                                                                                                                   | **Array**     | **Yes**       | Array of valid Subnets resource IDs                                                                                                | @("subnetId1", "subnetId2")                                                                                                                                                                                      |
| └─ `privateEndpointName` | Name of the private endpoint                                                                                                                                                  | **String**    | **No**        | Any valid Private Endpoint Name                                                                                                    | "aziepe1aps480"                                                                                                                                                                                                  |
| └─ `privateEndpointSubnetId`   | Target sub-resource of the private Endpoint of associated EventHub                                                                                                   | **String**      | **Yes**       | Array of valid Subnets resource IDs                                                                                      | @("subnetId1", "subnetId2")                                                                                                                                                                                                            |
| `zoneRedundancy`                              |             | **Bool**      | **Yes**       | "True", "False"	                                                                                                                   | $true                                                                                                                                                                                                            |
| `enableLocalAuth`                          ||  **Bool**      | **Yes**       | "True", "False"                                 | $true                                                                                                                                                                                                            |
| `tags`                                   | List of key value pairs that describe the resource         | **Object**|       **No**                                                                                                            | Hashtable | "IST.GLB.GLB.DataFactory_24HCloudFormation"       |                                                                                            |                                                                                                                                                                                         |      
|`autoInflate`| |  **Bool**      | **Yes**       | "True", "False"                                 | $true                                                                                                                                                                                                            |
|`capacity`|| **int**|**Yes**       ||  1|









# AZRQ

#### AZRQ Policies: https://palantir.sodexonet.com/azrq/service/AEH
#### AZRQ Tests: https://palantir.sodexonet.com/azrq/service/AEH

# How to use IMCSL EventHub

## Using IMCSL EventHub in Azure DevOps

```
#Yaml Pipeline example

trigger: none

pool: 'Replace_with_Your_Pool_Name'

variables:
- name: EventhubCslName
  value: "CSL.Event_Hub.AZ"


jobs:
  - job: UseCSLST
    displayName: Use CSL EventHub
    
    steps:
    - checkout: self
      path: $(Build.Repository.Name)

    # Download EventHub artifact from IMCSL feed
    - task: DownloadPackage@1
      displayName: 'Download CSL Artifact ${{ variables.EventhubCslName }}'
      inputs:
        packageType: 'nuget'
        feed: '/22c003e2-e5e3-4c47-bb62-11649d82c74b'
        view: 'Release'
        definition: '${{ variables.EventhubCslName }}'
        version: 'latest'
        downloadPath: '$(System.DefaultWorkingDirectory)/${{ variables.EventhubCslName }}'

    # Execute powershell script who contains project contexte parameters and call IMCSL function. Don't forget declare $(System.AccessToken) in environment variable because you need it for download library from azure devops feed.
    - task: PowerShell@2
      inputs:
        filePath: '$(System.DefaultWorkingDirectory)/EventHub.ps1'
        pwsh: true
        workingDirectory: '$(System.DefaultWorkingDirectory)'
      env:
        SYSTEM_ACCESSTOKEN: $(System.AccessToken)
```

## Local Usage
```
# Download the module from IMCSL Azure DevOps Feed : sdxcloud/IMCSL, sodexo-brs/GCCC_IMCSL
# Configure IMCSL Environment variables :
$Env:IMCSL_AZURE_DEVOPS_PAT = "PAT"
#User authentification
$Env:IMCSL_AZURE_IDENTITY = "User"
$Env:IMCSL_AZURE_DEVOPS_USER = "<YOUR USER>"

#SPN authentification
$Env:IMCSL_AZURE_IDENTITY = "SPN"
$Env:IMCSL_SERVICE_PRINCIPAL_ID = "<YOUR SERVICE PRINCIPAL ID>"
$Env:IMCSL_SERVICE_PRINCIPAL_SECRET = "<YOUR SERVICE PRINCIPAL SECRET>"
$Env:IMCSL_TENANT_ID = "<TENANT ID>"

#Create IMCSL EventHub configuration    
$Config = @{
 ...
}

#Invoke KeyVault IMCSL using the function Invoke-KVIMCSL :
Invoke-IMCSLEH -Configuration $Config

```

[Back to ToC](#table-of-contents)

## Lifecycle management & Idempotence

In order to manage all the lifecycle of Azure EventHub and to provide an idempotent library, CSL EventHub is designed to create, update and delete the Azure EventHub.
- **Creation and Update** :
 'Invoke-IMCSLEH' function : For the first execution, the library will create the Azure EventHub, but after the first successful execution, the library handle the update of the EventHub resource (If the configuration changed)

- **Delete**: 
'Remove-IMCSLEH' function: Will remove the Azure EventHub

## Configuration Example
Below is an example of a PowerShell script that imports and use the IMCSL EventHub module :

```
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
    eventHubName = "aziesd1stf428"
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
    tags = @{
        "applicationName" = "IST.GLB.GLB.DataFactory_24HCloudFormation"
        "applicationOwner" = "IMCSL"
    }
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

          
        
 ```       
> You can run this example using the following script:  
``deployExample.ps1``

     
# Contributions are welcome

**Do you want to become a CSL Contributor ? Here is the Process you should follow !**

[![image.png](Documentation/images/contribution.png)](https://sdxcloud.visualstudio.com/IST.GLB.GLB.GCCC_IMCSL/_wiki/wikis/IST.GLB.GLB.GCCC_IMCSL.wiki/5598/Contribution-Process)

**Here is the Global process of contributions with the 3 possible use cases :**

![image.png](Documentation/images/Items.png)

[Back to ToC](#table-of-contents)


