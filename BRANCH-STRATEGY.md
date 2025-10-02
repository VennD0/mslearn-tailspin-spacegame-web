# Branch Strategy for Tailspin Space Game DevOps Use Cases

This repository supports three different Azure DevOps pipeline use cases, organized by branch:

## 🌿 Branch Structure

### `main` Branch - UseCase1: Classic ARM DevOps
**Purpose**: Simple, straightforward Azure DevOps pipeline  
**Pattern**: Build → Deploy (single job)  
**Target**: Classic ARM deployment pattern  
**Pipeline File**: `azure-pipelines.yml`

**Features**:
- ✅ Single job build and deploy
- ✅ Conditional deployment (main branch only)
- ✅ Simple artifact publishing
- ✅ Direct Azure Web App deployment

**Azure DevOps Setup**: Point your UseCase1 pipeline to the `main` branch

---

### `multistage-pipeline` Branch - UseCase2: Multi-Stage with Deployment Slots
**Purpose**: Advanced multi-stage pipeline with blue-green deployments  
**Pattern**: Build → Dev → Test → Staging (4 stages)  
**Target**: Enterprise deployment with deployment slots  
**Pipeline File**: `azure-pipelines.yml`

**Features**:
- ✅ Multi-stage pipeline (Build → Dev → Test → Staging)
- ✅ Environment targeting with approvals
- ✅ Deployment slots for zero-downtime deployments
- ✅ Blue-green deployment pattern
- ✅ Artifact promotion between stages

**Azure DevOps Setup**: Point your UseCase2 pipeline to the `multistage-pipeline` branch

---

### `usecase3-docker-aks` Branch - UseCase3: Docker and AKS Deployment
**Purpose**: Containerized application deployment to Azure Kubernetes Service  
**Pattern**: Build → Containerize → Deploy to AKS  
**Target**: Container orchestration with Kubernetes  
**Pipeline File**: `azure-pipelines.yml`

**Features**:
- ✅ Docker containerization of .NET application
- ✅ Azure Container Registry (ACR) integration
- ✅ Azure Kubernetes Service (AKS) deployment
- ✅ Kubernetes manifests and configuration
- ✅ Container CI/CD pipeline
- ✅ Kubernetes rolling deployments

**Azure DevOps Setup**: Point your UseCase3 pipeline to the `usecase3-docker-aks` branch

---

## 🚀 How to Use

### For UseCase1 (Classic ARM):
1. In Azure DevOps, create/edit your pipeline
2. Set **Source Branch**: `main`
3. Pipeline will use the simple build+deploy pattern

### For UseCase2 (Multi-Stage):
1. In Azure DevOps, create/edit your pipeline  
2. Set **Source Branch**: `multistage-pipeline`
3. Pipeline will use the 4-stage deployment pattern

### For UseCase3 (Docker + AKS):
1. In Azure DevOps, create/edit your pipeline
2. Set **Source Branch**: `usecase3-docker-aks`
3. Pipeline will use containerization and Kubernetes deployment

### Current Infrastructure Status:
- ✅ **UAT Environment**: `https://tailspin-uat-webapp.azurewebsites.net` (UseCase 1 & 2)
- ✅ **Production**: `https://tailspin-prod-webapp.azurewebsites.net` (UseCase 1 & 2)
- ✅ **Staging Slot**: `https://tailspin-prod-webapp-staging.azurewebsites.net` (UseCase 2)
- 🚧 **AKS Cluster**: To be deployed (UseCase 3)

## 🔧 Infrastructure

### UseCase 1 & 2 (Shared):
- Resource Group: `rg-tailspin-demo`
- UAT App Service: `tailspin-uat-webapp` (Free F1)
- Production App Service: `tailspin-prod-webapp` (Standard S1) with staging slot
- Bicep Templates: Available in `infra/` folder

### UseCase 3 (New):
- Resource Group: `rg-tailspin-aks` (to be created)
- Azure Container Registry: `tailspinacr` (to be created)
- Azure Kubernetes Service: `tailspin-aks-cluster` (to be created)
- Kubernetes manifests: To be added in `k8s/` folder

## 📋 Repository Structure by Use Case

| Use Case | Branch | Pipeline | Infrastructure | Deployment Target |
|----------|--------|----------|----------------|-------------------|
| **UseCase1** | `main` | Classic ARM | App Service | Azure Web App |
| **UseCase2** | `multistage-pipeline` | Multi-stage YAML | App Service + Slots | Blue-Green Deployment |
| **UseCase3** | `usecase3-docker-aks` | Container CI/CD | AKS + ACR | Kubernetes Cluster |

## 📝 Notes

- All use cases use the same Tailspin SpaceGame .NET 8 application
- UseCase1 & 2 share the same Azure infrastructure
- UseCase3 requires new container-focused infrastructure
- Each use case demonstrates different deployment patterns and technologies
- Infrastructure provisioned via Bicep (Infrastructure as Code)
- Branch strategy prevents conflicts between different pipeline approaches

## 🎯 Next Steps for UseCase 3

1. Create Dockerfile for .NET application
2. Add Kubernetes deployment manifests
3. Create Azure Container Registry
4. Set up AKS cluster
5. Configure container CI/CD pipeline
6. Test containerized deployment