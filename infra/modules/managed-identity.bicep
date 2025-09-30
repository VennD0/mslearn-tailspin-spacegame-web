@description('Name of the environment')
param environmentName string

@description('Primary location for all resources')
param location string

@description('Resource token for unique naming')
param resourceToken string

// Variables
var managedIdentityName = 'mi${resourceToken}'

// User-Assigned Managed Identity (required by AZD rules)
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
  tags: {
    'azd-env-name': environmentName
  }
}

// Outputs
output managedIdentityId string = managedIdentity.id
output managedIdentityPrincipalId string = managedIdentity.properties.principalId
output managedIdentityClientId string = managedIdentity.properties.clientId
output managedIdentityName string = managedIdentity.name
