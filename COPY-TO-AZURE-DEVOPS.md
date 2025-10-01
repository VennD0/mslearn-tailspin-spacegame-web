# Quick Solution: Copy Multistage Pipeline to Azure DevOps

## 🎯 **Immediate Solution**

Since you need the multistage pipeline in your Azure DevOps repository, here are two quick options:

### **Option 1: Copy via Azure DevOps Web Interface (Fastest)**

1. **Open Azure DevOps**: https://devops-delapena@dev.azure.com/devops-delapena/UseCase2-YAML-MultiStaging/_git/tailspin-spacegame-web-deploy

2. **Create New File**: 
   - Click "New" → "File"
   - Name: `azure-pipelines-multistage.yml`

3. **Copy this content**:
```yaml
# Simple Multi-stage Pipeline with Deployment Slots Demo
# Stages: Build → UAT → Production Staging → Slot Swap

trigger:
- main

variables:
  buildConfiguration: 'Release'
  azureServiceConnection: 'azure-service-connection' # Update with your service connection name
  
  # Update these after creating your App Services
  uatWebAppName: 'tailspin-uat-webapp'
  prodWebAppName: 'tailspin-prod-webapp'
  resourceGroupName: 'rg-tailspin-demo'

stages:
- stage: Build
  displayName: 'Build App'
  jobs:
  - job: Build
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    - task: UseDotNet@2
      inputs:
        packageType: 'sdk'
        version: '8.0.x'
    
    - task: DotNetCoreCLI@2
      displayName: 'Build'
      inputs:
        command: 'build'
        projects: 'Tailspin.SpaceGame.Web/Tailspin.SpaceGame.Web.csproj'
        arguments: '--configuration $(buildConfiguration)'
    
    - task: DotNetCoreCLI@2
      displayName: 'Publish'
      inputs:
        command: 'publish'
        projects: 'Tailspin.SpaceGame.Web/Tailspin.SpaceGame.Web.csproj'
        arguments: '--configuration $(buildConfiguration) --output $(Build.ArtifactStagingDirectory)'
        zipAfterPublish: true
    
    - publish: $(Build.ArtifactStagingDirectory)
      artifact: webapp

- stage: DeployUAT
  displayName: 'Deploy to UAT'
  dependsOn: Build
  jobs:
  - deployment: DeployUAT
    environment: 'UAT'
    pool:
      vmImage: 'ubuntu-latest'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureWebApp@1
            displayName: 'Deploy to UAT'
            inputs:
              azureSubscription: '$(azureServiceConnection)'
              appType: 'webApp'
              appName: '$(uatWebAppName)'
              package: '$(Pipeline.Workspace)/webapp/Tailspin.SpaceGame.Web.zip'

- stage: DeployProdStaging
  displayName: 'Deploy to Prod Staging Slot'
  dependsOn: DeployUAT
  jobs:
  - deployment: DeployProdStaging
    environment: 'Production-Staging'
    pool:
      vmImage: 'ubuntu-latest'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureWebApp@1
            displayName: 'Deploy to Staging Slot'
            inputs:
              azureSubscription: '$(azureServiceConnection)'
              appType: 'webApp'
              appName: '$(prodWebAppName)'
              deployToSlotOrASE: true
              resourceGroupName: '$(resourceGroupName)'
              slotName: 'staging'
              package: '$(Pipeline.Workspace)/webapp/Tailspin.SpaceGame.Web.zip'

- stage: SwapToProduction
  displayName: 'Swap to Production'
  dependsOn: DeployProdStaging
  jobs:
  - deployment: SwapSlots
    environment: 'Production'
    pool:
      vmImage: 'ubuntu-latest'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureAppServiceManage@0
            displayName: 'Swap Staging to Production'
            inputs:
              azureSubscription: '$(azureServiceConnection)'
              action: 'Swap Slots'
              webAppName: '$(prodWebAppName)'
              resourceGroupName: '$(resourceGroupName)'
              sourceSlot: 'staging'
```

4. **Commit the file**

### **Option 2: Use Git Commands**
```powershell
# Clone the Azure DevOps repository
git clone https://devops-delapena@dev.azure.com/devops-delapena/UseCase2-YAML-MultiStaging/_git/tailspin-spacegame-web-deploy

# Copy the pipeline file from your current directory
Copy-Item "azure-pipelines-multistage.yml" "tailspin-spacegame-web-deploy/"

# Commit and push
cd tailspin-spacegame-web-deploy
git add azure-pipelines-multistage.yml
git commit -m "Add multistage deployment pipeline"
git push origin main
```

## 🚀 **After Adding the Pipeline**

1. **Go to Azure DevOps Pipelines**
2. **Create New Pipeline**
3. **Choose "Existing Azure Pipelines YAML file"**
4. **Select `/azure-pipelines-multistage.yml`**
5. **Run the pipeline!**

This will get your multistage pipeline working in Azure DevOps immediately!