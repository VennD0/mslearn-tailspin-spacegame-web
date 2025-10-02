# 🔄 Integration Guide: Tailspin SpaceGame + Azure DevOps Template #12

## 📋 **Current Situation**
- ✅ Azure DevOps UseCase3 project created with Template #12 files
- ✅ Tailspin SpaceGame containerization complete (this repository)
- ✅ Azure infrastructure deployed (ACR + AKS)
- 🔄 Need to integrate both codebases

## 🎯 **Integration Strategy**

### **Step 1: Access Your Azure DevOps Project**
1. Go to: `https://dev.azure.com/devops-delapena/UseCase3-Docker-AKS`
2. Navigate to **Repos** → **Files**
3. See what files are already there from Template #12

### **Step 2: Files to Copy from Tailspin SpaceGame**

**Essential Application Files:**
```
📁 Tailspin.SpaceGame.Web/          # Copy entire folder (our .NET app)
📄 Dockerfile                       # Copy (our containerization)
📄 .dockerignore                    # Copy (our optimization)
```

**Kubernetes Configuration:**
```
📁 k8s/                            # Copy entire folder
  ├── namespace.yaml               # Kubernetes namespace
  ├── deployment.yaml              # Application deployment
  ├── service.yaml                 # LoadBalancer service
  └── ingress.yaml                 # HTTP routing
```

**Infrastructure as Code:**
```
📁 infra/                          # Copy/merge with existing
  └── aks-infrastructure.bicep     # Our AKS + ACR template
```

**Pipeline Configuration:**
```
📄 azure-pipelines.yml             # Replace or merge with existing
```

**Documentation:**
```
📄 README-UseCase3.md              # Copy (our documentation)
📄 DEPLOYMENT-GUIDE-UseCase3.md    # Copy (deployment guide)
📄 BRANCH-STRATEGY.md              # Copy (branch strategy)
```

### **Step 3: Manual Copy Process**

#### **Option A: Via Azure DevOps Web Interface**

1. **Upload Application Code:**
   - In Azure DevOps, go to **Repos** → **Upload files**
   - Upload the entire `Tailspin.SpaceGame.Web` folder
   - Upload `Dockerfile` and `.dockerignore`

2. **Upload Kubernetes Manifests:**
   - Create `k8s` folder in Azure DevOps
   - Upload all files from our `k8s/` directory

3. **Upload Infrastructure:**
   - Upload `infra/aks-infrastructure.bicep`

4. **Update Pipeline:**
   - Replace or update `azure-pipelines.yml` with our version

#### **Option B: Clone and Copy (If Access Works)**

```bash
# Try different authentication
git clone https://<your-pat-token>@dev.azure.com/devops-delapena/UseCase3-Docker-AKS/_git/UseCase3-Docker-AKS

# Or try with interactive login
git clone https://dev.azure.com/devops-delapena/UseCase3-Docker-AKS/_git/UseCase3-Docker-AKS
```

### **Step 4: Pipeline Configuration Updates**

**Update the pipeline file with our configuration:**

```yaml
# UseCase3: Docker + AKS Pipeline (Updated)
trigger:
- main

variables:
  buildConfiguration: 'Release'
  dockerRegistryServiceConnection: 'tailspin-acr-connection'
  imageRepository: 'tailspin/spacegame-web'
  containerRegistry: 'tailspinacr2025.azurecr.io'
  dockerfilePath: 'Dockerfile'
  tag: '$(Build.BuildId)'
  k8sNamespace: 'tailspin'
  aksServiceConnection: 'tailspin-aks-connection'

# ... rest of our pipeline configuration
```

### **Step 5: Service Connections Setup**

In Azure DevOps project settings:

**Docker Registry Service Connection:**
- Name: `tailspin-acr-connection`
- Type: Azure Container Registry
- Registry: `tailspinacr2025`

**Kubernetes Service Connection:**
- Name: `tailspin-aks-connection` 
- Type: Kubernetes
- Cluster: `tailspin-aks-prod`
- Namespace: `tailspin`

### **Step 6: Validate Integration**

1. **Check file structure** in Azure DevOps:
   ```
   UseCase3-Docker-AKS/
   ├── 📁 Tailspin.SpaceGame.Web/    # Our app
   ├── 📁 k8s/                       # Our Kubernetes config
   ├── 📁 infra/                     # Infrastructure
   ├── 📄 Dockerfile                 # Our containerization
   ├── 📄 azure-pipelines.yml        # Updated pipeline
   └── 📁 [Template #12 files]       # Existing template files
   ```

2. **Test pipeline** by running it in Azure DevOps

## 🚀 **Alternative: Import from GitHub**

**Simplest approach if you have access:**

1. **Delete existing content** in Azure DevOps repo (if possible)
2. **Import repository:**
   - Go to **Repos** → **Import a repository**
   - Source: `https://github.com/VennD0/mslearn-tailspin-spacegame-web.git`
   - Branch: `usecase3-docker-aks`

## 📞 **Need Help?**

**If you encounter access issues:**
1. Check Azure DevOps permissions
2. Verify Personal Access Token (PAT)
3. Contact Azure DevOps admin for repository access
4. Try the web interface upload method

**Files ready for copying:**
- All files are in our current directory
- Infrastructure is already deployed
- Pipeline is configured with correct ACR name

## ✅ **Success Indicators**

✅ **Integration Complete When:**
- Tailspin.SpaceGame.Web folder in Azure DevOps repo
- Dockerfile and Kubernetes manifests uploaded
- Pipeline runs successfully
- Application deploys to AKS cluster

---

**📝 Choose the method that works best with your Azure DevOps access level!**