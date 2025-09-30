# Three-Stage Environment Setup Guide
## Dev → Test → Staging with Deployment Slots

## 📋 What We're Creating

### **Three Separate App Service Instances:**
1. **Dev Environment** (Free F1) - Development and feature testing
2. **Test Environment** (Basic B1) - Integration and UAT 
3. **Staging Environment** (Standard S1) - Pre-production with deployment slots

### **Pipeline Flow:**
```
Build → Dev → Test → Staging → Preview Slot → Swap to Live
```

## 🚀 Deployment Steps

### 1. Deploy the Three-Stage Infrastructure
```powershell
# Create resource group
az group create --name rg-tailspin-demo --location eastus

# Deploy three-stage infrastructure
az deployment group create `
  --resource-group rg-tailspin-demo `
  --template-file infra/three-stage-demo.bicep `
  --parameters appNamePrefix=tailspin

# Get the app names for pipeline configuration
az deployment group show `
  --resource-group rg-tailspin-demo `
  --name three-stage-demo `
  --query properties.outputs.environmentSummary.value
```

### 2. Update Pipeline Variables
In `azure-pipelines-three-stage.yml`, update these variables with the output from deployment:
```yaml
variables:
  devWebAppName: 'tailspin-dev-webapp'      # From deployment output
  testWebAppName: 'tailspin-test-webapp'    # From deployment output  
  stagingWebAppName: 'tailspin-staging-webapp' # From deployment output
  resourceGroupName: 'rg-tailspin-demo'
```

### 3. Create Azure DevOps Environments
Create these environments in Azure DevOps (Pipelines → Environments):

| Environment | Approval Required | Purpose |
|-------------|------------------|---------|
| `Development` | ❌ No | Automatic deployment for all branches |
| `Test` | ❌ No | Automatic deployment after dev success |
| `Staging` | ❌ No | Automatic deployment after test success |
| `Staging-Preview` | ❌ No | Deploy to preview slot |
| `Production` | ✅ **Yes** | Manual approval for slot swap |

### 4. Environment Configuration

#### **Dev Environment (F1 Free)**
- 🎯 **Purpose**: Feature development and initial testing
- 💰 **Cost**: Free tier
- 🔄 **Deployment**: Every commit to any branch
- ⚡ **Performance**: Basic (sufficient for development)

#### **Test Environment (B1 Basic)** 
- 🎯 **Purpose**: Integration testing and UAT
- 💰 **Cost**: Low-cost basic tier
- 🔄 **Deployment**: Only main branch after dev success
- 🧪 **Testing**: Automated test suite execution

#### **Staging Environment (S1 Standard)**
- 🎯 **Purpose**: Pre-production validation
- 💰 **Cost**: Standard tier (supports deployment slots)
- 🔄 **Deployment**: Only main branch after test success
- 🔄 **Slots**: Preview slot for blue-green deployments

## 🎯 Demo Scenarios

### **Scenario 1: Feature Development**
1. Create feature branch
2. Push changes → Deploys to **Dev** only
3. Test in dev environment
4. Merge to main → Flows through all stages

### **Scenario 2: Production Release**
1. Push to main branch
2. **Build** → Creates deployment artifacts
3. **Dev** → Immediate deployment for dev testing
4. **Test** → Runs integration tests
5. **Staging** → Production-like validation
6. **Preview Slot** → Blue-green deployment prep
7. **Production Approval** → Manual gate
8. **Slot Swap** → Zero-downtime release

## 🔍 Testing Your Setup

Run this validation script:
```powershell
# Test all environments
$environments = @(
    @{Name="Dev"; Url="https://tailspin-dev-webapp.azurewebsites.net"},
    @{Name="Test"; Url="https://tailspin-test-webapp.azurewebsites.net"},
    @{Name="Staging"; Url="https://tailspin-staging-webapp.azurewebsites.net"},
    @{Name="Preview"; Url="https://tailspin-staging-webapp-preview.azurewebsites.net"}
)

foreach ($env in $environments) {
    Write-Host "Testing $($env.Name): $($env.Url)" -ForegroundColor Cyan
    try {
        $response = Invoke-WebRequest -Uri $env.Url -Method GET -TimeoutSec 10
        Write-Host "✅ $($env.Name) is responding (HTTP $($response.StatusCode))" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ $($env.Name) not responding (normal if not deployed yet)" -ForegroundColor Yellow
    }
}
```

## 🏗️ Infrastructure Costs

| Environment | Tier | Monthly Cost (approx) | Purpose |
|-------------|------|----------------------|---------|
| Dev | F1 Free | $0 | Development |
| Test | B1 Basic | ~$13 | Testing |
| Staging | S1 Standard | ~$73 | Pre-production |
| **Total** | | **~$86/month** | Complete pipeline |

## 🎊 Benefits Demonstrated

✅ **Separate environments** for each stage  
✅ **Progressive deployment** with quality gates  
✅ **Cost optimization** (free dev, basic test, standard staging)  
✅ **Zero-downtime deployments** via slot swapping  
✅ **Manual approval gates** for production  
✅ **Branch-based deployment** (dev vs main)  
✅ **Automated testing** at each stage  

This setup provides a complete enterprise-grade deployment pipeline! 🚀