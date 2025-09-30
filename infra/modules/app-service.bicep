@description('Name of the environment')
param environmentName string

@description('Primary location for all resources')
param location string

@description('Resource token for unique naming')
param resourceToken string

@description('Environment suffix (uat or prod)')
param environmentSuffix string

@description('Application Insights connection string')
param appInsightsConnectionString string

@description('Managed identity resource ID')
param managedIdentityId string

@description('Managed identity client ID')
param managedIdentityClientId string

@description('Key Vault name')
param keyVaultName string

@description('Whether to create a deployment slot')
param createDeploymentSlot bool = false

// Variables
var appServicePlanName = 'asp-${environmentSuffix}-${resourceToken}'
var webAppName = 'app-${environmentSuffix}-${resourceToken}'
var deploymentSlotName = 'staging'

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  tags: {
    'azd-env-name': environmentName
  }
  sku: {
    name: 'S1'
    tier: 'Standard'
    size: 'S1'
    family: 'S'
    capacity: 1
  }
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

// Web App
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: location
  tags: {
    'azd-env-name': environmentName
    'azd-service-name': 'web'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: 'v8.0'
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: 'dotnet'
        }
      ]
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: environmentSuffix == 'prod' ? 'Production' : 'Development'
        }
        {
          name: 'ApplicationInsights__ConnectionString'
          value: appInsightsConnectionString
        }
        {
          name: 'AZURE_CLIENT_ID'
          value: managedIdentityClientId
        }
        {
          name: 'KeyVault__VaultName'
          value: keyVaultName
        }
      ]
    }
  }
}

// App Service Site Extension (required by AZD rules)
resource siteExtension 'Microsoft.Web/sites/siteextensions@2023-01-01' = {
  parent: webApp
  name: 'Microsoft.AspNetCore.AzureAppServices.SiteExtension'
}

// Deployment Slot (only for production)
resource deploymentSlot 'Microsoft.Web/sites/slots@2023-01-01' = if (createDeploymentSlot) {
  parent: webApp
  name: deploymentSlotName
  location: location
  tags: {
    'azd-env-name': environmentName
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: 'v8.0'
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: 'dotnet'
        }
      ]
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Staging'
        }
        {
          name: 'ApplicationInsights__ConnectionString'
          value: appInsightsConnectionString
        }
        {
          name: 'AZURE_CLIENT_ID'
          value: managedIdentityClientId
        }
        {
          name: 'KeyVault__VaultName'
          value: keyVaultName
        }
      ]
    }
  }
}

// Site Extension for Deployment Slot (only for production)
resource slotSiteExtension 'Microsoft.Web/sites/slots/siteextensions@2023-01-01' = if (createDeploymentSlot) {
  parent: deploymentSlot
  name: 'Microsoft.AspNetCore.AzureAppServices.SiteExtension'
}

// Outputs
output webAppId string = webApp.id
output webAppName string = webApp.name
output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
output appServicePlanId string = appServicePlan.id
output appServicePlanName string = appServicePlan.name
output deploymentSlotName string = createDeploymentSlot ? deploymentSlotName : ''
output deploymentSlotUrl string = createDeploymentSlot ? 'https://${webApp.properties.defaultHostName}' : 'N/A'
