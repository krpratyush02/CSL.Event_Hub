// Add and adapt neeeded parameters for the deployment depending on the IMCSL library
param location string
param eventHubName string
param skuName string
param zoneRedundancy bool
param enableLocalAuth bool
param autoInflate bool
param capacity int
param tags object = {}
param networkConfiguration object


var serviceEndpointSubnetIds = contains(networkConfiguration, 'serviceEndpoint') && contains(networkConfiguration.serviceEndpoint, 'subnetResourceIds') ? networkConfiguration.serviceEndpoint.subnetResourceIds : []
var privateEndpointSubnetId = contains(networkConfiguration, 'privateEndpoint') && contains(networkConfiguration.privateEndpoint, 'subnetResourceId') ? networkConfiguration.privateEndpoint.subnetResourceId : ''
var isNetworkConfigurationEmpty = empty(serviceEndpointSubnetIds) && empty(privateEndpointSubnetId)
var privateEndpointName = contains(networkConfiguration, 'privateEndpoint') && contains(networkConfiguration.privateEndpoint, 'privateEndpointName') ? networkConfiguration.privateEndpoint.privateEndpointName : ''
var customNetworkInterfaceName = empty(privateEndpointName) ? '' : '${privateEndpointName}-nic'
var groupIds = ['namespace']


module EventHub  '../../External-modules/BICEP.Event_Hubs.AZ/1.0.2/eventHubs.bicep' = if(!isNetworkConfigurationEmpty) {
  name: 'IMCSL-EventHub-${eventHubName}-deployment'
  params: {
    location: location
    eventHubName: eventHubName
    skuName: skuName
    capacity: capacity
    enableLocalAuth: enableLocalAuth
    autoInflate: autoInflate
    tags: tags
    zoneRedundancy: zoneRedundancy
    serviceEndpointSubnetIds: serviceEndpointSubnetIds
  }
}

module PE '../../External-modules/BICEP.Private_Endpoint.AZ/1.1.1/main.bicep' = if(!empty(privateEndpointName)) {
  name: 'IMCSL-PE-${privateEndpointName}-deployment'
  params: {
    location: location
    customNetworkInterfaceName: customNetworkInterfaceName
    groupIds: groupIds
    privateEndpointName: privateEndpointName
    privateEndpointSubnetId: privateEndpointSubnetId 
    privateLinkServiceId: EventHub.outputs.eventHubId
  }
}
