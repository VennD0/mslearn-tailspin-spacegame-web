// Simple Infrastructure for Tailspin Demo
// Creates UAT and Production App Services with staging slot

param location string = resourceGroup().location
param appNamePrefix string = 'tailspin'

// UAT App Service
resource uatAppServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${appNamePrefix}-uat-plan'
  location: location
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
}

resource uatWebApp 'Microsoft.Web/sites@2023-01-01' = {
  name: '${appNamePrefix}-uat-webapp'
  location: location
  properties: {
    serverFarmId: uatAppServicePlan.id
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: 'v8.0'
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: 'dotnet'
        }
      ]
    }
  }
}

// Production App Service Plan
resource prodAppServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${appNamePrefix}-prod-plan'
  location: location
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
}

// Production Web App
resource prodWebApp 'Microsoft.Web/sites@2023-01-01' = {
  name: '${appNamePrefix}-prod-webapp'
  location: location
  properties: {
    serverFarmId: prodAppServicePlan.id
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: 'v8.0'
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: 'dotnet'
        }
      ]
    }
  }
}

// Staging Slot for Production
resource stagingSlot 'Microsoft.Web/sites/slots@2023-01-01' = {
  parent: prodWebApp
  name: 'staging'
  location: location
  properties: {
    serverFarmId: prodAppServicePlan.id
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: 'v8.0'
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: 'dotnet'
        }
      ]
    }
  }
}

// Outputs
output uatWebAppName string = uatWebApp.name
output prodWebAppName string = prodWebApp.name
output uatUrl string = 'https://${uatWebApp.properties.defaultHostName}'
output prodUrl string = 'https://${prodWebApp.properties.defaultHostName}'
output stagingUrl string = 'https://${stagingSlot.properties.defaultHostName}'
