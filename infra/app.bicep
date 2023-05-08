@description('The location of where to deploy resources')
param location string

@description('The base name of the app resources')
param appBaseName string

@description('The id of the associated storage account')
param storageId string

@description('The name of the associated storage account')
param storageName string

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${appBaseName}plan'
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: 'F1'
  }
  kind: 'linux'
}

resource webApplication 'Microsoft.Web/sites@2022-03-01' = {
  name: '${appBaseName}app'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|7.0'
    }
  }
  tags: {
    'azd-service-name': 'web'
  }
}

resource webSiteConnectionStrings 'Microsoft.Web/sites/config@2020-12-01' = {
  parent: webApplication
  name: 'connectionstrings'
  properties: {
    STORAGE_CONNECTION: {
      value: 'DefaultEndpointsProtocol=https;AccountName=${storageName};AccountKey=${listKeys(storageId, '2021-09-01').keys[0].value};EndpointSuffix=core.windows.net'
      type: 'Custom'
    }
  }
}

output webAppName string = webApplication.name
output webAppId string  = webApplication.id
