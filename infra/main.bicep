targetScope = 'subscription'

@description('The location of where to deploy resources')
param location string

@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

var tags = { 'azd-env-name': environmentName }

resource fileBrowserGrp 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${environmentName}'
  location: location
}

//consume appServicePlan as module
module storageAccount 'storage.bicep' = {
  name: '${deployment().name}storageDeploy'
  scope: fileBrowserGrp
  params: {
    location: location
    storageAccountName: '${environmentName}storage'
  }
}

module webApp 'app.bicep' = {
  name: '${deployment().name}appDeploy'
  scope: fileBrowserGrp
  params: {
    location: location
    storageId: storageAccount.outputs.storageAccountId
    basename: environmentName
    storageName: storageAccount.outputs.storageAccountName
  }
}
