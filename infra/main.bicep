targetScope = 'subscription'

@description('The location of where to deploy resources')
param location string

@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

var abbrs = loadJsonContent('./abbreviations.json')

resource fileBrowserGrp 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${abbrs.resourcesResourceGroups}-${environmentName}'
  location: location
}

module storageAccount 'storage.bicep' = {
  name: '${deployment().name}storageDeploy'
  scope: fileBrowserGrp
  params: {
    location: location
    storageAccountName: '${abbrs.storageStorageAccounts}${environmentName}storage'
  }
}

module webApp 'app.bicep' = {
  name: '${deployment().name}appDeploy'
  scope: fileBrowserGrp
  params: {
    location: location
    appBaseName: '${abbrs.webSitesAppService}${environmentName}'
    storageId: storageAccount.outputs.storageAccountId
    storageName: storageAccount.outputs.storageAccountName
  }
}
