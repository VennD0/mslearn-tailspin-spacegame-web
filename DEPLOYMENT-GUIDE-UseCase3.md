# 🚀 UseCase 3 Deployment Guide - Complete Walkthrough

## ✅ **Current Status**
- ✅ Resource Group: `rg-tailspin-aks` created
- ✅ Azure Container Registry: `tailspinacr2025.azurecr.io` created
- 🔄 AKS Cluster: `tailspin-aks-prod` creating (10-15 minutes)
- ✅ Pipeline files updated with ACR name

## 📋 **Step-by-Step Deployment**

### **Step 1: Wait for AKS Creation & Get Credentials**

```bash
# Check AKS creation status
az aks show --resource-group "rg-tailspin-aks" --name "tailspin-aks-prod" --query "provisioningState" -o tsv

# Once "Succeeded", get credentials
az aks get-credentials --resource-group "rg-tailspin-aks" --name "tailspin-aks-prod"
```

### **Step 2: Test Local Docker Build**

```bash
# Login to ACR
az acr login --name tailspinacr2025

# Build Docker image locally (test)
docker build -t tailspinacr2025.azurecr.io/tailspin/spacegame-web:test .

# Push test image
docker push tailspinacr2025.azurecr.io/tailspin/spacegame-web:test
```

### **Step 3: Set Up Azure DevOps**

#### **3.1 Import Repository**
1. Go to Azure DevOps UseCase3 project
2. **Repos** → **Import a Git repository**
3. Clone URL: `https://github.com/VennD0/mslearn-tailspin-spacegame-web.git`
4. Import branch: `usecase3-docker-aks`

#### **3.2 Create Service Connections**

**Docker Registry Service Connection:**
1. **Project Settings** → **Service connections**
2. **New service connection** → **Docker Registry**
3. Settings:
   - Registry type: **Azure Container Registry**
   - Subscription: Your Azure subscription
   - Azure container registry: `tailspinacr2025`
   - Service connection name: `tailspin-acr-connection`
   - ✅ Grant access permission to all pipelines

**Kubernetes Service Connection:**
1. **New service connection** → **Kubernetes**
2. Settings:
   - Authentication method: **Azure Subscription**
   - Subscription: Your Azure subscription
   - Cluster: `tailspin-aks-prod`
   - Namespace: `tailspin`
   - Service connection name: `tailspin-aks-connection`
   - ✅ Grant access permission to all pipelines

#### **3.3 Create Pipeline**
1. **Pipelines** → **New pipeline**
2. **Azure Repos Git** (since you imported)
3. Select your repository
4. **Existing Azure Pipelines YAML file**
5. Branch: `usecase3-docker-aks`
6. Path: `/azure-pipelines.yml`
7. **Save and run**

### **Step 4: Run Pipeline & Monitor**

The pipeline will execute these stages:
1. **Build Stage**: 
   - Restore .NET dependencies
   - Build application
   - Run unit tests
   - Build Docker image
   - Push to ACR

2. **Deploy Stage**:
   - Create Kubernetes namespace
   - Deploy to AKS cluster
   - Expose via LoadBalancer

### **Step 5: Access Your Application**

```bash
# Check deployment status
kubectl get pods -n tailspin

# Get service details
kubectl get service tailspin-spacegame-web-service -n tailspin

# Wait for EXTERNAL-IP (may take 2-3 minutes)
# Example output:
# NAME                               TYPE           CLUSTER-IP   EXTERNAL-IP      PORT(S)        AGE
# tailspin-spacegame-web-service     LoadBalancer   10.0.37.27   20.124.123.45    80:30572/TCP   2m
```

**Access URL**: `http://EXTERNAL-IP` (use the EXTERNAL-IP from above)

## 🔍 **Troubleshooting Commands**

```bash
# Check pod logs
kubectl logs -n tailspin -l app=spacegame-web

# Describe pods for issues
kubectl describe pods -n tailspin

# Check all resources
kubectl get all -n tailspin

# Port forward for testing
kubectl port-forward -n tailspin service/tailspin-spacegame-web-service 8080:80
# Then access: http://localhost:8080
```

## 📊 **Expected Results**

✅ **Successful Deployment Indicators:**
- Pipeline completes both stages successfully
- 3 pods running in `tailspin` namespace
- LoadBalancer service has external IP assigned
- Application accessible via external IP

✅ **What You'll See:**
- Tailspin SpaceGame web application running in Kubernetes
- Same application as UseCase 1 & 2, but containerized
- Auto-scaling ready infrastructure
- Production-grade Kubernetes deployment

## 🎯 **Next Steps After Deployment**

1. **Scale the application**:
   ```bash
   kubectl scale deployment tailspin-spacegame-web -n tailspin --replicas=5
   ```

2. **Check auto-scaling** (if HPA configured):
   ```bash
   kubectl get hpa -n tailspin
   ```

3. **Update application** (via pipeline):
   - Make code changes
   - Commit to `usecase3-docker-aks` branch
   - Pipeline auto-triggers rolling update

4. **Monitor with kubectl**:
   ```bash
   kubectl top pods -n tailspin
   kubectl get events -n tailspin
   ```

## 🎉 **Success Criteria**

✅ **UseCase 3 Complete When:**
- AKS cluster is running
- ACR contains your application image
- Application pods are healthy
- LoadBalancer provides external access
- CI/CD pipeline successfully deploys updates

---

**📝 This guide provides everything needed to complete UseCase 3: Docker + AKS deployment!**