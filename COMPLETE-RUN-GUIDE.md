# Complete Guide: How to Run Your Multistage Pipeline

## Prerequisites Setup

### 1. Install Azure CLI
```powershell
# Option 1: Using winget (recommended)
winget install Microsoft.AzureCLI

# Option 2: Download from https://aka.ms/installazurecliwindows
```

### 2. Login to Azure
```powershell
az login
```

### 3. Set your subscription
```powershell
az account list --output table
az account set --subscription "your-subscription-name-or-id"
```

## Quick Pipeline Setup (Without Infrastructure Script)

### Option 1: Manual Infrastructure Creation

#### Step 1: Create Resource Group
```powershell
az group create --name rg-tailspin-demo --location eastus
```

#### Step 2: Create UAT Environment
```powershell
# UAT App Service Plan (Free tier)
az appservice plan create --name tailspin-uat-plan --resource-group rg-tailspin-demo --sku F1 --location eastus

# UAT Web App
az webapp create --name tailspin-uat-webapp --resource-group rg-tailspin-demo --plan tailspin-uat-plan --runtime "DOTNETCORE:8.0"
```

#### Step 3: Create Production Environment
```powershell
# Production App Service Plan (Standard tier - supports slots)
az appservice plan create --name tailspin-prod-plan --resource-group rg-tailspin-demo --sku S1 --location eastus

# Production Web App
az webapp create --name tailspin-prod-webapp --resource-group rg-tailspin-demo --plan tailspin-prod-plan --runtime "DOTNETCORE:8.0"

# Staging Slot
az webapp deployment slot create --name tailspin-prod-webapp --resource-group rg-tailspin-demo --slot staging
```

### Option 2: Use Azure Portal

1. **Go to Azure Portal**: https://portal.azure.com
2. **Create Resource Group**: `rg-tailspin-demo`
3. **Create App Services**:
   - UAT: `tailspin-uat-webapp` (Free F1)
   - Production: `tailspin-prod-webapp` (Standard S1)
4. **Add Staging Slot** to Production app

## Azure DevOps Pipeline Setup

### Step 1: Add Pipeline to Repository

1. **Go to Azure DevOps**: https://devops-delapena@dev.azure.com/devops-delapena/UseCase2-YAML-MultiStaging/_git/tailspin-spacegame-web-deploy

2. **Create New File**:
   - Click "New" → "File"
   - Name: `azure-pipelines-multistage.yml`
   - Content: Copy from your local file

### Step 2: Create Service Connection

1. **Project Settings** → **Service connections**
2. **New service connection** → **Azure Resource Manager**
3. **Service principal (automatic)**
4. **Subscription**: Your Azure subscription
5. **Resource group**: `rg-tailspin-demo`
6. **Service connection name**: `azure-service-connection`

### Step 3: Create Environments

Go to **Pipelines** → **Environments** and create:

| Environment | Approval | Description |
|-------------|----------|-------------|
| `UAT` | None | UAT deployment environment |
| `Production-Staging` | None | Deploy to staging slot |
| `Production` | **Required** | Production slot swap |

### Step 4: Update Pipeline Variables

In your `azure-pipelines-multistage.yml`, update:

```yaml
variables:
  buildConfiguration: 'Release'
  azureServiceConnection: 'azure-service-connection'
  
  # Update these with your actual app names
  uatWebAppName: 'tailspin-uat-webapp'
  prodWebAppName: 'tailspin-prod-webapp'
  resourceGroupName: 'rg-tailspin-demo'
```

### Step 5: Create and Run Pipeline

1. **Pipelines** → **New pipeline**
2. **Azure Repos Git** → Select repository
3. **Existing Azure Pipelines YAML file**
4. **Path**: `/azure-pipelines-multistage.yml`
5. **Run**

## Expected Pipeline Flow

```
🔄 Build Stage
   ├── Install .NET 8 SDK
   ├── Build application
   ├── Publish artifacts
   └── ✅ Artifact: webapp

🔄 Deploy UAT
   ├── Download artifacts
   ├── Deploy to UAT app
   └── ✅ UAT: https://tailspin-uat-webapp.azurewebsites.net

🔄 Deploy Production Staging
   ├── Download artifacts
   ├── Deploy to staging slot
   └── ✅ Staging: https://tailspin-prod-webapp-staging.azurewebsites.net

⏸️ Manual Approval Required (Production environment)

🔄 Swap to Production
   ├── Swap staging → production
   └── ✅ Production: https://tailspin-prod-webapp.azurewebsites.net
```

## Troubleshooting

### Pipeline Fails at Build
- Check project path: `Tailspin.SpaceGame.Web/Tailspin.SpaceGame.Web.csproj`
- Ensure .NET 8.0 is configured

### Pipeline Fails at Deployment
- Verify service connection permissions
- Check web app names in variables
- Ensure environments are created

### Service Connection Issues
- Verify subscription permissions
- Check resource group access
- Recreate service connection if needed

## Quick Test

After setup, test with a simple change:

```powershell
# Make a small change
echo "Pipeline test" >> README.md

# Commit and push (if using Azure Repos)
git add README.md
git commit -m "Test pipeline trigger"
git push origin main
```

This will trigger the complete multistage pipeline flow!