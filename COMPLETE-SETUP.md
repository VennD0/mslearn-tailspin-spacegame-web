# Complete Setup Instructions for Azure Pipeline Demo

## ✅ Prerequisites Completed
- [x] Visual Studio Code is installed and `code` command is in PATH
- [x] Project is open in VS Code

## 🚀 Next Steps

### 1. Setup Azure CLI (if not already installed)
```powershell
# Check if Azure CLI is installed
az --version

# If not installed, install via winget
winget install Microsoft.AzureCLI
```

### 2. Login to Azure
```powershell
# Login to your Azure account
az login

# Set your subscription (replace with your subscription ID)
az account set --subscription "your-subscription-id"

# Verify you're logged in
az account show
```

### 3. Create Resource Group and Deploy Infrastructure
```powershell
# Create resource group
az group create --name rg-tailspin-demo --location eastus

# Deploy the simple infrastructure
az deployment group create `
  --resource-group rg-tailspin-demo `
  --template-file infra/simple-demo.bicep `
  --parameters appNamePrefix=tailspin-demo

# Get the outputs (note the web app names)
az deployment group show `
  --resource-group rg-tailspin-demo `
  --name simple-demo `
  --query properties.outputs
```

### 4. Setup Azure DevOps Pipeline

#### A. Create Service Connection
1. Go to Azure DevOps → Project Settings → Service connections
2. Create new Azure Resource Manager connection
3. Choose "Service principal (automatic)" 
4. Select your subscription and resource group
5. Name it `azure-service-connection`

#### B. Update Pipeline Variables
In `azure-pipelines-multistage.yml`, update these lines:
```yaml
variables:
  azureServiceConnection: 'azure-service-connection' # ✅ Already set
  uatWebAppName: 'tailspin-demo-uat-webapp'         # 📝 Update this
  prodWebAppName: 'tailspin-demo-prod-webapp'       # 📝 Update this  
  resourceGroupName: 'rg-tailspin-demo'             # ✅ Already set
```

#### C. Create Environments
1. Go to Pipelines → Environments
2. Create these environments:
   - `UAT` (no approval required)
   - `Production-Staging` (no approval required)
   - `Production` (add approval gate - assign yourself as approver)

#### D. Create and Run Pipeline
1. Go to Pipelines → Create Pipeline
2. Choose "Azure Repos Git"
3. Select your repository
4. Choose "Existing Azure Pipelines YAML file"
5. Select `/azure-pipelines-multistage.yml`
6. Save and run!

### 5. Test the Complete Flow

The pipeline will execute these stages:
1. **Build** - Compiles and packages the .NET app
2. **Deploy UAT** - Deploys to UAT environment for testing
3. **Deploy Prod Staging** - Deploys to production staging slot
4. **Swap to Production** - Requires manual approval, then swaps slots

### 6. Verify Deployment
After successful deployment, you can access:
- **UAT**: `https://tailspin-demo-uat-webapp.azurewebsites.net`
- **Production**: `https://tailspin-demo-prod-webapp.azurewebsites.net`
- **Staging**: `https://tailspin-demo-prod-webapp-staging.azurewebsites.net`

## 🎯 Demo Scenario

1. **Make a code change** in `Views/Home/Index.cshtml`
2. **Commit and push** to main branch
3. **Watch pipeline execute** through all stages
4. **Approve production deployment** when prompted
5. **Verify zero-downtime deployment** via slot swap

## 🔧 Troubleshooting

- **Pipeline fails on deployment**: Check service connection permissions
- **Can't access web apps**: Verify resource group and app names in variables
- **Build fails**: Ensure .NET 8.0 SDK is available in build agent

## 📚 Key Concepts Demonstrated

✅ **Multi-stage YAML pipelines**  
✅ **Environment-based deployments**  
✅ **Deployment slots for zero-downtime**  
✅ **Manual approval gates**  
✅ **Infrastructure as Code with Bicep**  
✅ **Blue-green deployment pattern**