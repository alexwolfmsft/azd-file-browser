@description('Storage Account type')
param storageAccountType string = 'Standard_LRS'

@description('The storage account location.')
param location string = resourceGroup().location

@description('The name of the storage account')
param storageAccountName string

@description('Name of the blob container')
param containerName string = 'demofiles'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'

  resource blobService 'blobServices' = {
    name: 'default'
    
    resource container 'containers' = {
      name: containerName
    }
  }
}

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
