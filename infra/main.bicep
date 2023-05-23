targetScope = 'subscription'

@description('The location of where to deploy resources')
param location string

@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

var abbrs = loadJsonContent('./abbreviations.json')
var tags = { 'azd-env-name': environmentName }
param applicationInsightsDashboardName string = ''
param applicationInsightsName string = ''
param logAnalyticsName string = ''
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

resource fileManagerGrp 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

module storageAccount 'storage.bicep' = {
  name: '${deployment().name}storageDeploy'
  scope: fileManagerGrp
  params: {
    location: location
    storageAccountName: '${abbrs.storageStorageAccounts}${environmentName}storage'
  }
}

module monitoring 'monitor/monitoring.bicep' = {
  name: 'monitoring'
  scope: fileManagerGrp
  params: {
    location: location
    tags: tags
    logAnalyticsName: !empty(logAnalyticsName) ? logAnalyticsName : '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    applicationInsightsName: !empty(applicationInsightsName) ? applicationInsightsName : '${abbrs.insightsComponents}${resourceToken}'
    applicationInsightsDashboardName: !empty(applicationInsightsDashboardName) ? applicationInsightsDashboardName : '${abbrs.portalDashboards}${resourceToken}'
  }
}

module webApp 'app.bicep' = {
  name: '${deployment().name}appDeploy'
  scope: fileManagerGrp
  params: {
    location: location
    appBaseName: '${abbrs.webSitesAppService}${environmentName}'
    storageId: storageAccount.outputs.storageAccountId
    storageName: storageAccount.outputs.storageAccountName
    applicationInsightsConnectionString: monitoring.outputs.applicationInsightsConnectionString
    appInsightsInstrumentationKey: monitoring.outputs.applicationInsightsInstrumentationKey
  }
}
