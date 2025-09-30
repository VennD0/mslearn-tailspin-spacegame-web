// Complete Three-Stage Infrastructure: Dev, Test, and Staging
// Each stage gets its own App Service instance

param location string = resourceGroup().location
param appNamePrefix string = 'tailspin'

// ====== DEV ENVIRONMENT ======
resource devAppServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${appNamePrefix}-dev-plan'
  location: location
  sku: {
    name: 'F1'  // Free tier for dev
    tier: 'Free'
  }
}

resource devWebApp 'Microsoft.Web/sites@2023-01-01' = {
  name: '${appNamePrefix}-dev-webapp'
  location: location
  properties: {
    serverFarmId: devAppServicePlan.id
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
          value: 'Development'
        }
      ]
    }
  }
}

// ====== TEST ENVIRONMENT ======
resource testAppServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${appNamePrefix}-test-plan'
  location: location
  sku: {
    name: 'B1'  // Basic tier for test
    tier: 'Basic'
  }
}

resource testWebApp 'Microsoft.Web/sites@2023-01-01' = {
  name: '${appNamePrefix}-test-webapp'
  location: location
  properties: {
    serverFarmId: testAppServicePlan.id
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
      ]
    }
  }
}

// ====== STAGING ENVIRONMENT ======
resource stagingAppServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${appNamePrefix}-staging-plan'
  location: location
  sku: {
    name: 'S1'  // Standard tier for staging (supports deployment slots)
    tier: 'Standard'
  }
}

resource stagingWebApp 'Microsoft.Web/sites@2023-01-01' = {
  name: '${appNamePrefix}-staging-webapp'
  location: location
  properties: {
    serverFarmId: stagingAppServicePlan.id
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
          value: 'Production'
        }
      ]
    }
  }
}

// Optional: Deployment slot for Staging (for blue-green deployment demo)
resource stagingSlot 'Microsoft.Web/sites/slots@2023-01-01' = {
  parent: stagingWebApp
  name: 'preview'
  location: location
  properties: {
    serverFarmId: stagingAppServicePlan.id
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
      ]
    }
  }
}

// ====== OUTPUTS ======
output devWebAppName string = devWebApp.name
output testWebAppName string = testWebApp.name
output stagingWebAppName string = stagingWebApp.name

output devUrl string = 'https://${devWebApp.properties.defaultHostName}'
output testUrl string = 'https://${testWebApp.properties.defaultHostName}'
output stagingUrl string = 'https://${stagingWebApp.properties.defaultHostName}'
output stagingPreviewUrl string = 'https://${stagingSlot.properties.defaultHostName}'

// Summary for easy reference
output environmentSummary object = {
  dev: {
    name: devWebApp.name
    url: 'https://${devWebApp.properties.defaultHostName}'
    tier: 'Free (F1)'
    purpose: 'Development and feature testing'
  }
  test: {
    name: testWebApp.name
    url: 'https://${testWebApp.properties.defaultHostName}'
    tier: 'Basic (B1)'
    purpose: 'Integration and user acceptance testing'
  }
  staging: {
    name: stagingWebApp.name
    url: 'https://${stagingWebApp.properties.defaultHostName}'
    tier: 'Standard (S1)'
    purpose: 'Pre-production validation with deployment slots'
  }
}
