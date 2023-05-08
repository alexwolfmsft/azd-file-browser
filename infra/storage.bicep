@description('Storage Account type')
param storageAccountType string = 'Standard_LRS'

@description('The storage account location.')
param location string = resourceGroup().location

@description('The name of the storage account')
param storageAccountName string

@description('Name of the blob as it is stored in the blob container')
param filename string = 'blob.txt'

@description('Name of the blob container')
param containerName string = 'images'

resource sa 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'

  resource blobService 'blobServices' = {
    name: 'default'

    resource container 'containers' = {
      name: 'images'
    }
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployscript-upload-blob'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.26.1'
    timeout: 'PT5M'
    retentionInterval: 'PT1H'
    environmentVariables: [
      {
        name: 'AZURE_STORAGE_ACCOUNT'
        value: sa.name
      }
      {
        name: 'AZURE_STORAGE_KEY'
        secureValue: sa.listKeys().keys[0].value
      }
      {
        name: 'CONTENT'
        value: loadTextContent('blob.txt')
      }
    ]
    scriptContent: 'echo "$CONTENT" > ${filename} && az storage blob upload -f ${filename} -c ${containerName} -n ${filename}'
  }
}

output storageAccountName string = storageAccountName
output storageAccountId string = sa.id
