param location string
param basename string
param storageId string

resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: '${basename}-plan'
  location: location
  sku: {
    name: 'F1'
    capacity: 1
  }
}

resource webApplication 'Microsoft.Web/sites@2021-01-15' = {
  name: '${basename}-app'
  location: location
    properties: {
    serverFarmId: appServicePlan.id
  }
}

resource webSiteConnectionStrings 'Microsoft.Web/sites/config@2020-12-01' = {
  parent: webApplication
  name: 'connectionstrings'
  properties: {
    STORAGE_CONNECTION: {
      value: listKeys(storageId, '2021-09-01').keys[0].value
      type: 'SQLAzure'
    }
  }
}

output webAppName string = webApplication.name
output webAppId string  = webApplication.id
