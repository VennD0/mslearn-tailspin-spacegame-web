# Pipeline Troubleshooting Guide

## 🔍 Common Pipeline Failures & Solutions

### **1. Build Stage Failures**

#### **Error: .NET SDK not found**
```yaml
# Solution: Ensure correct .NET version
- task: UseDotNet@2
  inputs:
    packageType: 'sdk'
    version: '8.0.x'  # Make sure this matches your project
```

#### **Error: Project file not found**
```yaml
# Solution: Check project path
projects: 'Tailspin.SpaceGame.Web/Tailspin.SpaceGame.Web.csproj'
# Make sure this path exists in your repository
```

### **2. Deployment Stage Failures**

#### **Error: Service connection not found**
```yaml
# Solution: Update service connection name
azureServiceConnection: 'your-actual-service-connection-name'
```

#### **Error: Web app not found**
```yaml
# Solution: Update web app names after infrastructure deployment
devWebAppName: 'tailspin-dev-webapp'      # Check actual names
testWebAppName: 'tailspin-test-webapp'    # in Azure portal
stagingWebAppName: 'tailspin-staging-webapp'
```

#### **Error: Environment not found**
- Go to Azure DevOps → Pipelines → Environments
- Create missing environments:
  - Development
  - Test  
  - Staging
  - Staging-Preview
  - Production

### **3. Infrastructure Deployment Failures**

#### **Error: Resource names already exist**
```bash
# Solution: Use unique prefix
az deployment group create \
  --resource-group rg-tailspin-demo \
  --template-file infra/three-stage-demo.bicep \
  --parameters appNamePrefix=tailspin-unique-name
```

#### **Error: Quota exceeded**
- Free tier (F1) allows only 1 free app per subscription
- Consider using B1 Basic tier for all environments

### **4. Permission Errors**

#### **Error: Insufficient permissions**
- Service Principal needs:
  - Contributor role on Resource Group
  - Web App Contributor role
- Check in Azure Portal → IAM

## 🚀 Quick Fixes

### **Option 1: Use Simple Pipeline (Minimal Dependencies)**
```yaml
# Use this basic version for testing
trigger:
- main

variables:
  buildConfiguration: 'Release'

stages:
- stage: Build
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
      inputs:
        command: 'build'
        projects: 'Tailspin.SpaceGame.Web/Tailspin.SpaceGame.Web.csproj'
        arguments: '--configuration $(buildConfiguration)'
```

### **Option 2: Check Prerequisites**
```powershell
# Run this to verify setup
Write-Host "Checking prerequisites..." -ForegroundColor Cyan

# Check Azure CLI
try {
    $azVersion = az --version
    Write-Host "✅ Azure CLI installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI not found" -ForegroundColor Red
}

# Check login
try {
    $account = az account show --query name -o tsv
    Write-Host "✅ Logged into Azure: $account" -ForegroundColor Green
} catch {
    Write-Host "❌ Not logged into Azure" -ForegroundColor Red
    Write-Host "Run: az login" -ForegroundColor Yellow
}

# Check resource group
$rgExists = az group exists --name "rg-tailspin-demo"
if ($rgExists -eq "true") {
    Write-Host "✅ Resource group exists" -ForegroundColor Green
} else {
    Write-Host "❌ Resource group not found" -ForegroundColor Red
    Write-Host "Run: az group create --name rg-tailspin-demo --location eastus" -ForegroundColor Yellow
}
```

## 📋 Step-by-Step Recovery

### **1. First, deploy infrastructure manually:**
```powershell
# Ensure you're logged in
az login

# Create resource group
az group create --name rg-tailspin-demo --location eastus

# Deploy infrastructure with unique names
az deployment group create `
  --resource-group rg-tailspin-demo `
  --template-file infra/three-stage-demo.bicep `
  --parameters appNamePrefix=tailspin-$env:USERNAME
```

### **2. Get the actual web app names:**
```powershell
# Get deployment outputs
az deployment group show `
  --resource-group rg-tailspin-demo `
  --name three-stage-demo `
  --query properties.outputs
```

### **3. Update pipeline variables with actual names**

### **4. Test with simple build-only pipeline first**

## 🆘 Emergency: Build-Only Pipeline
If everything fails, use this minimal pipeline to test:

```yaml
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

steps:
- task: UseDotNet@2
  inputs:
    packageType: 'sdk'
    version: '8.0.x'

- task: DotNetCoreCLI@2
  inputs:
    command: 'build'
    projects: 'Tailspin.SpaceGame.Web/Tailspin.SpaceGame.Web.csproj'
    arguments: '--configuration Release'

- task: DotNetCoreCLI@2
  inputs:
    command: 'publish'
    projects: 'Tailspin.SpaceGame.Web/Tailspin.SpaceGame.Web.csproj'
    arguments: '--configuration Release --output $(Build.ArtifactStagingDirectory)'
    zipAfterPublish: true

- publish: $(Build.ArtifactStagingDirectory)
  artifact: webapp
```

## 📞 Need Help?
Share the specific error message and I can provide targeted solutions!