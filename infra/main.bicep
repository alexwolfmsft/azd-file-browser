param location string
targetScope = 'subscription'

@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

var abbrs = loadJsonContent('./abbreviations.json')
var tags = { 'azd-env-name': environmentName }

resource fileBrowserGrp 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

//consume appServicePlan as module
module storageAccount 'storage.bicep' = {
  name: '${deployment().name}storageDeploy'
  scope: fileBrowserGrp
  params: {
    location: location
    storageAccountName: '${abbrs.storageStorageAccounts}${environmentName}'
  }
}

module webApp 'app.bicep' = {
  name: '${deployment().name}appDeploy'
  scope: fileBrowserGrp
  params: {
    location: location
    storageId: storageAccount.outputs.storageAccountId
    basename: environmentName
  }
}
