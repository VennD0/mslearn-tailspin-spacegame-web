# Quick Setup Guide for Multi-Stage Pipeline Demo

## Prerequisites
1. Azure subscription
2. Azure DevOps organization
3. Service connection to Azure in Azure DevOps

## Setup Steps

### 1. Create Azure Resources
Deploy the simple infrastructure:
```bash
# Create resource group
az group create --name rg-tailspin-demo --location eastus

# Deploy infrastructure
az deployment group create \
  --resource-group rg-tailspin-demo \
  --template-file infra/simple-demo.bicep \
  --parameters appNamePrefix=tailspin-demo
```

### 2. Update Pipeline Variables
In `azure-pipelines-multistage.yml`, update these variables:
- `azureServiceConnection`: Your Azure service connection name
- `uatWebAppName`: Output from deployment (e.g., `tailspin-demo-uat-webapp`)
- `prodWebAppName`: Output from deployment (e.g., `tailspin-demo-prod-webapp`)
- `resourceGroupName`: `rg-tailspin-demo`

### 3. Create Environments in Azure DevOps
1. Go to Pipelines → Environments
2. Create these environments:
   - `UAT`
   - `Production-Staging` 
   - `Production` (add approval gate)

### 4. Run the Pipeline
1. Commit and push the pipeline file
2. The pipeline will:
   - **Build** the .NET app
   - **Deploy to UAT** for testing
   - **Deploy to Production staging slot** for validation
   - **Swap staging to production** (with approval)

## Key Features Demonstrated

✅ **Multi-stage pipeline** with environment gates  
✅ **Deployment slots** for zero-downtime deployments  
✅ **Manual approval** before production  
✅ **Staging validation** before slot swap  
✅ **Infrastructure as Code** with Bicep  

## Testing the Demo
1. Make a change to the app
2. Push to main branch
3. Watch the pipeline progress through stages
4. Approve deployments when prompted
5. Verify the app is deployed successfully

## URLs After Deployment
- UAT: `https://[uatWebAppName].azurewebsites.net`
- Production: `https://[prodWebAppName].azurewebsites.net`
- Staging: `https://[prodWebAppName]-staging.azurewebsites.net`