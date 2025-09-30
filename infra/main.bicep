targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Name of the resource group')
param resourceGroupName string = 'rg-${environmentName}'

// Variables
var resourceToken = uniqueString(subscription().id, location, environmentName)
var tags = {
  'azd-env-name': environmentName
}

// Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// User-Assigned Managed Identity (required by AZD rules)
module managedIdentity 'modules/managed-identity.bicep' = {
  name: 'managed-identity'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    resourceToken: resourceToken
  }
}

// Key Vault
module keyVault 'modules/key-vault.bicep' = {
  name: 'key-vault'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    resourceToken: resourceToken
    managedIdentityPrincipalId: managedIdentity.outputs.managedIdentityPrincipalId
  }
}

// Log Analytics Workspace
module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'log-analytics'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    resourceToken: resourceToken
  }
}

// Application Insights
module appInsights 'modules/app-insights.bicep' = {
  name: 'app-insights'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    resourceToken: resourceToken
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
  }
}

// UAT App Service Plan and Web App
module uatAppService 'modules/app-service.bicep' = {
  name: 'uat-app-service'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    resourceToken: resourceToken
    environmentSuffix: 'uat'
    appInsightsConnectionString: appInsights.outputs.appInsightsConnectionString
    managedIdentityId: managedIdentity.outputs.managedIdentityId
    managedIdentityClientId: managedIdentity.outputs.managedIdentityClientId
    keyVaultName: keyVault.outputs.keyVaultName
    createDeploymentSlot: false
  }
}

// Production App Service Plan and Web App with Deployment Slot
module prodAppService 'modules/app-service.bicep' = {
  name: 'prod-app-service'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    resourceToken: resourceToken
    environmentSuffix: 'prod'
    appInsightsConnectionString: appInsights.outputs.appInsightsConnectionString
    managedIdentityId: managedIdentity.outputs.managedIdentityId
    managedIdentityClientId: managedIdentity.outputs.managedIdentityClientId
    keyVaultName: keyVault.outputs.keyVaultName
    createDeploymentSlot: true
  }
}

// Outputs (required by AZD)
output RESOURCE_GROUP_ID string = rg.id
output AZURE_LOCATION string = location
output UAT_WEB_APP_NAME string = uatAppService.outputs.webAppName
output PROD_WEB_APP_NAME string = prodAppService.outputs.webAppName
output UAT_WEB_APP_URL string = uatAppService.outputs.webAppUrl
output PROD_WEB_APP_URL string = prodAppService.outputs.webAppUrl
output APPLICATION_INSIGHTS_CONNECTION_STRING string = appInsights.outputs.appInsightsConnectionString
output KEY_VAULT_NAME string = keyVault.outputs.keyVaultName
