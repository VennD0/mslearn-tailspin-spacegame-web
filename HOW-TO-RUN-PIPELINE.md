# Complete Pipeline Setup Guide

## 🎯 Quick Start (Recommended)

### **Step 1: Run Readiness Check**
```powershell
.\check-pipeline-ready.ps1
```

### **Step 2: Commit Your Changes**
```powershell
# Add all files
git add .

# Commit changes
git commit -m "Add multi-stage deployment pipeline with three environments"

# Push to Azure Repos
git push origin main
```

### **Step 3: Create Pipeline in Azure DevOps**

#### **3.1 Navigate to Pipelines**
1. Open **Azure DevOps** in your browser
2. Go to your project
3. Click **Pipelines** in the left menu
4. Click **"New pipeline"** button

#### **3.2 Choose Source**
1. Select **"Azure Repos Git"**
2. Choose your repository: **mslearn-tailspin-spacegame-web**

#### **3.3 Configure Pipeline**
1. Select **"Existing Azure Pipelines YAML file"**
2. Choose the branch: **main**
3. Select path: **`/azure-pipelines-simple.yml`** (start with this)
4. Click **"Continue"**

#### **3.4 Review and Run**
1. Review the pipeline YAML
2. Click **"Run"** to execute immediately
3. Or click **"Save"** to save without running

## 📋 Pipeline Options

### **Option 1: Simple Build Pipeline (Recommended First)**
**File:** `azure-pipelines-simple.yml`
```yaml
# What it does:
✅ Builds the .NET application
✅ Publishes artifacts
❌ No deployment (safe for testing)
```

### **Option 2: Two-Stage Pipeline**
**File:** `azure-pipelines-multistage.yml`
```yaml
# What it does:
✅ Build → UAT → Production Staging → Slot Swap
⚠️ Requires: Service connection + Web apps created
```

### **Option 3: Full Three-Stage Pipeline**
**File:** `azure-pipelines-three-stage.yml`
```yaml
# What it does:
✅ Build → Dev → Test → Staging → Preview → Production
⚠️ Requires: Service connection + 3 Web apps + Environments
```

## 🔧 Prerequisites for Deployment Pipelines

### **For Deployment Pipelines (Options 2 & 3):**

#### **1. Create Service Connection**
1. Go to **Project Settings** → **Service connections**
2. Click **"New service connection"**
3. Choose **"Azure Resource Manager"**
4. Select **"Service principal (automatic)"**
5. Choose your **subscription** and **resource group**
6. Name it: **`azure-service-connection`**

#### **2. Deploy Infrastructure First**
```powershell
# Create resource group
az group create --name rg-tailspin-demo --location eastus

# Deploy infrastructure (choose one):

# For two-stage:
az deployment group create --resource-group rg-tailspin-demo --template-file infra/simple-demo.bicep --parameters appNamePrefix=tailspin

# For three-stage:
az deployment group create --resource-group rg-tailspin-demo --template-file infra/three-stage-demo.bicep --parameters appNamePrefix=tailspin
```

#### **3. Create Environments**
Go to **Pipelines** → **Environments** and create:
- Development
- Test
- Staging
- Production (add approval gate)

#### **4. Update Pipeline Variables**
In your chosen pipeline file, update:
```yaml
variables:
  azureServiceConnection: 'azure-service-connection'  # Your actual name
  devWebAppName: 'tailspin-dev-webapp'               # From deployment output
  testWebAppName: 'tailspin-test-webapp'             # From deployment output
  stagingWebAppName: 'tailspin-staging-webapp'       # From deployment output
```

## 🚀 Running the Pipeline

### **Manual Run**
1. Go to **Pipelines** → Select your pipeline
2. Click **"Run pipeline"**
3. Choose **branch** (usually main)
4. Click **"Run"**

### **Automatic Trigger**
```yaml
# Pipeline runs automatically when you push to main branch
trigger:
- main
```

### **Monitor Pipeline**
1. Click on the **running pipeline**
2. Watch each **stage** progress
3. Click on **jobs** to see detailed logs
4. **Approve** manual gates when prompted

## 📊 Expected Results

### **Simple Pipeline (Build Only)**
```
✅ Build (2-3 minutes)
   ├── Install .NET SDK
   ├── Restore packages  
   ├── Build application
   └── Publish artifacts
```

### **Two-Stage Pipeline**
```
✅ Build → ✅ UAT → ✅ Prod Staging → 🔄 Slot Swap
(5-8 minutes total)
```

### **Three-Stage Pipeline**
```
✅ Build → ✅ Dev → ✅ Test → ✅ Staging → 🔄 Preview → 🔄 Production
(8-12 minutes total)
```

## 🆘 Troubleshooting

### **Build Fails**
- Check project path in pipeline YAML
- Verify .NET version (should be 8.0.x)
- Run local build: `dotnet build`

### **Deployment Fails**
- Verify service connection permissions
- Check web app names in variables
- Ensure environments are created

### **Pipeline Not Found**
- Make sure YAML file is committed and pushed
- Check file path when creating pipeline
- Verify branch selection

## 🎉 Success Indicators

✅ **Pipeline created successfully**  
✅ **Build stage completes without errors**  
✅ **Artifacts are published**  
✅ **Deployment stages complete (if using deployment pipeline)**  
✅ **Web applications are accessible**  

## 📞 Need Help?

If you encounter issues:
1. Check the **detailed logs** in the pipeline run
2. Copy the **error message**
3. Refer to the **troubleshooting guide**
4. Start with the **simple build pipeline** first