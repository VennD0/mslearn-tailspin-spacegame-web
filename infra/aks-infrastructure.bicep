// Azure Container Registry and Azure Kubernetes Service Infrastructure
// For Tailspin SpaceGame UseCase 3: Docker + AKS deployment

@description('Location for all resources')
param location string = resourceGroup().location

@description('Name prefix for all resources')
param namePrefix string = 'tailspin'

@description('Environment suffix (dev, staging, prod)')
param environment string = 'prod'

@description('AKS cluster name')
param aksClusterName string = '${namePrefix}-aks-${environment}'

@description('ACR name (must be globally unique)')
param acrName string = '${namePrefix}acr${environment}${uniqueString(resourceGroup().id)}'

@description('Kubernetes version')
param kubernetesVersion string = '1.28.5'

@description('Node pool VM size')
param nodeVmSize string = 'Standard_D2s_v3'

@description('Number of nodes in the default node pool')
param nodeCount int = 3

@description('Tags for all resources')
param tags object = {
  project: 'TailspinSpaceGame'
  useCase: 'UseCase3-Docker-AKS'
  environment: environment
  managedBy: 'bicep'
}

// Azure Container Registry
resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
    dataEndpointEnabled: false
    encryption: {
      status: 'disabled'
    }
    networkRuleBypassOptions: 'AzureServices'
    policies: {
      quarantinePolicy: {
        status: 'disabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: 'disabled'
      }
      retentionPolicy: {
        days: 30
        status: 'enabled'
      }
    }
    publicNetworkAccess: 'Enabled'
    zoneRedundancy: 'Disabled'
  }
}

// Azure Kubernetes Service
resource aks 'Microsoft.ContainerService/managedClusters@2023-09-02-preview' = {
  name: aksClusterName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${aksClusterName}-dns'
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: nodeCount
        vmSize: nodeVmSize
        osType: 'Linux'
        mode: 'System'
        type: 'VirtualMachineScaleSets'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        enableAutoScaling: true
        minCount: 1
        maxCount: 5
        maxPods: 30
        osDiskSizeGB: 30
        osDiskType: 'Managed'
        kubeletDiskType: 'OS'
        enableNodePublicIP: false
        enableCustomCATrust: false
        enableEncryptionAtHost: false
        enableUltraSSD: false
        enableFIPS: false
        gpuInstanceProfile: 'MIG1g'
      }
    ]
    networkProfile: {
      networkPlugin: 'kubenet'
      loadBalancerSku: 'Standard'
      outboundType: 'loadBalancer'
    }
    addonProfiles: {
      azureKeyvaultSecretsProvider: {
        enabled: false
      }
      azurepolicy: {
        enabled: false
      }
      httpApplicationRouting: {
        enabled: false
      }
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspace.id
        }
      }
    }
    autoUpgradeProfile: {
      upgradeChannel: 'patch'
    }
    disableLocalAccounts: false
    enableRBAC: true
    nodeResourceGroup: '${resourceGroup().name}-aks-nodes'
    privateLinkResources: []
    publicNetworkAccess: 'Enabled'
  }
}

// Log Analytics Workspace for AKS monitoring
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${namePrefix}-logs-${environment}'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Role assignment to allow AKS to pull from ACR
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, aks.id, 'AcrPull')
  scope: acr
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull role
    principalId: aks.properties.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
  }
}

// Outputs
output acrName string = acr.name
output acrLoginServer string = acr.properties.loginServer
output aksClusterName string = aks.name
output aksClusterFqdn string = aks.properties.fqdn
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name
output resourceGroupName string = resourceGroup().name

// Output for pipeline variables
output acrLoginCommand string = 'az acr login --name ${acr.name}'
output getCredentialsCommand string = 'az aks get-credentials --resource-group ${resourceGroup().name} --name ${aks.name}'